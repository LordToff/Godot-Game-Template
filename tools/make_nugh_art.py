from PIL import Image, ImageDraw
from pathlib import Path
out=Path(__file__).resolve().parents[1]/'prototype/assets'
for phase in [1,2]:
 im=Image.new('RGBA',(32,32));d=ImageDraw.Draw(im)
 outline='#302a35';shadow='#656a56' if phase==1 else '#80596b';skin='#aab58d' if phase==1 else '#cfac9c';light='#d8d1ab';eye='#ebe7bd' if phase==1 else '#ff858e'
 # A heavy segmented worm body, coiled tail and exposed human upper body. No robe/staff.
 d.ellipse((3,15,29,30),fill=outline);d.ellipse((5,16,28,28),fill=shadow)
 d.ellipse((8,17,27,27),fill=skin);d.ellipse((12,19,25,25),fill=shadow)
 d.arc((10,18,26,26),0,300,fill=light,width=2)
 d.polygon([(7,24),(6,28),(2,29),(1,27),(3,25),(4,22)],fill=outline);d.line([(3,27),(7,26),(10,27)],fill=skin,width=3)
 for y in [18,21,24]:d.line([(8,y),(11,y+1),(18,y+1),(22,y)],fill=shadow,width=1)
 d.polygon([(11,8),(21,8),(24,16),(22,22),(12,24),(8,19),(8,13)],fill=outline)
 d.polygon([(12,9),(20,9),(22,15),(21,20),(13,22),(10,18),(10,13)],fill=skin)
 d.rectangle((12,12,14,16),fill=light);d.rectangle((18,12,20,16),fill=light);d.line([(16,11),(16,20)],fill=shadow,width=1)
 d.line([(12,18),(15,19),(19,18)],fill=shadow,width=1)
 # Long human arms ending in clawed hands.
 for pts in [[(11,11),(6,12),(4,17),(3,20)],[(21,11),(25,13),(27,17),(28,21)]]:
  d.line(pts,fill=outline,width=5);d.line(pts,fill=skin,width=3)
  x,y=pts[-1]
  d.line([(x-2,y),(x-2,y+2)],fill=light);d.line([(x,y),(x,y+3)],fill=light);d.line([(x+2,y),(x+2,y+2)],fill=light)
 # Distorted human face: brow, two eyes, nose, elongated screaming jaw.
 d.rectangle((11,1,21,9),fill=outline);d.rectangle((13,0,19,1),fill=outline);d.rectangle((12,2,20,8),fill=skin)
 d.rectangle((13,3,15,4),fill=outline);d.rectangle((18,3,20,4),fill=outline);d.point((14,4),fill=eye);d.point((19,4),fill=eye)
 d.line([(16,4),(16,6)],fill=light);d.rectangle((14,7,19,10),fill=outline);d.rectangle((15,7,18,7),fill=light);d.point((16,10),fill=light)
 if phase==2:
  d.line([(11,13),(13,15),(11,18)],fill='#973f59');d.line([(20,17),(18,20),(21,22)],fill='#973f59')
  for x,y in [(7,18),(25,21),(20,27)]:d.polygon([(x,y),(x-1,y-4),(x+2,y)],fill=light)
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
