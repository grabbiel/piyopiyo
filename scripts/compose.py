import json,math,wave,struct,hashlib
from pathlib import Path
from datetime import datetime,timezone
from music21 import stream,note,tempo,instrument
root=Path(__file__).resolve().parents[1];out=root/'PiyoPiyo/PiyoPiyoCore/Sources/PiyoPiyoCore/Resources';out.mkdir(parents=True,exist_ok=True)
patterns={'focus':(76,[60,67,64,71,69,64,62,67]),'celebration':(144,[72,76,79,74,81,79,76,84]),'reflection':(68,[67,64,62,69,65,62,60,64]),'transition':(108,[60,64,69,67,74,71])}
ledger=[]
for name,(bpm,pitches) in patterns.items():
 score=stream.Stream();score.append(instrument.Piano());score.append(tempo.MetronomeMark(number=bpm));samples=[];rate=22050;length=60/bpm
 for pitch in pitches:
  score.append(note.Note(pitch,quarterLength=1));freq=440*2**((pitch-69)/12)
  for i in range(int(rate*length)):
   t=i/rate;env=min(1,t/0.012)*math.exp(-t*5/length);value=0.14*env*(math.sin(2*math.pi*freq*t)+0.3*math.sin(4*math.pi*freq*t)+0.08*math.sin(6*math.pi*freq*t));samples.append(int(32767*value))
 score.write('midi',fp=str(out/(name+'.mid')))
 with wave.open(str(out/(name+'.wav')),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes(struct.pack('<'+'h'*len(samples),*samples))
 ledger.append({'id':'original-'+name,'kind':'audio','title':'Piyo / '+name,'url':'local:scripts/compose.py','accessedAt':datetime.now(timezone.utc).isoformat(),'sha256':hashlib.sha256((out/(name+'.wav')).read_bytes()).hexdigest(),'bpm':bpm,'license':'Original generated composition; project-owned','redistributable':True,'releaseInclusion':'bundled','notes':'Original note sequence, additive synthesis; no sampled recordings.'})
rate=22050;samples=[]
for i in range(rate*3):
 t=i/rate;local=t%1;env=min(1,local/.01)*max(0,1-local/.18) if local<.18 else 0;samples.append(int(32767*.18*env*math.sin(2*math.pi*660*t)))
with wave.open(str(out/'pulses.wav'),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes(struct.pack('<'+'h'*len(samples),*samples))
ledger.append({'id':'original-audio','kind':'audio','title':'Three pulse signal','url':'local:scripts/compose.py','accessedAt':datetime.now(timezone.utc).isoformat(),'sha256':hashlib.sha256((out/'pulses.wav').read_bytes()).hexdigest(),'license':'Original generated signal; project-owned','redistributable':True,'releaseInclusion':'bundled'})
(root/'references/original-audio.json').write_text(json.dumps(ledger,indent=2)+'\n')
print('Composed four original MIDI/WAV motifs and a three-pulse exercise.')
