"""Build an Excel workbook and a self-contained browser report from recorded v0.16 trials.
Run: python tools/make_playtest_report.py [output_directory]
Refresh reference data only with: godot --headless --path . --script tools/export_trial_reference.gd
No gameplay or recorded battle outcomes are changed by this report.
"""
from pathlib import Path
from collections import Counter
import json, sys, html
import xlsxwriter

ROOT = Path(__file__).resolve().parents[1]
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / 'downloads'
OUT.mkdir(parents=True, exist_ok=True)
DATA = json.loads((ROOT / 'docs/Trial-results-v0.16.json').read_text())
REF = json.loads((ROOT / 'docs/Trial-reference-v0.16.json').read_text())
FACES = {f['id']: f for f in REF['faces']}
HEROES = ['Vesper', 'Rook', 'Wren']
TEAMS = {
 'starting': ('Basic starting dice', 'No bonus abilities. Each hero has the ordinary starting dice.', 'Tests whether the basic abilities can beat the boss without any chosen upgrades.'),
 'mixed': ('Random bonus abilities', 'Each hero receives two different random abilities from the full 47-face bonus pool.', 'A broad sample of legal loadouts. This is not one fixed team and does not represent how people choose their abilities.'),
 'numeric': ('More attacks with rolled damage', 'Every hero chooses two additional attack abilities that use the separate Numeric die to determine damage.', 'This was previously called “Numeric attacks”. It means an attack-heavy loadout, not a different character class or a different Numeric die.'),
 'support': ('Healing and protection', 'The chosen bonuses focus on healing allies, gaining Block, reducing damage and swapping positions.', 'This team sacrifices some offensive options. The bot does not optimize deliberate tanking or every rescue combination.'),
 'channel': ('Maintained effects (Channels)', 'Each hero chooses one effect that can stay active between turns and one attack with rolled damage.', 'A maintained Channel holds one Action die, leaving fewer dice available to roll. Only one Channel per hero is supported.'),
 'growth': ('Abilities that improve dice', 'The chosen abilities add or spread useful faces during the fight, alongside healing and protection.', 'Growth changes apply to this fight only. Initial dice still follow the normal construction rules.'),
}
MODES = ['Blank has no movement effect', 'One Blank becomes Move 1', 'One Blank becomes Move 2']
SHORTMODES = ['Movement OFF', 'Blank → Move 1', 'Blank → Move 2']
COLORS = ['#738093', '#158A87', '#C58B32']
XLSX_NAME = 'Ash-and-Oath-Playtest-v0.16.xlsx'
GLOSSARY = [
 ('Action die', 'Chooses which ability you get to use. Each hero has three six-sided Action dice.'),
 ('Numeric die', 'A separate value die used by some attacks, healing and defenses. Its sides are 2, 2, 1, 1, 1, 0. It is not an extra Action die.'),
 ('Attack with rolled damage', 'An ability that rolls the Numeric die to set its base damage. For example: Strike Numeric. Modifiers, Block and Weakness can change the final HP damage.'),
 ('Basic Strike', 'The ordinary starting attack has base damage 1. It does not roll Numeric for its damage.'),
 ('Blank movement OFF', 'A rolled Action-die Blank cannot move a hero. This is the normal starting setting.'),
 ('Blank → Move 1 or 2', 'With the test Soul ON, spend one rolled Action-die Blank to move up to 1 or 2 orthogonal spaces. Maximum one conversion per hero’s own turn, including a full recovery turn. Other heroes have their own allowance.'),
 ('Numeric zero versus Blank', 'A Numeric result of 0 is a value roll. It cannot be converted into movement. Only a rolled Blank on an Action die can use the test Soul.'),
 ('Turn versus round', 'A turn is one hero or the boss acting. A round contains the actors’ turns in initiative order. “Average rounds” is not a count of clicks, dice or individual turns.'),
 ('Channel', 'An effect maintained between turns. Its Action die is held rather than rolled. Maintain or release it at the hero’s next turn; its printed interruption rules still apply.'),
 ('Block and protection', 'Block absorbs ordinary damage and is consumed. Remaining Block normally expires at that unit’s next turn start. Stonewake can preserve it while maintained.'),
 ('Downed versus dead', 'A hero at 0 HP can be Downed and potentially revived. “Downings” counts events, including repeat events; it is not a count of permanently dead heroes. A party with no standing hero loses.'),
 ('Starting reroll', 'Each hero starts with one Action Reroll. That charge does not refill every round. Use it in the opening window before ordinary actions.'),
 ('Test seed', 'A reproducible random starting seed. Seeds 1–200 were reused across settings and before/after fixes. Changing actions changes later random draws.'),
]
# Short plain-language descriptions for the specific bonus faces in the fixed teams.
EFFECTS = {
 0: 'A rolled Action-die Blank has no ordinary effect. With the test Soul ON, one Blank per hero turn may be spent for movement. It stays installed as Blank.',
 1: 'Basic Strike: attack an adjacent unit for base damage 1. It does not roll the Numeric die. Block and Weakness can reduce the HP damage.',
 2: 'Step: move up to 1 orthogonal space to a legal empty cell. Cannot move while Rooted.',
 3: 'Stride: move up to 3 orthogonal spaces in one straight line. Cannot turn, pass through units or move while Rooted.',
 4: 'Guard: gain 1 Block.',
 5: 'Stored automatically when rolled. When personally attacked, react to gain 1 Block and optionally step up to 1 space. Rooted prevents the step.',
 6: 'Reroll another unresolved Action die and resolve its new result next. This spends Focus; it does not use the separate banked Action Reroll charge.',
 7: 'Heal yourself or an adjacent hero for 1 HP. Healing a Downed hero revives them as Broken and queues an immediate recovery turn after the acting turn ends.',
 8: 'Shove an adjacent unit up to 1 legal space away, with no collision damage. This owned starter ability is not equipped in the default trial layouts.',
 12: 'Install Recovery on a chosen Blank belonging to a hero. Recovery heals a Numeric value at range 1. After two placements, Blessing becomes Blank.',
 19: 'Heal a different hero within 3 and clear sight for a Numeric value, normally at least 1. Gambler’s absolute ×0 remains zero.',
 25: 'Maintain to gain benefits from future rolls: Blanks grant 1 Block; other results add Numeric power, capped at +2. HP loss breaks it, causes 2 normal backlash damage and leaves a Red Tile.',
 31: 'Gain 2 Block immediately. Maintain to keep Block and gain 1, up to 8. Any HP loss or 2 cumulative Block lost before your next turn interrupts it.',
 33: 'Replace a chosen Blank on your own dice with Bone for this fight. Bone gives 1 Block and may step 1 space.',
 34: 'Attack an adjacent unit. Roll the separate Numeric die for base damage: 2, 2, 1, 1, 1 or 0.',
 35: 'Attack a visible unit within 2. Roll Numeric, with final damage capped at 2 per resolution, including Mark Prey. Units block sight.',
 36: 'Attack an adjacent unit using Numeric damage. If the hit removes at least 2 HP, gain Block equal to the HP damage dealt.',
 37: 'Attack an adjacent unit using Numeric damage. Ignore 1 of its Block for this hit; the bypassed Block remains afterward.',
 39: 'Attack an adjacent unit using Numeric damage. Add 1 when standing at the southern edge of the north-facing boss.',
 40: 'Attack an adjacent unit using Numeric damage. If you break existing Block and also damage HP, delay an upcoming boss activation by one initiative slot when possible.',
 41: 'Attack using Numeric damage. On HP damage, once per hero turn, copy Engrave into a Blank on the same die, up to 3 copies. Three copies give +1 damage. Never overwrites another ability.',
 42: 'Roll Numeric and gain that much Block.',
 43: 'Gain 3 Block if you currently have none; otherwise gain 1 Block.',
 44: 'Stored Reaction: when an ally within 2 and clear sight is attacked, give both that ally and yourself 1 Block before the hit.',
 47: 'Gain Damage Reduction 1 and Weakness 1 until your next turn. You take less ordinary HP damage after Block, but your own attacks deal 1 less damage.',
 49: 'Maintain to heal 1 at the next turn start. Any HP damage interrupts the Channel and turns this face into Blank.',
 58: 'Swap with a standing ally within 3 and clear sight. Both gain 1 Block. Rooted prevents the swap; the boss and Downed allies are ineligible.',
}
FIXES = [
 ('Black Oath', 'A cost could survive a turn that ended with zero Block and charge HP after a later Guard.', 'The cost expires at the end of the casting turn. It charges once only if Block remains then.'),
 ('Wither Ward', 'Self-costs, friendly fire or Cinder Brand could wrongly give Weakness to the boss.', 'Only actual HP loss from an adjacent boss Attack triggers the Ward.'),
 ('Fracture = 0', 'Setting the number of removed faces to zero still forced a face to be removed.', 'Zero removes no faces and opens no destructive choice.'),
 ('Killing-hit rewards', 'Victory skipped Engrave growth and Hooked Slash Block on the final hit.', 'A qualifying killing hit still grants those personal rewards. Further damage stops at victory.'),
 ('Cost log', 'Black Oath’s damage entry could inherit an unrelated action label.', 'The log names Black Oath cost and the hero paying it.'),
]
SCENARIOS = DATA['after']['scenarios']
BEFORE = {(s['kit'], s['blank_move']): s for s in DATA['before']['scenarios']}
def scenario(kit, mode): return next(s for s in SCENARIOS if s['kit'] == kit and s['blank_move'] == mode)
def name(face): return FACES[int(face)]['name']
def removed(build):
 base = Counter(f for d in REF['teams']['starting']['builds'][0] for f in d if f)
 actual = Counter(f for d in build for f in d if f)
 return ', '.join(f'{name(f)}' + (f' ×{n}' if n > 1 else '') for f,n in (base-actual).items()) or 'None'

