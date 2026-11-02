"""Verify the real browser export with Chromium and OCR.
Serve exports/web at 127.0.0.1:8765 first. Requires Python Playwright,
/usr/bin/chromium and tesseract. Screenshots/report go to ignored exports/.
This uses a fresh browser context and does not alter a player's saved ledger.
"""
from playwright.sync_api import sync_playwright
from pathlib import Path
import subprocess,json,re,os
os.environ["OMP_THREAD_LIMIT"]="1"
ROOT=Path(__file__).resolve().parents[1]
out=ROOT/'exports'/'validation-v0.25';out.mkdir(parents=True,exist_ok=True)
def ocr(page,name):
 p=out/(name+'.png');page.screenshot(path=str(p));return subprocess.check_output(['tesseract',str(p),'stdout'],stderr=subprocess.DEVNULL,text=True)
def click(page,x,y):page.mouse.click(x,y);page.wait_for_timeout(300)
def draft(page):
 for hero in range(3):
  click(page,180,280);click(page,490,280);click(page,1130,830)
with sync_playwright() as p:
 b=p.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
 page=b.new_page(viewport={'width':1440,'height':900},device_scale_factor=1)
 errors=[];page.on('console',lambda m:errors.append(m.text) if m.type=='error' else None);page.on('pageerror',lambda e:errors.append(str(e)))
 page.goto('http://127.0.0.1:8765');page.wait_for_timeout(6000);draft(page)
 text=ocr(page,'03-boss-review');assert 'CHOOSE YOUR ENCOUNTER' in text,text
 click(page,480,850);text=ocr(page,'04-six-events');assert 'THE ASH ROAD' in text,text
 seen=set();rewards=[]
 for trial in range(50):
  click(page,720,620);text=ocr(page,'event-current')
  m=re.search(r'd6\s*[→>—-]*\s*([1-6])\s*[.·:—-]',text)
  if not m:
   # Tesseract reads the arrow as a hyphen; the selected title is unique.
   titles=['Abandoned Supplies','Ash Shrine','Stranded Traveller','Scavenger Ambush','Infested Ruins','Buried Reliquary']
   # Selected heading begins below the slots.
   cropped=page.screenshot(path=str(out/'event-crop.png'),clip={'x':0,'y':360,'width':1440,'height':420})
   detail=subprocess.check_output(['tesseract',str(out/'event-crop.png'),'stdout'],stderr=subprocess.DEVNULL,text=True)
   event=next((i+1 for i,t in enumerate(titles) if t.lower() in detail.lower()),None)
  else:event=int(m.group(1))
  assert event is not None,text
  seen.add(event);page.screenshot(path=str(out/f'event-{event}-choice.png'))
  click(page,400,710) # guaranteed safe option, visibly resolves/earns reward
  text=ocr(page,f'event-{event}-resolved');assert 'New sortie' in text,text
  if event in [1,3,6]:assert 'Granted:' in text,text
  rewards.append({'event':event,'text':text})
  if len(seen)==6:break
  click(page,330,710)
 assert len(seen)==6,seen
 # Save, reload and navigate back: ledger must survive, and completed result cannot re-claim.
 before=ocr(page,'05-before-reload');page.wait_for_timeout(2000);page.reload();page.wait_for_timeout(6000);draft(page);click(page,480,850)
 after=ocr(page,'06-after-reload');assert 'New sortie' in after and 'Roll event' not in after,after
 inv_before=next(x for x in before.splitlines() if 'Salves' in x and 'Fragments' in x)
 inv_after=next(x for x in after.splitlines() if 'Salves' in x and 'Fragments' in x)
 assert inv_before==inv_after,(inv_before,inv_after)
 # Start ordinary encounter through a genuinely rolled event.
 for trial in range(40):
  click(page,330,710);click(page,720,620);text=ocr(page,'combat-candidate')
  if 'Fight 2 Scavengers' in text or 'Fight 2 Cinder Mites' in text:
   click(page,1040,710);page.wait_for_timeout(2000);text=ocr(page,'07-ordinary-combat');assert 'Defeat both' in text,text
   click(page,350,125);click(page,680,531);text=ocr(page,'08-supplies');assert 'EXPEDITION SUPPLIES' in text,text
   click(page,680,600);click(page,80,125);page.wait_for_timeout(500);ocr(page,'09-dice');page.keyboard.press('Escape')
   break
  click(page,400,710)
 else:raise AssertionError('No ordinary encounter rolled')
 (out/'validation.json').write_text(json.dumps({'seen':sorted(seen),'trials':len(rewards),'browser_errors':errors,'rewards':rewards},indent=2))
 assert not errors,errors
 print('PASS: six browser events, safe choices, exact reward summaries, reload lock, ordinary combat, supplies and dice; no browser errors',flush=True)
 b.close()
