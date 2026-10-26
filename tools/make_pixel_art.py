"""Original pixel sprites and arena tiles. No source-image conversion or smoothing."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageColor
OUT = Path(__file__).resolve().parents[1] / 'prototype/assets'
P = {'.':(0,0,0,0),'o':'#111522','s':'#293047','m':'#495069','l':'#8994a8','w':'#e9dec5','f':'#c98e67','h':'#7a4a3a','t':'#337d7c','T':'#7ad5c0','p':'#6e508b','P':'#bda0da','g':'#b28243','G':'#f0c36b','r':'#944c50','R':'#e28a69'}
P = {k:ImageColor.getcolor(v,"RGBA") if isinstance(v,str) else v for k,v in P.items()}
def stamp(im,rows,at,palette=P):
 for y,row in enumerate(rows):
  for x,c in enumerate(row):
   if c != '.': im.putpixel((at[0]+x,at[1]+y),palette[c])
# The 16 x 24 heroes use distinct equipment and silhouettes.
vesper=[
'......oooo......','.....otTTto.....','....otTttTto....','...ottttttTto...','...otowwwoTto...',
'...otowfwoTto...','....towfwoTo....','....ottwtTto....','.....ottTto.....','...oottttToo..G.',
'..otttTtttttoGTG','..ofttTttttto.G.','..offtTtttfho.h.','...ootTttfoo..h.',
'....otTtttoo..h.','....otTtttto..h.','...ottTttttto.h.','...ottTttttto.h.',
'..ottTtttttttoh.','..otTTtttttttoh.','..ooooooooooo.h.','....ossosso...h.','....ossoosso....','....ooooooo.....']
rook=[
'.....oooooo.....','....osllllso....','...osllmmllso...','...osllmmllso...','...oloooooolo...',
'...omowffwomo...','...omowffwomo...','....oommmoo.....','...ooPmmPooo....','..olllPPllllo...',
'.olllllPPllllo..','.olmmllPPllmmlo.','.ofmollPPllomfo.','..ooosllllsooo..',
'...oosllllsoo...','..oplolllloppo..','..opPolllloPpo..','..opPooooooPpo..',
'...opPooooPpo...','....olsooslo....','....olsooslo....','...ollsoosllo...','...ossoooosso...','...oooo..oooo...']
wren=[
'.....oooooo.....','....oggggggo....','...ogGggggggo...','...ogghhhhgggo..','...ogohffhogo...',
'...ogohffhogo...','....gohffhog....','....ogGgggo.....','...ooGGGggoo....','..ogggGgggggo...',
'..ofggGgggfho.o.','..offgGggfho.om.','...oogGggoo..om.','....ogGggo...o.m',
'....ogGgggo..o.m','...oggggggo..o.m','...ogggggggo.o.m','...oggoooggo.om.',
'....ohhohho..om.','....ohhohho...o.','....ohhohho.....','...ohhhohhho....','...ossoosso.....','...ooooooo......']
# Three armoured knights; distinct tabards, plumes and equipment share a clear helmet silhouette.
knight=[
'......ppp.......','.....opPpo......','.....oppo.......','....ooooooo.....','...oslllllso....',
'...ollmmlllo....','...oloooooolo...','...olwoolwolo...','....olmmllo.....','....oommmoo.....',
'..ooolPPloloo...','..olllPPllmlo...','..olmlPPllmlo...', '..olmlPPllmlo...',
'...oolPPlloo....','....olPPllo.....','...oplPPllpo....','...opPllPppo....',
'....oloooolo....','....olsooslo....','....olsooslo....','...ollsoosllo...','...ommooommo....','...oooo.oooo....']
units=Image.new('RGBA',(64,64))
for i,(dark,bright) in enumerate([('t','T'),('p','P'),('g','G')]):
 palette=dict(P);palette['p']=P[dark];palette['P']=P[bright]
 at=((i%2)*32+8,(i//2)*32+4);stamp(units,knight,at,palette)
 d=ImageDraw.Draw(units);ox,oy=at
 # Steel sword and coloured kite shield, all drawn on the source pixel grid.
 d.line((ox+15,oy+8,ox+15,oy+19),fill=P['l']);d.line((ox+13,oy+17,ox+17,oy+17),fill=P['g'])
 d.rectangle((ox-1,oy+11,ox+4,oy+18),fill=P['o']);d.rectangle((ox,oy+12,ox+3,oy+17),fill=P[dark]);d.line((ox+1,oy+12,ox+1,oy+18),fill=P[bright]);d.point((ox+2,oy+19),fill=P['o'])
# 32 x 32 skeletal monarch, hand-placed pixel geometry.
boss=Image.new('RGBA',(32,32));d=ImageDraw.Draw(boss)
def rect(box,c):d.rectangle(box,fill=P[c])
for x in [4,25]:
 rect((x,1,x+2,9),'o');rect((x+1,2,x+1,7),'g')
rect((7,5,24,11),'o');rect((9,3,11,7),'g');rect((15,1,17,7),'G');rect((21,3,23,7),'g');rect((9,6,22,8),'g')
rect((9,9,22,20),'o');rect((11,9,20,18),'w');rect((10,11,21,15),'w')
rect((11,12,14,14),'o');rect((17,12,20,14),'o');rect((12,13,13,13),'G');rect((18,13,19,13),'G')
rect((15,15,16,16),'h');rect((12,18,19,19),'l')
for x in range(13,20,2):rect((x,17,x,19),'o')
d.polygon([(7,19),(11,18),(16,23),(21,18),(25,19),(29,31),(3,31)],fill=P['o'])
d.polygon([(8,20),(11,20),(15,24),(13,30),(5,30)],fill=P['p'])
d.polygon([(23,20),(20,20),(17,24),(19,30),(27,30)],fill=P['p'])
rect((15,22,16,30),'w')
for y in [23,26,29]:rect((12,y,19,y),'l')
rect((2,18,5,27),'o');rect((3,19,4,25),'w');rect((26,18,29,27),'o');rect((27,19,28,25),'w')
units.alpha_composite(boss,(32,32));units.save(OUT/'pixel_units.png')
# Clean 16 x 16 head icons, separately drawn for small UI panels.
head=[
'......ppp.......','.....opPpo......','.....oppo.......','....ooooooo.....','...oslllllso....',
'..osllmmlllso...','..olllmmllllo...','..oloooooooolo..','..olwoollwoolo..','..olmmmmmmmlo...',
'...olmmmmmlo....','....ollllo......','....oommoo......','...olPPPPlo.....','..ollPPPPllo....','..oooooooooo....']
portraits=Image.new('RGBA',(32,32))
for i,(dark,bright) in enumerate([('t','T'),('p','P'),('g','G')]):
 palette=dict(P);palette['p']=P[dark];palette['P']=P[bright];stamp(portraits,head,((i%2)*16,(i//2)*16),palette)
stamp(portraits,[
'..o..........o..','..ogo..G...ogo..','...ogoGGG.ogo...','....oggggggo....','....owwwwwo.....','...owwwwwwwo....','...owooowoowo...','...owGowGowo....','...owwwwwwwo....','....owhhwwo.....','....owowowo.....','....owwwwo......','...opwllwpo.....','..opPpwwpPpo....','..oooooooooo....','................'],(16,16))
portraits.save(OUT/'pixel_portraits.png')
# 9 x 9 floor: 19 source pixels per game cell, displayed at exactly 4x.
arena=Image.new('RGBA',(179,179),'#111522');d=ImageDraw.Draw(arena)
for y in range(9):
 for x in range(9):
  left=4+x*19;top=4+y*19
  base='#29313e' if (x+y)%2 else '#2d3542';d.rectangle((left,top,left+18,top+18),fill=base)
  d.line((left,top,left+18,top),fill='#414957');d.line((left,top,left,top+18),fill='#39414f')
  d.line((left+1,top+18,left+18,top+18),fill='#202634');d.line((left+18,top+1,left+18,top+18),fill='#202634')
  if (x*3+y)%5==0:
   d.line([(left+11,top+1),(left+11,top+4),(left+9,top+4),(left+9,top+7)],fill='#202634')
  if (x+y*3)%7==0:
   d.rectangle((left+3,top+13,left+4,top+14),fill='#3c5d57')
# Border and sparse braziers remain outside all playable cells.
for n in range(0,179,8):
 d.rectangle((n,0,n+6,2),fill='#495069');d.rectangle((n,176,n+6,178),fill='#495069')
 d.rectangle((0,n,2,n+6),fill='#495069');d.rectangle((176,n,178,n+6),fill='#495069')
for x,y in [(1,1),(174,1),(1,174),(174,174)]:
 d.rectangle((x,y,x+2,y+2),fill='#b28243');d.point((x+1,y),fill='#f0c36b')
# A quiet geometric seal in the central 3x3 cells.
d.rectangle((62,62,116,116),outline='#4b4d55');d.line((89,68,89,110),fill='#4b4d55');d.line((68,89,110,89),fill='#4b4d55')
arena.save(OUT/'pixel_arena.png')
print('Wrote 179x179 arena, 64x64 units, 32x32 icons.')