wb = xlsxwriter.Workbook(OUT / XLSX_NAME)
wb.set_properties({'title':'Ash & Oath — explained battle trials','subject':'v0.16 playtest results, exact loadouts and changes','author':'Ash & Oath prototype','comments':'Recorded trials; no invented individual battle results.'})
navy,teal,gold,muted = '#182638','#117E7B','#AC7623','#59677B'
fmt = {}
fmt['title']=wb.add_format({'font_name':'Calibri','font_size':25,'bold':True,'font_color':navy,'valign':'vcenter'})
fmt['subtitle']=wb.add_format({'font_size':11,'font_color':muted,'text_wrap':True,'valign':'vcenter'})
fmt['section']=wb.add_format({'font_size':13,'bold':True,'font_color':teal,'bottom':1,'bottom_color':'#D7E4E5','valign':'vcenter'})
fmt['text']=wb.add_format({'font_size':11,'font_color':navy,'text_wrap':True,'valign':'top'})
fmt['label']=wb.add_format({'font_size':11,'bold':True,'font_color':navy,'text_wrap':True,'valign':'top','bg_color':'#EEF3F8'})
fmt['note']=wb.add_format({'font_size':11,'font_color':'#6B4C18','bg_color':'#FFF4DF','text_wrap':True,'valign':'vcenter'})
fmt['header']=wb.add_format({'bold':True,'font_color':'#FFFFFF','bg_color':navy,'text_wrap':True,'valign':'vcenter','font_size':11,'border_color':'#FFFFFF'})
fmt['cell']=wb.add_format({'font_size':11,'font_color':navy,'text_wrap':True,'valign':'vcenter'})
fmt['int']=wb.add_format({'font_size':11,'font_color':navy,'num_format':'0','valign':'vcenter'})
fmt['num']=wb.add_format({'font_size':11,'font_color':navy,'num_format':'0.00','valign':'vcenter'})
fmt['pct']=wb.add_format({'font_size':12,'bold':True,'num_format':'0.0%','font_color':navy,'valign':'vcenter'})
fmt['delta']=wb.add_format({'font_size':11,'num_format':'+0.0;-0.0;0.0','font_color':navy,'valign':'vcenter'})
fmt['link']=wb.add_format({'font_size':11,'font_color':teal,'underline':True,'valign':'vcenter'})
fmt['metric']=wb.add_format({'font_size':25,'bold':True,'font_color':teal,'bg_color':'#E9F5F1','align':'center','valign':'vcenter'})
fmt['metriclabel']=wb.add_format({'font_size':11,'font_color':navy,'bg_color':'#E9F5F1','align':'center','valign':'vcenter','text_wrap':True})
SHEETS=['Start here','Win rates','Team lineups','Ability guide','Dice layouts','Detailed results','Method & fixes','Random draws']
ws={n:wb.add_worksheet(n) for n in SHEETS}
for n,w in ws.items():
 w.hide_gridlines(2);w.set_tab_color(teal if n in SHEETS[:3] else gold if n=='Method & fixes' else '#8291A4')
 w.set_default_row(22);w.set_column('A:A',4);w.set_column('B:K',12)
 w.set_landscape();w.set_paper(9);w.fit_to_pages(1,0);w.set_margins(.3,.3,.4,.4)
 w.set_header('&L&BAsh & Oath&RPlaytest report · v0.16');w.set_footer('&LRecorded bot trials · see Method & fixes&RPage &P of &N')
 w.merge_range('B2:K3', 'ASH & OATH  /  '+n.upper(),fmt['title'])
 w.merge_range('B4:K5','v0.16 · Same recorded battles, clearer explanations · Choose a tab below to explore.',fmt['subtitle'])
 for c,(target,label) in enumerate([('Start here','Read first'),('Win rates','Compare wins'),('Team lineups','Exact teams'),('Ability guide','Ability effects'),('Method & fixes','Method / fixes')]):
  w.merge_range(6,1+c*2,6,2+c*2,'',fmt['link']);w.write_url(6,1+c*2,f"internal:'{target}'!B2",fmt['link'],label)
 w.set_row(6,28)

