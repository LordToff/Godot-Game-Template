"""Original small pixel texture and borders for Ash & Oath's interface."""
from PIL import Image,ImageDraw
from pathlib import Path
import random
random.seed(23)
im=Image.new('RGB',(360,225),'#0d1721');d=ImageDraw.Draw(im)
for y in range(225):
 for x in range(360):
  vignette=max(abs(x-180)/180,abs(y-112)/112)
  n=random.choice([-1,0,0,0,1]);im.putpixel((x,y),(int(15-4*vignette)+n,int(25-6*vignette)+n,int(35-7*vignette)+n))
# Masonry is confined to the outer margins; the reading area stays quiet.
for y in range(0,225,19):
 for x in range(-12 if (y//19)%2 else 0,360,32):
  if x<12 or x>327:d.rectangle((x,y,x+30,y+17),outline='#1b2730')
d.rectangle((5,5,354,219),outline='#534b3b');d.rectangle((7,7,352,217),outline='#25323b')
for x,y,sx,sy in [(8,8,1,1),(351,8,-1,1),(8,216,1,-1),(351,216,-1,-1)]:
 d.line([(x+sx*23,y),(x,y),(x,y+sy*23)],fill='#9a8055',width=1)
 d.rectangle((x+sx*4-1,y+sy*4-1,x+sx*4+1,y+sy*4+1),fill='#a38b60')
# A faint die-shaped seal behind the equipment preview.
d.polygon([(270,57),(307,78),(307,121),(270,143),(233,121),(233,78)],outline='#27343a')
d.line([(270,57),(270,100),(233,121)],fill='#27343a');d.line([(270,100),(307,121)],fill='#27343a')
for x,y in [(24,211),(336,211),(24,14),(336,14)]:d.line((x-7,y,x+7,y),fill='#4c4b40');d.point((x,y),fill='#d4ae6a')
out=Path(__file__).resolve().parents[1]/'prototype/assets/pixel_chamber.png';im.save(out)
print(out)
