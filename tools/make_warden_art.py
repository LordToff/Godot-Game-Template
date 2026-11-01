"""Original 32-pixel Iron Warden sprites: steel, tower shield and hammer."""
from PIL import Image,ImageDraw
from pathlib import Path
out=Path(__file__).resolve().parents[1]/'prototype/assets'
for phase in [1,2]:
 im=Image.new('RGBA',(32,32));d=ImageDraw.Draw(im)
 ink='#202733';dark='#465364';steel='#8997a2';light='#c6c9bd';gold='#d5b579';glow='#8cdbd4' if phase==1 else '#ff9567'
 d.rectangle((10,26,14,30),fill=ink);d.rectangle((18,26,22,30),fill=ink)
 d.rectangle((10,27,14,29),fill=steel);d.rectangle((18,27,23,29),fill=steel)
 d.polygon([(9,11),(22,11),(25,23),(21,28),(11,28),(7,22)],fill=ink)
 d.polygon([(11,12),(21,12),(23,22),(20,26),(12,26),(9,22)],fill=dark)
 d.polygon([(12,13),(20,13),(21,20),(16,24),(11,20)],fill=steel)
 d.line([(16,14),(16,23)],fill=light);d.rectangle((11,23,21,24),fill=gold)
 d.rectangle((10,3,22,12),fill=ink);d.rectangle((12,2,20,4),fill=ink)
 d.rectangle((11,5,21,10),fill=steel);d.rectangle((12,7,20,8),fill=ink)
 d.line([(14,7),(19,7)],fill=glow);d.line([(16,3),(16,5)],fill=gold)
 # Broad squared pauldrons, a readable tower shield and a heavy square hammer.
 d.rectangle((6,11,11,16),fill=ink);d.rectangle((7,12,10,15),fill=steel)
 d.rectangle((21,11,26,16),fill=ink);d.rectangle((22,12,25,15),fill=steel)
 d.polygon([(2,14),(11,14),(12,24),(7,29),(1,24)],fill=ink)
 d.polygon([(3,15),(10,15),(10,23),(7,26),(3,23)],fill=dark)
 d.line([(4,16),(9,16),(9,23),(7,25),(4,23),(4,16)],fill=gold)
 d.line([(7,18),(7,23)],fill=glow);d.line([(5,20),(9,20)],fill=glow)
 d.line([(25,15),(27,26)],fill=ink,width=3);d.line([(25,15),(27,26)],fill=gold)
 d.rectangle((23,7,31,13),fill=ink);d.rectangle((24,8,30,12),fill=steel)
 d.line([(25,8),(25,12)],fill=light);d.line([(29,8),(29,12)],fill=gold)
 if phase==2:
  for line in [[(12,14),(14,17),(12,19)],[(20,15),(18,18),(20,21)],[(24,9),(28,10),(26,12)]]:d.line(line,fill=glow)
  d.line([(12,4),(13,2),(15,3)],fill=glow);d.line([(19,3),(21,1),(22,4)],fill=glow)
 im.save(out/('pixel_bugh.png' if phase==1 else 'pixel_bugh_phase2.png'))
print('Original Iron Warden pixel sprites written')