w=ws['Start here'];w.set_zoom(95)
for start,end,value,label in [('B9','D10','7,200','Total battle runs: 3,600 before + 3,600 after'),('F9','H10','200','Battles for EACH team / movement setting'),('J9','K10','0','Stalled battles')]:
 w.merge_range(f'{start}:{end}',value,fmt['metric'])
 # Put the explanation directly underneath each card.
 a=start[0];b=end[0];w.merge_range(f'{a}11:{b}13',label,fmt['metriclabel'])
w.merge_range('B15:K16','Start here: the team labels describe which bonus abilities were chosen. They are not character classes, and the three heroes use the same basic starting dice.',fmt['note'])
w.merge_range('B18:K18','WHAT “NUMERIC ATTACKS” MEANS',fmt['section'])
w.merge_range('B20:K22','Some attack abilities roll a separate Numeric die for their base damage. Its sides are 2, 2, 1, 1, 1, 0. For example, Strike Numeric rolling 2 starts with 2 damage before Block and other modifiers. The normal starting Strike instead starts with a fixed 1 damage.',fmt['text'])
w.merge_range('B24:K26','The report now calls that team “More attacks with rolled damage”. Each hero keeps four Basic Strike faces and gains two attacks with rolled damage, replacing one Step and one Focus. Exact pairs: Vesper — Strike Numeric + Piercing Thrust; Rook — Short Shot + Flanking Blow; Wren — Hooked Slash + Break Rhythm.',fmt['text'])
w.merge_range('B28:K28','HOW TO READ THE RESULTS',fmt['section'])
w.merge_range('B30:K32','Example: 99 player wins + 101 boss wins = 200 completed fights, so the player win rate is 49.5%. Every row / setting has its own 200 fights. The 3,600-fight trial set was repeated after the fixes using the same seeds; it is not 7,200 independent seeds.',fmt['text'])
w.merge_range('B34:K37','Each hero has 3 dice × 6 sides. Initially each die has at least 2 Blanks. In fixed bonus teams, each hero chooses two bonus DESIGNS; the legal automatic layout replaces two starter faces to equip them. It does not add extra dice or 14 non-Blank faces. Exact replacements and all six sides are on Dice layouts.',fmt['note'])
w.merge_range('B39:K39','WHAT THE RESULTS SUGGEST',fmt['section'])
w.merge_range('B41:K43','Optional Blank movement changes difficulty substantially. Random bonus teams won 49.5% with movement OFF, 83.0% with Move 1 and 89.0% with Move 2. The attack-heavy team won more often than the support team under this bot’s strategy.',fmt['text'])
w.merge_range('B45:K48','These are automated comparisons, not predicted human win rates. The bot heals, approaches the boss and tries to escape marked hazards; it does not optimize every ability combination. Whole-team comparisons do not prove that one particular ability is too strong. Default HP and damage numbers were retained; the bug fixes are listed on Method & fixes.',fmt['note'])
w.freeze_panes(7,1);w.print_area('A1:K49')

w=ws['Win rates'];w.set_zoom(90);w.merge_range('B9:K10','Each percentage is the fraction of 200 battles won by the players. The same teams and starting seeds were used across movement settings. One Blank conversion per hero’s OWN turn.',fmt['note'])
headers=['Team / chosen bonus style','Movement OFF','Blank → Move 1','Blank → Move 2','OFF: player wins','OFF: boss wins','Move 1: player wins','Move 1: boss wins','Move 2: player wins','Move 2: boss wins']
for c,h in enumerate(headers):w.write(12,c+1,h,fmt['header'])
w.set_row(12,48);w.set_column('B:B',30);w.set_column('C:E',17);w.set_column('F:K',12)
for i,(kit,(label,_,_)) in enumerate(TEAMS.items()):
 r=13+i;w.set_row(r,44);w.write(r,1,label,fmt['cell'])
 for mode in range(3):
  s=scenario(kit,mode);col=5+mode*2;w.write_number(r,col,s['wins'],fmt['int']);w.write_number(r,col+1,s['losses'],fmt['int'])
  a=xlsxwriter.utility.xl_col_to_name(col);b=xlsxwriter.utility.xl_col_to_name(col+1)
  w.write_formula(r,2+mode,f'={a}{r+1}/SUM({a}{r+1}:{b}{r+1})',fmt['pct'],s['wins']/200)
 for mode in range(3):w.write_comment(r,2+mode,f"{scenario(kit,mode)['wins']} player wins and {scenario(kit,mode)['losses']} boss wins, out of 200. Setting: {MODES[mode]}.")
