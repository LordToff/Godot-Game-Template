from PIL import Image, ImageDraw
from pathlib import Path
out=Path(__file__).resolve().parents[1]/'prototype/assets'
for phase in [1,2]:
 im=Image.new('RGBA',(32,32));d=ImageDraw.Draw(im)
 dark='#252532';cloak='#49475e' if phase==1 else '#693d64';mid='#6c7781' if phase==1 else '#aa6b9f';worm='#b5c5a2' if phase==1 else '#dfc9ad';light='#e5e0ba';eye='#8eedc3' if phase==1 else '#ff8a94'
 d.rectangle((8,24,23,29),fill=dark);d.rectangle((10,28,13,30),fill='#282c37');d.rectangle((20,28,24,30),fill='#282c37')
 d.polygon([(11,9),(23,10),(27,27),(6,27)],fill=dark);d.polygon([(12,12),(22,12),(24,26),(8,26)],fill=cloak)
 d.rectangle((11,19,13,25),fill=mid);d.rectangle((20,17,21,26),fill=mid)
 d.rectangle((11,4,22,13),fill=dark);d.rectangle((13,2,20,4),fill=dark);d.rectangle((10,6,12,10),fill=cloak);d.rectangle((21,5,23,13),fill=cloak)
 d.rectangle((13,5,20,13),fill=worm);d.rectangle((14,9,19,13),fill='#171d25');d.rectangle((13,6,15,7),fill=eye);d.rectangle((18,6,20,7),fill=eye)
 d.point((14,10),fill=light);d.point((19,10),fill=light);d.rectangle((15,13,18,14),fill=light)
 # Three curled worms form the summoner's staff, arm and lower mantle.
 for points in [[(5,20),(3,16),(3,9),(5,7),(7,9),(7,13)],[(25,22),(28,19),(29,13),(27,11),(25,13)],[(9,23),(12,21),(16,22),(18,26),(23,25)]]:
  d.line(points,fill=dark,width=5);d.line(points,fill=worm,width=3)
  x,y=points[-1];d.rectangle((x-1,y-1,x+1,y+2),fill='#24202b');d.point((x,y-1),fill=light)
 d.rectangle((14,17,18,18),fill=eye);d.point((14,19),fill=eye)
 if phase==2:
  for x,y in [(8,2),(24,3),(2,20),(29,24),(13,0)]:d.rectangle((x,y,x+1,y+1),fill=eye)
 im.save(out/('pixel_nugh.png' if phase==1 else 'pixel_nugh_phase2.png'))
sheet=Image.new('RGBA',(32,16))
for f in range(2):
 im=Image.new('RGBA',(16,16));d=ImageDraw.Draw(im)
 d.ellipse((1,10,14,14),fill='#222b32');d.line([(3,12),(2,9),(4,7),(7,8),(9,12),(12,10),(12,4)],fill='#25342e',width=5)
 d.line([(3,12),(2,9),(4,7),(7,8),(9,12),(12,10),(12,4)],fill='#b4c5a4',width=3)
 d.rectangle((9,1,14,7+f),fill='#d8ddbc');d.rectangle((10,3,13,6+f),fill='#252331');d.point((10,2),fill='#ff8a94');d.point((13,2),fill='#ff8a94');d.point((11,3),fill='#fcf0cf');d.point((12,6+f),fill='#fcf0cf')
 sheet.paste(im,(f*16,0))
sheet.save(out/'pixel_screaming_worm.png')
print('Original pixel sprites generated:',out)
