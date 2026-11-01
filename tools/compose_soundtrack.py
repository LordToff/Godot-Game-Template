"""Original Ash & Oath score. Deterministic synthesis; no external samples.
Requires numpy and ffmpeg. Ogg masters are checked in for normal development.
"""
from pathlib import Path
import numpy as np, subprocess, wave, tempfile
RATE=22050
OUT=Path(__file__).resolve().parents[1]/'prototype/assets/music'
OUT.mkdir(parents=True,exist_ok=True)
rng=np.random.default_rng(2723)
def hz(m):return 440*2**((m-69)/12)
def voice(m,duration,kind):
 t=np.arange(int(duration*RATE))/RATE;f=hz(m)
 if kind=='bell':
  v=sum(a*np.sin(2*np.pi*f*r*t)*np.exp(-t*k) for a,r,k in [(1,1,2.2),(.35,2.01,4),(.16,3.98,7)])*.24
 elif kind=='pluck':
  v=sum(np.sin(2*np.pi*f*h*t)/h**1.5 for h in range(1,7))*np.exp(-t*4.2)*.22
 elif kind=='bass':v=(np.sin(2*np.pi*f*t)+.2*np.sin(2*np.pi*f*2*t))*np.exp(-t*1.5)*.32
 elif kind=='pad':
  env=np.minimum(t/.35,1)*np.minimum((duration-t)/.65,1)
  v=(np.sin(2*np.pi*f*.999*t)+np.sin(2*np.pi*f*1.001*t)+.25*np.sin(2*np.pi*f*2*t))*env*.045
 elif kind=='kick':v=np.sin(2*np.pi*(48*t+42*(1-np.exp(-t*20))/20))*np.exp(-t*15)*.6
 elif kind=='tom':v=np.sin(2*np.pi*(f*t+20*(1-np.exp(-t*15))/15))*np.exp(-t*10)*.28
 elif kind=='hat':
  n=rng.normal(0,1,len(t));v=(n-np.roll(n,1))*np.exp(-t*40)*.035
 else:v=np.zeros(len(t))
 v*=np.minimum(t/.008,1)*np.minimum((duration-t)/.018,1)
 return v
def compose(name,bpm,intensity):
 beat=60/bpm;bars=16;length=bars*4*beat;total=round(length*RATE)
 song=np.zeros((total,2),np.float64)
 def add(at,m,d,kind,gain=1,pan=0):
  v=voice(m,d,kind)*gain;start=round(at*RATE);idx=(start+np.arange(len(v)))%total
  song[idx,0]+=v*np.sqrt((1-pan)/2);song[idx,1]+=v*np.sqrt((1+pan)/2)
 # D minor / Bb / F / C, then G minor / Bb / A / A: a resolving 16-bar phrase.
 chords=[(38,50,53,57),(34,46,50,53),(41,53,57,60),(36,48,52,55),(43,55,58,62),(34,46,50,53),(33,45,49,52),(33,45,49,57)]*2
 melody=[[74,77,76,69],[70,74,77,74],[72,77,81,79],[76,72,67,69],[74,79,77,74],[77,74,70,69],[73,76,81,76],[73,69,76,73]]
 for bar,chord in enumerate(chords):
  at=bar*4*beat
  for i,m in enumerate(chord[1:]):add(at,m,4*beat+.4,'pad',1,-.45+i*.45)
  for step in range(8):
   tone=chord[1:][[0,1,2,1,0,2,1,2][step]]+(12 if step==6 and bar%4==3 else 0)
   add(at+step*.5*beat,tone,1.1,'pluck',.48 if intensity==0 else .68,(-1)**step*.25)
  for j,m in enumerate(melody[bar%8]):
   if intensity or j in [0,2]:add(at+(j+.25)*beat,m-(12 if intensity==2 and bar<8 else 0),1.8,'bell',.55 if intensity==0 else .7,(-1)**j*.3)
  for step in ([0,2] if intensity==0 else [0,1.5,2,3.5]):add(at+step*beat,chord[0],1.4,'bass',.5 if intensity==0 else .8)
  if intensity:
   for step in [0,2]:add(at+step*beat,36,.4,'kick',.55 if intensity==1 else .75)
   for step in [1,3]:add(at+step*beat,45,.5,'tom',.5,(-1)**step*.2)
   for step in np.arange(.5,4,.5):add(at+step*beat,60,.15,'hat',.8,(-1)**int(step*2)*.4)
   if intensity==2:
    for step in [2.5,3.25,3.75]:add(at+step*beat,50,.35,'tom',.45,.2)
 # Stereo room echoes wrap at the musical seam, keeping loop tails intact.
 dry=song.copy()
 for delay,gain in [(.18,.18),(.37,.11),(.61,.065)]:song+=np.roll(dry[:,::-1],round(delay*RATE),axis=0)*gain
 song=np.tanh(song*.9);song*=.78/max(np.max(np.abs(song)),.001)
 pcm=(song*32767).astype('<i2')
 with tempfile.NamedTemporaryFile(suffix='.wav') as f:
  with wave.open(f.name,'wb') as w:w.setnchannels(2);w.setsampwidth(2);w.setframerate(RATE);w.writeframes(pcm.tobytes())
  subprocess.run(['ffmpeg','-y','-loglevel','error','-i',f.name,'-af','loudnorm=I=-19:TP=-2:LRA=8','-ar','44100','-c:a','libvorbis','-q:a','4',str(OUT/(name+'.ogg'))],check=True)
 print(name,round(length,2),'seconds',flush=True)
for args in [('embers_at_the_forge',76,0),('oathbound',100,1),('the_crown_splinters',112,2)]:compose(*args)