w.autofilter(12,1,18,10);w.conditional_format('C14:E19',{'type':'3_color_scale','min_type':'num','min_value':0,'mid_type':'num','mid_value':.5,'max_type':'num','max_value':1,'min_color':'#F8DAD6','mid_color':'#FFF0CA','max_color':'#B9E2D1'})
w.merge_range('B21:K23','The movement setting changes only the test Soul: OFF = no Blank movement; Move 1 / Move 2 = spend one rolled Action-die Blank to move up to that many spaces. A Numeric result of 0 cannot become movement. The allowance refreshes on each hero’s own turn, including full recovery turns.',fmt['text'])
chart=wb.add_chart({'type':'bar','subtype':'clustered'})
for mode in range(3):chart.add_series({'name':['Win rates',12,mode+2],'categories':['Win rates',13,1,18,1],'values':['Win rates',13,mode+2,18,mode+2],'fill':{'color':COLORS[mode]},'border':{'none':True},'data_labels':{'value':True,'num_format':'0.0%','position':'outside_end','font':{'size':9}}})
chart.set_title({'name':'Player win rate by team and Blank movement'})
chart.set_x_axis({'min':0,'max':1.1,'major_unit':.25,'num_format':'0%','major_gridlines':{'visible':True,'line':{'color':'#E3E8EE'}}})
chart.set_y_axis({'reverse':True,'num_font':{'size':11}});chart.set_legend({'position':'bottom'});chart.set_chartarea({'border':{'none':True},'fill':{'color':'#FFFFFF'}});chart.set_size({'width':1110,'height':425})
w.insert_chart('B26',chart);w.freeze_panes(13,2);w.print_area('A1:K47')

w=ws['Team lineups'];w.set_column('B:B',29);w.set_column('C:C',12);w.set_column('D:E',25);w.set_column('F:H',17);w.set_column('I:K',12)
w.merge_range('B9:K11','The three heroes start with the same basic body. Fixed teams equip the listed two bonus faces per hero, replacing starter faces. “Random bonus abilities” uses a different drawn pair for every hero / seed; inspect Random draws for all 600 draws.',fmt['note'])
rr=13
for kit,(label,description,limit) in TEAMS.items():
 w.merge_range(rr,1,rr,10,label,fmt['section']);w.set_row(rr,29)
 w.merge_range(rr+1,1,rr+2,10,description+' '+limit,fmt['text'])
 if kit in REF['teams']:
  for hero,pair in enumerate(REF['teams'][kit]['pairs']):
   r=rr+3+hero*2;w.merge_range(r,1,r+1,2,HEROES[hero],fmt['label']);w.merge_range(r,3,r,10,' + '.join(name(f) for f in pair) if pair else 'No bonus faces; ordinary starting dice',fmt['cell']);w.merge_range(r+1,3,r+1,10,'Starter faces replaced: '+removed(REF['teams'][kit]['builds'][hero]),fmt['subtitle'])
  rr+=11
 else:
  w.merge_range(rr+3,1,rr+5,10,'All 47 extended bonus designs are eligible. Each hero receives two distinct designs. Repeated designs across different heroes are allowed. The same draw is used across all three movement settings. Individual random-team battle outcomes were not stored; the report contains aggregate results.',fmt['text']);rr+=8
w.freeze_panes(7,1);w.print_area(0,0,rr,10)

w=ws['Ability guide'];w.set_column('B:B',25);w.set_column('C:D',14);w.set_column('E:K',12)
w.merge_range('B9:K10','Read the type and timing separately. “Attack” says what an ability does. “Reaction” or “Channel” says when / how it is used. Descriptions below use the tested default values.',fmt['note'])
rr=12
for term,definition in GLOSSARY:
 w.merge_range(rr,1,rr+1,3,term,fmt['label']);w.merge_range(rr,4,rr+1,10,definition,fmt['text']);rr+=3
w.merge_range(rr,1,rr,10,'STARTING ABILITIES AND CHOSEN BONUS FACES',fmt['section']);rr+=2
for fid in sorted(EFFECTS):
 f=FACES[fid];w.merge_range(rr,1,rr+2,3,f['name']+'\n'+f['type']+' · '+f['timing'],fmt['label']);w.merge_range(rr,4,rr+2,10,EFFECTS[fid],fmt['text']);rr+=4
w.freeze_panes(7,1);w.print_area(0,0,rr,10)

w=ws['Dice layouts'];w.set_column('B:B',28);w.set_column('C:C',12);w.set_column('D:D',9);w.set_column('E:J',21);w.set_column('K:K',34)
w.merge_range('B9:K11','One row = one six-sided Action die at the START of the trial. All six sides are shown in their actual side order; duplicates are intentional. Starter faces replaced is a total for that hero’s whole build, repeated on its three rows. Growth may change these dice during combat.',fmt['note'])
rows=[]
for kit,info in REF['teams'].items():
 for h,build in enumerate(info['builds']):
  for d,die in enumerate(build):rows.append([TEAMS[kit][0],HEROES[h],['I','II','III'][d]]+[name(f) for f in die]+[removed(build)])
columns=['Team','Hero','Die','Side 1','Side 2','Side 3','Side 4','Side 5','Side 6','Starter faces replaced']
w.add_table(13,1,13+len(rows),10,{'name':'StartingDiceLayouts','style':'Table Style Medium 2','columns':[{'header':h,'format':fmt['cell']} for h in columns],'data':rows})
for r in range(14,14+len(rows)):w.set_row(r,45)
w.freeze_panes(14,4);w.repeat_rows(13);w.print_area(0,0,14+len(rows),10)

