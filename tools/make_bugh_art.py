"""Original integer-grid pixel sprites for the Cocoon Regent and its brood."""
from PIL import Image, ImageDraw
from pathlib import Path
OUT=Path(__file__).resolve().parents[1]/'prototype/assets'
for phase in (1,2):
 im=Image.new('RGBA',(32,32));d=ImageDraw.Draw(im)
 ink='#292735';shell='#686176' if phase==1 else '#985d74';light='#c1a9b5';silk='#e5d9b2';eye='#7ee3c0' if phase==1 else '#ffb17c'
 # Six jointed insect limbs frame a hanging silk abdomen and crownlike carapace.
 for side in (-1,1):
  for y in (11,17,23):
   d.line([(16+side*7,y),(16+side*12,y-3),(16+side*14,y+3)],fill=ink,width=3)
   d.line([(16+side*8,y),(16+side*12,y-2),(16+side*13,y+3)],fill=light,width=1)
 d.ellipse((7,11,25,30),fill=ink);d.ellipse((9,13,23,28),fill=silk)
 for y in (15,18,21,24):d.line([(10,y),(16,y+2),(22,y)],fill=shell)
 d.polygon([(8,12),(10,5),(12,8),(16,1),(20,8),(23,5),(25,13),(21,18),(11,18)],fill=ink)
 d.polygon([(10,12),(12,8),(14,10),(16,4),(19,10),(22,8),(23,12),(20,16),(12,16)],fill=shell)
 d.rectangle((12,11,14,12),fill=eye);d.rectangle((19,11,21,12),fill=eye)
 d.line([(14,15),(16,17),(19,15)],fill=silk)
 if phase==2:
  for x,y in ((10,20),(20,24),(14,27)):d.line([(x,y),(x+2,y-2),(x+1,y+2)],fill='#c85e83')
  d.polygon([(15,21),(18,19),(20,23),(17,25)],fill=eye)
 im.save(OUT/('pixel_bugh.png' if phase==1 else 'pixel_bugh_phase2.png'))
for kind in ('cocoon','mite','friendly_nugh'):
 sheet=Image.new('RGBA',(32,16))
 for frame in (0,1):
  im=Image.new('RGBA',(16,16));d=ImageDraw.Draw(im)
  if kind=='cocoon':
   d.line([(8,0),(8,4)],fill='#c1a9b5');d.ellipse((3,3,12,15),fill='#342d40');d.ellipse((4,4,11,14),fill='#d3c7a9')
   for y in (6,9,12):d.line([(4,y),(8,y+1),(11,y)],fill='#8f7896')
   d.point((7+frame,8),fill='#706278')
  elif kind=='mite':
   for side in (-1,1):
    for y in (6,9,12):d.line([(8+side*3,y),(8+side*6,y+frame-1)],fill='#b2a1b5')
   d.ellipse((4,3,11,14),fill='#302939');d.ellipse((5,5,10,13),fill='#8f7690');d.rectangle((5,3,10,7),fill='#c6b99e');d.point((6,5),fill='#df678b');d.point((9,5),fill='#df678b')
  else:
   d.line([(2,12),(5,10),(8,12),(12,10),(12,5)],fill='#223e43',width=5);d.line([(2,12),(5,10),(8,12),(12,10),(12,5)],fill='#76d7b5',width=3)
   d.rectangle((9,2+frame,14,7+frame),fill='#b7f0ce');d.point((10,4+frame),fill='#203442');d.point((13,4+frame),fill='#203442');d.line([(11,6+frame),(12,6+frame)],fill='#448875')
  sheet.paste(im,(frame*16,0))
 sheet.save(OUT/('pixel_'+kind+'.png'))
print('Wrote five original pixel sprite sheets to',OUT)
