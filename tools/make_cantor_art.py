from pathlib import Path
from PIL import Image, ImageDraw
out=Path(__file__).resolve().parents[1]/'prototype/assets'
for phase in [1,2]:
 im=Image.new('RGBA',(32,32));d=ImageDraw.Draw(im)
 dark='#252e3c';shade='#705a43' if phase==1 else '#66567d';bronze='#b58e54' if phase==1 else '#a19bb2';gold='#e5c681' if phase==1 else '#eee1b4';light='#64d5df' if phase==1 else '#a9f0ef'
 # Cast-metal handle, bell silhouette and a dark sound chamber.
 d.rectangle((12,0,19,2),fill=dark);d.rectangle((13,1,18,3),fill=gold)
 d.polygon([(11,3),(20,3),(23,7),(24,17),(28,23),(28,25),(3,25),(3,23),(7,17),(8,7)],fill=dark)
 d.polygon([(11,5),(20,5),(22,9),(22,17),(25,22),(6,22),(9,17),(9,9)],fill=bronze)
 d.line([(11,6),(10,13),(10,19)],fill=gold,width=2);d.line([(20,7),(21,13),(21,19)],fill=shade,width=2)
 d.rectangle((5,23,26,24),fill=gold);d.rectangle((8,25,23,26),fill=shade)
 d.polygon([(12,10),(19,10),(21,20),(10,20)],fill=dark)
 # A suspended clapper / crystal instead of a human torso.
 d.rectangle((15,8,16,15),fill=gold);d.polygon([(15,14),(18,17),(16,21),(13,18)],fill=light);d.point((15,16),fill='#f1ffff')
 d.rectangle((12,6,19,7),fill=shade);d.point((12,6),fill=light);d.point((19,6),fill=light)
 # Four low articulated legs; one hammer arm and one tuning-fork arm.
 for points in [[(7,24),(5,28),(1,29)],[(11,25),(10,29),(7,30)],[(21,25),(22,29),(25,30)],[(25,24),(27,28),(30,29)]]:
  d.line(points,fill=dark,width=3);d.line(points,fill=bronze,width=1)
 d.line([(8,11),(4,10),(2,14),(3,18)],fill=dark,width=4);d.line([(8,11),(4,11),(3,15),(4,18)],fill=gold,width=2)
 d.rectangle((1,17,6,19),fill=shade);d.rectangle((1,17,5,17),fill=gold)
 d.line([(23,11),(27,10),(29,15)],fill=dark,width=4);d.line([(23,11),(27,11),(28,15)],fill=bronze,width=2)
 d.line([(29,17),(29,9)],fill=gold);d.line([(27,9),(31,9)],fill=gold);d.line([(27,9),(27,5)],fill=light);d.line([(31,9),(31,5)],fill=light)
 if phase==2:
  d.line([(11,4),(12,8),(10,11),(12,14),(10,18),(11,22)],fill=light)
  d.line([(20,5),(19,9),(22,12),(20,16),(23,21)],fill=light)
  for x,y in [(4,5),(24,1),(1,22)]:d.rectangle((x,y,x+1,y+1),fill=light)
 im.save(out/('pixel_cantor.png' if phase==1 else 'pixel_cantor_phase2.png'))
print('Original bell-reliquary sprites generated.')