w=ws['Detailed results'];w.set_column('B:B',29);w.set_column('C:C',24);w.set_column('D:F',12);w.set_column('G:G',15);w.set_column('H:H',16);w.set_column('I:J',14);w.set_column('K:M',18);w.set_column('N:O',16)
w.merge_range('B9:K11','18 scenarios × 200 battles = 3,600 AFTER-fix fights. Average rounds includes wins and losses. Average boss HP in losses excludes wins. “Downings” counts events, not unique heroes. Phase II means the boss reached half HP.',fmt['note'])
headers=['Team','Blank movement','Battles','Player wins','Boss wins','Player win rate','Average rounds','Phase II fights','Phase II rate','Avg boss HP when lost','Downing events','Stalls','Before: player wins','Change in wins']
rows=[]
for kit in TEAMS:
 for m in range(3):
  s=scenario(kit,m);old=BEFORE[(kit,m)];rows.append([TEAMS[kit][0],SHORTMODES[m],200,s['wins'],s['losses'],s['wins']/200,s['mean_rounds'],s['phase_two'],s['phase_two']/200,s['mean_boss_hp_in_losses'],s['downings'],s['stalls'],old['wins'],s['wins']-old['wins']])
formats=[fmt['cell'],fmt['cell'],fmt['int'],fmt['int'],fmt['int'],fmt['pct'],fmt['num'],fmt['int'],fmt['pct'],fmt['num'],fmt['int'],fmt['int'],fmt['int'],fmt['int']]
w.add_table(13,1,13+len(rows),14,{'name':'DetailedTrialResults','style':'Table Style Medium 2','columns':[{'header':h,'format':f} for h,f in zip(headers,formats)],'data':rows})
w.set_row(13,56)
for r in range(14,32):w.set_row(r,39)
w.freeze_panes(14,3);w.repeat_rows(13);w.print_area('A1:O33')

w=ws['Method & fixes'];w.set_column('B:D',15);w.set_column('E:K',12)
sections=[
 ('What was held constant','Tuned rules; heroes start at 6 HP, boss at 12 HP. Half HP (6) unlocks phase II. All three Action dice have six sides; minimum two Blanks per die initially. Ordinary Numeric values are 2, 2, 1, 1, 1, 0. Each hero starts with one banked Action Reroll. The latest boss rules and half-HP upgrades are active.'),
 ('Boss phases in these trials','The boss starts at 12 HP and enters phase II at 6 HP. Cinder Brand starts as a five-cell cross and upgrades to a 3×3 square for newly armed Brands. Upgraded Ashen Chain adds Rooted until the next boss turn. Furnace Roar unlocks at half HP. Smoking Strike places fire after HP damage and detonates existing fire on another damaging hit.'),
 ('What varied','Six team builds and three Blank movement settings. For the fixed teams, only the selected bonus designs change. The legal auto-builder may replace different starter faces to satisfy body caps; see Dice layouts. Random pairs use all 47 extended designs. All default ability numbers remain unchanged.'),
 ('How the bot plays','It reads visible rolls and board state, prioritizes healing and revivals, uses setup effects, attacks legal targets and approaches the boss. It tries to leave marked Brand cells, avoids fire / board edges when equivalent, rerolls unusable Blanks in its opening window and keeps Channels. It does not inspect future RNG outcomes.'),
 ('Before versus after','Seeds 1–200 were used for every scenario before and after the fixes. That is 3,600 fights per version, 7,200 runs total. Every scenario’s win/loss count stayed unchanged. Dedicated regression cases reproduce the fixed edge cases; unchanged aggregate wins do not mean the bugs were harmless.'),
 ('Limits of the evidence','This is one heuristic bot, not a human playtest or an optimal strategy search. It does not optimize every rescue, tanking or support combination. Reusing the same starting seeds does not force identical later die rolls when decisions change. Whole-team comparisons cannot isolate the balance of one ability.'),
 ('What “no stalls” means','Each fight had a limit of 1,600 decisions or 50 rounds. No fight reached the limit. HP / Block / dead-state checks found no invalid values. This does not prove that every possible game bug has been tested.'),
 ('Why the old starter result differed','The earlier simple bot recorded 17 wins in 100 fights. This newer heuristic recorded 67 in 200 with basic dice and movement OFF. Its healing / revival and hazard-escape choices differ. Compare before/after only when the same policy is used.'),
 ('Balance decision','No default HP, damage or Soul numbers were changed. Random bonus builds with movement OFF won 99/200, which does not support a blanket boss HP reduction. Move 2 plus the attack-heavy kit won 199/200; that optional combination makes this encounter especially forgiving.'),
]
rr=12
for title,body in sections:
 w.merge_range(rr,1,rr,10,title,fmt['section']);w.merge_range(rr+1,1,rr+4,10,body,fmt['text']);rr+=6
w.merge_range(rr,1,rr,10,'FIXED IN v0.16 — WHAT / WHY',fmt['section']);rr+=2
for title,problem,fix in FIXES:
 w.merge_range(rr,1,rr+3,3,title,fmt['label']);w.merge_range(rr,4,rr+3,10,'Problem: '+problem+'\nFix: '+fix,fmt['text']);rr+=5
w.merge_range(rr,1,rr+2,10,'Source data: docs/Trial-results-v0.16.json. Exact reference data: docs/Trial-reference-v0.16.json. Generator: tools/make_playtest_report.py. No new battles were invented or rerun for this presentation update.',fmt['note'])
w.freeze_panes(7,1);w.print_area(0,0,rr+3,10)

w=ws['Random draws'];w.set_column('B:B',10);w.set_column('C:C',12);w.set_column('D:E',27);w.set_column('F:H',49);w.set_column('I:K',12)
w.merge_range('B9:K11','All 600 hero loadouts used by the random-bonus trials: 200 seeds × 3 heroes. The same drawn loadout was used in all three movement settings. These are reconstructed deterministic draws, not individual battle outcomes. Use the filter to inspect a seed or hero.',fmt['note'])
rows=[]
for draw in REF['random_draws']:
 rows.append([draw['seed'],draw['hero']]+[name(f) for f in draw['pair']]+[' / '.join(name(f) for f in die) for die in draw['build']])
w.add_table(13,1,13+len(rows),7,{'name':'RandomBonusDraws','style':'Table Style Medium 2','columns':[{'header':h,'format':fmt['cell']} for h in ['Seed','Hero','Bonus face 1','Bonus face 2','Die I: sides 1–6','Die II: sides 1–6','Die III: sides 1–6']],'data':rows})
for r in range(14,614):w.set_row(r,48)
w.freeze_panes(14,3);w.repeat_rows(13);w.print_area(0,0,614,7)
wb.close()

# A readable browser companion: same figures, no application or account required.
e=lambda s:html.escape(str(s),quote=True)
summary_rows=''.join('<tr><th scope="row">'+e(label)+'</th>'+''.join(f'<td><strong>{scenario(kit,m)["wins"]/2:.1f}%</strong><span>{scenario(kit,m)["wins"]} player wins · {scenario(kit,m)["losses"]} boss wins</span></td>' for m in range(3))+'</tr>' for kit,(label,_,_) in TEAMS.items())
teamcards=[]
for kit,(label,description,limit) in TEAMS.items():
 heroes=''
 if kit in REF['teams']:
  for h,pair in enumerate(REF['teams'][kit]['pairs']):
   abilities=''.join(f'<li><strong>{e(name(f))}</strong><p>{e(EFFECTS[f])}</p></li>' for f in pair) if pair else '<li>Ordinary starting abilities only.</li>'
   dice=''.join(f'<tr><th>Die {"I II III".split()[d]}</th>'+''.join(f'<td>{e(name(f))}</td>' for f in die)+'</tr>' for d,die in enumerate(REF['teams'][kit]['builds'][h]))
   heroes+=f'<section class="hero"><h3>{HEROES[h]}</h3><p class="muted">Attack faces at the start: {sum(FACES[int(f)]['type']=='Attack' for die in REF['teams'][kit]['builds'][h] for f in die)} of 18 sides</p><ul class="abilities">{abilities}</ul><p class="muted">Starter faces replaced: {e(removed(REF["teams"][kit]["builds"][h]))}</p><details><summary>Show all six sides of each die</summary><div class="scroll"><table class="dice"><thead><tr><th>Die</th>'+''.join(f'<th>Side {n}</th>' for n in range(1,7))+f'</tr></thead><tbody>{dice}</tbody></table></div></details></section>'
 else:heroes='<p>There is no single fixed trio of pairs. Every hero draws two different designs from the full bonus pool. The Excel workbook includes all 600 exact hero draws and their dice on the “Random draws” tab.</p>'
 teamcards.append(f'<article class="team" data-kit="{kit}"><div class="eyebrow">TEAM GUIDE</div><h2>{e(label)}</h2><p>{e(description)}</p><p class="callout">{e(limit)}</p>{heroes}</article>')
result_rows=''.join('<tr data-kit="'+kit+'"><th scope="row">'+e(TEAMS[kit][0])+'</th><td>'+e(SHORTMODES[m])+'</td>'+''.join('<td>'+e(v)+'</td>' for v in [s['wins'],s['losses'],f'{s["wins"]/2:.1f}%',f'{s["mean_rounds"]:.2f}',f'{s["phase_two"]}/200',f'{s["mean_boss_hp_in_losses"]:.2f}',s['downings'],s['stalls']])+'</tr>' for kit in TEAMS for m in range(3) for s in [scenario(kit,m)])
glossary=''.join(f'<dt>{e(term)}</dt><dd>{e(body)}</dd>' for term,body in GLOSSARY)
starting_guide=''.join(f'<dt>{e(name(fid))}</dt><dd>{e(EFFECTS[fid])}</dd>' for fid in range(9))
fixrows=''.join(f'<tr><th>{e(t)}</th><td>{e(p)}</td><td>{e(f)}</td></tr>' for t,p,f in FIXES)
method=''.join(f'<details><summary>{e(t)}</summary><p>{e(b)}</p></details>' for t,b in sections)
charts=''.join('<div class="chart-row"><div>'+e(label)+'</div><div class="bars">'+''.join(f'<div class="barline"><span class="bar" style="width:{scenario(kit,m)["wins"]/2}%;--color:{COLORS[m]}"></span><b>{scenario(kit,m)["wins"]/2:.1f}%</b></div>' for m in range(3))+'</div></div>' for kit,(label,_,_) in TEAMS.items())
css='''*{box-sizing:border-box}body{margin:0;background:#f4f6fa;color:#182638;font:16px/1.55 system-ui,sans-serif}header{background:#182638;color:white;padding:48px max(24px,calc((100vw - 1180px)/2)) 36px}header p{max-width:780px;color:#d3deec}h1{font-size:clamp(30px,4vw,48px);line-height:1.12;margin:12px 0}h2{font-size:25px;line-height:1.25}h3{font-size:18px}.eyebrow{font-size:12px;letter-spacing:.15em;font-weight:750;color:#998058}header .eyebrow{color:#edc988}.download{display:inline-block;background:#d5af69;color:#182638;text-decoration:none;font-weight:750;padding:13px 20px;border-radius:8px;margin:8px 0}.secondary{color:#e7eef7;margin-left:20px}main{max-width:1228px;margin:auto;padding:24px}.tabs{display:flex;gap:8px;flex-wrap:wrap;position:sticky;top:0;background:#f4f6faf5;padding:12px 0;z-index:2;border-bottom:1px solid #d9e0e9;margin-bottom:24px}.tabs button{border:1px solid #cbd6df;border-radius:7px;background:white;color:#26394e;padding:11px 16px;font:inherit;cursor:pointer}.tabs button[aria-selected=true]{background:#117e7b;color:white;border-color:#117e7b}.panel[hidden]{display:none}.cards{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}.metric,.paper,.team{background:white;border:1px solid #e0e6ee;border-radius:12px;padding:24px;margin-bottom:20px}.metric strong{font-size:36px;display:block;color:#117e7b}.metric span{font-size:14px;color:#59677b}.callout{background:#fff4df;border-left:4px solid #c58b32;padding:16px 20px;border-radius:6px}.muted{color:#59677b;font-size:14px}.scroll{overflow-x:auto}table{border-collapse:collapse;width:100%;font-size:14px;line-height:1.4}th,td{text-align:left;padding:16px;border-bottom:1px solid #e0e6ee;vertical-align:top}thead th{background:#182638;color:white;font-weight:650}tbody tr:nth-child(even){background:#f5f8fb}td strong{font-size:20px;color:#117e7b}td span{display:block;color:#59677b;font-size:13px;margin-top:6px}tbody th{min-width:180px}summary{cursor:pointer;padding:12px 0;color:#117e7b;font-weight:650}details p{margin-top:0}.hero{border-top:1px solid #e0e6ee;margin-top:24px;padding-top:8px}.abilities{padding-left:22px}.abilities p{margin:4px 0 16px;color:#47586e}.dice{min-width:920px;font-size:13px}.dice th,.dice td{padding:10px}.chart-row{display:grid;grid-template-columns:230px 1fr;gap:20px;margin:22px 0;align-items:center}.barline{position:relative;height:24px;margin:5px 0;padding-right:60px}.bar{display:block;background:var(--color);height:18px;border-radius:3px;max-width:calc(100% - 55px)}.barline b{position:absolute;right:0;top:-2px;font-size:13px}.legend{display:flex;gap:20px;flex-wrap:wrap}.legend i{display:inline-block;width:12px;height:12px;margin-right:5px;border-radius:2px}dl{display:grid;grid-template-columns:220px 1fr;gap:16px 24px}dt{font-weight:700}dd{margin:0}label{display:block;font-weight:700;margin:12px 0}select{padding:10px 14px;border:1px solid #cbd6df;border-radius:6px;font:inherit;max-width:100%}.result-table{min-width:1200px}.result-table td{white-space:nowrap}.team select{width:100%}footer{padding:20px 0;color:#59677b;font-size:13px}@media(max-width:650px){main{padding:14px}.cards{grid-template-columns:1fr}.metric{margin-bottom:0}.paper,.team{padding:18px}.chart-row{grid-template-columns:1fr;gap:4px}dl{grid-template-columns:1fr;gap:6px}dd{margin-bottom:15px}.tabs{position:static}.secondary{display:block;margin:10px 0}th,td{padding:12px}}@media print{.tabs,.download,.secondary,.filters{display:none}.panel[hidden]{display:block}body{background:white}.paper,.team{break-inside:avoid}header{background:white;color:#182638;padding:10px}header p{color:#59677b}details>*{display:block}}'''
htmltext='''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Ash & Oath — explained playtest results</title><style>'''+css+'''</style></head><body><header><div class="eyebrow">ASH & OATH · v0.16 PLAYTEST REPORT</div><h1>What did we test?<br>What do the results mean?</h1><p>Plain-language team descriptions, each hero’s exact abilities and all 18 trial results. This is a clearer presentation of the recorded tests; no game rules or results were changed for this report.</p><a class="download" download href="'''+XLSX_NAME+'''">Download the Excel workbook (.xlsx)</a><a class="secondary" href="https://lordtoff.github.io/Godot-Game-Template/?v=0.16">Play the game</a></header><main><nav class="tabs" aria-label="Report sections" role="tablist">'''+''.join(f'<button id="tab-{key}" role="tab" aria-controls="{key}" aria-selected="{"true" if key=="overview" else "false"}" data-tab="{key}">{label}</button>' for key,label in [('overview','1 · Results explained'),('teams','2 · Exact teams'),('glossary','3 · Ability language'),('details','4 · Detailed results'),('method','5 · Method & fixes')])+'''</nav><section id="overview" class="panel" role="tabpanel" aria-labelledby="tab-overview"><div class="cards"><div class="metric"><strong>7,200</strong><span>Battle runs: 3,600 before + 3,600 after</span></div><div class="metric"><strong>200</strong><span>Fights for each team / movement setting</span></div><div class="metric"><strong>0</strong><span>Stalled fights in either version</span></div></div><article class="paper"><h2>First: what were “Numeric attacks”?</h2><p>These are <strong>attacks that roll a separate die to determine damage</strong>. That die is called the Numeric die. Its six sides are <strong>2, 2, 1, 1, 1, 0</strong>: 33.3% base 2, 50% base 1 and 16.7% base 0. Modifiers can change the final value. For example, Strike Numeric rolling 2 starts with 2 damage before Block and modifiers. Basic Strike instead has a fixed base damage of 1.</p><p class="callout">The team is now labelled <strong>More attacks with rolled damage</strong>. Each hero keeps four Basic Strike faces and equips two more attack faces, replacing one Step and one Focus. It is a choice of bonus abilities, not a character class or a different Numeric die. See <button data-goto="teams">Exact teams</button> for each hero’s two abilities and what they do.</p><h2>Player win rate</h2><p>Each cell shows the percentage of 200 fights the players won, with the player and boss win counts underneath. Example: <strong>99 player wins / 200 fights = 49.5%</strong>.</p><div class="scroll"><table><thead><tr><th scope="col">Team / chosen bonus style</th><th scope="col">Blank movement OFF</th><th scope="col">One Blank → Move 1</th><th scope="col">One Blank → Move 2</th></tr></thead><tbody>'''+summary_rows+'''</tbody></table></div><p class="muted">Movement ON permits at most one conversion per hero’s own turn, including full recovery turns. It spends a rolled Action-die Blank. A Numeric roll of zero cannot become movement.</p></article><article class="paper"><h2>Compare the movement advantage</h2><div class="legend">'''+''.join(f'<span><i style="background:{c}"></i>{e(m)}</span>' for c,m in zip(COLORS,SHORTMODES))+'''</div>'''+charts+'''<p class="muted">Bar lengths use a common 0–100% scale. The numbers are player win rates.</p></article><article class="paper"><h2>What needs attention?</h2><p><strong>Blank movement has a large difficulty effect.</strong> Random bonus teams won 49.5% with it OFF, 83.0% at Move 1 and 89.0% at Move 2. It should be treated as a substantial optional advantage.</p><p><strong>The attack-heavy kit wins more often than the support kit under this bot.</strong> With movement OFF: 79% versus 40%. Whole-team comparisons cannot tell us which single ability needs a buff; the support strategy is also less optimized.</p><p><strong>No default HP or damage values were changed.</strong> The random-bonus / movement-OFF sample does not support a blanket boss HP reduction. Edge-case bugs were fixed; the exact win/loss counts stayed unchanged after those fixes.</p><p class="callout">These are fixed-strategy bot comparisons, not predicted human win rates. The before/after runs reuse the same 200 seeds per scenario. Read Method & fixes before drawing conclusions about one ability.</p></article></section><section id="teams" class="panel" role="tabpanel" aria-labelledby="tab-teams" hidden><article class="paper"><h2>What each hero actually equipped</h2><p>The three heroes start with the same basic dice. Each fixed bonus team replaces <strong>two starter faces per hero</strong> with its two chosen bonus designs. It does not add dice or extra sides. There are initially 12 non-Blank sides per hero, with at least two Blanks on each die.</p><label for="team-select">Choose a team</label><select id="team-select">'''+''.join(f'<option value="{key}">{e(label)}</option>' for key,(label,_,_) in TEAMS.items())+'''</select></article>'''+''.join(teamcards)+'''</section><section id="glossary" class="panel" role="tabpanel" aria-labelledby="tab-glossary" hidden><article class="paper"><h2>Ability and battle language</h2><dl>'''+glossary+'''</dl><h2>What the starting abilities do</h2><dl>'''+starting_guide+'''</dl></article></section><section id="details" class="panel" role="tabpanel" aria-labelledby="tab-details" hidden><article class="paper"><h2>All 18 results after the fixes</h2><p>Each row contains 200 fights. Average rounds includes both wins and losses. Boss HP in losses excludes wins. Downings are events, not unique dead heroes.</p><label for="result-select">Filter team</label><select id="result-select"><option value="all">All teams (18 rows)</option>'''+''.join(f'<option value="{key}">{e(label)}</option>' for key,(label,_,_) in TEAMS.items())+'''</select><p class="muted" id="row-count">Showing 18 scenarios</p><div class="scroll"><table class="result-table"><thead><tr>'''+''.join('<th>'+e(h)+'</th>' for h in ['Team','Blank setting','Player wins','Boss wins','Player win rate','Average rounds','Reached phase II','Boss HP in losses','Downing events','Stalls'])+'''</tr></thead><tbody>'''+result_rows+'''</tbody></table></div></article></section><section id="method" class="panel" role="tabpanel" aria-labelledby="tab-method" hidden><article class="paper"><h2>What changed and why</h2><div class="scroll"><table><thead><tr><th>Rule / ability</th><th>Problem</th><th>Fix</th></tr></thead><tbody>'''+fixrows+'''</tbody></table></div></article><article class="paper"><h2>Method and limits</h2>'''+method+'''<p>Source: <a href="Trial-results-v0.16.json">recorded before/after results</a>. The workbook includes all exact fixed dice layouts and all 600 reconstructed random hero draws.</p></article></section><footer>v0.16 · Recorded results preserved · Base settings retained · Workbook has filters, frozen headers, a comparison chart, exact abilities and full dice layouts.</footer></main><script>
function showTab(id){document.querySelectorAll('.panel').forEach(p=>p.hidden=p.id!==id);document.querySelectorAll('[data-tab]').forEach(b=>b.setAttribute('aria-selected',String(b.dataset.tab===id)));history.replaceState(null,'','#'+id);}
document.querySelectorAll('[data-tab]').forEach(b=>b.addEventListener('click',()=>showTab(b.dataset.tab)));
document.querySelectorAll('[data-goto]').forEach(b=>b.addEventListener('click',()=>{showTab(b.dataset.goto);document.querySelector('.tabs').scrollIntoView({behavior:'smooth'});}));
const team=document.querySelector('#team-select');function filterTeams(){document.querySelectorAll('.team').forEach(c=>c.hidden=c.dataset.kit!==team.value);}team.addEventListener('change',filterTeams);filterTeams();
const filter=document.querySelector('#result-select');filter.addEventListener('change',()=>{let n=0;document.querySelectorAll('.result-table tbody tr').forEach(r=>{r.hidden=filter.value!=='all'&&r.dataset.kit!==filter.value;if(!r.hidden)n++;});document.querySelector('#row-count').textContent='Showing '+n+' scenarios';});
const current=location.hash.slice(1);if(current&&document.getElementById(current)?.classList.contains('panel'))showTab(current);
document.querySelector('.tabs').addEventListener('keydown',e=>{if(!['ArrowLeft','ArrowRight','Home','End'].includes(e.key))return;const tabs=Array.from(document.querySelectorAll('[data-tab]'));let i=tabs.indexOf(document.activeElement);if(i<0)return;e.preventDefault();i=e.key==='Home'?0:e.key==='End'?tabs.length-1:(i+(e.key==='ArrowRight'?1:-1)+tabs.length)%tabs.length;tabs[i].focus();showTab(tabs[i].dataset.tab);});
</script></body></html>'''
# Correct bar geometry: the fill region shares one common width; labels sit outside it.
htmltext=htmltext.replace('.barline{position:relative;height:24px;margin:5px 0;padding-right:60px}', '.barline{position:relative;height:24px;margin:5px 60px 5px 0}').replace('max-width:calc(100% - 55px)', 'max-width:100%').replace('right:0;top:-2px;font-size:13px','right:-60px;top:-2px;font-size:13px')
(OUT/'playtest-report.html').write_text(htmltext)
(OUT/'Trial-results-v0.16.json').write_text(json.dumps(DATA,indent=2)+'\n')
print('Created',OUT/XLSX_NAME)
print('Created',OUT/'playtest-report.html')
