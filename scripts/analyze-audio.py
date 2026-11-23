import librosa,json,hashlib
from pathlib import Path
from datetime import datetime,timezone
path=Path('references/audio/hyouka-preview.mp3');y,sr=librosa.load(path)
tempo,_=librosa.beat.beat_track(y=y,sr=sr);bpm=float(tempo[0])
result={'id':'hyouka-official-preview','kind':'audio_reference','title':'Hyouka Part One official trailer, 20-second reference excerpt','url':'https://www.youtube.com/watch?v=KbIUra_o2wc','accessedAt':datetime.now(timezone.utc).isoformat(),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'method':'yt-dlp; public official trailer; first 20 seconds','status':'acquired','redistributable':False,'releaseInclusion':False,'analysis':{'tempoBpm':bpm,'spectralCentroidHz':float(librosa.feature.spectral_centroid(y=y,sr=sr).mean()),'durationSeconds':float(librosa.get_duration(y=y,sr=sr)),'bucket':'focus/reflection' if bpm<90 else 'transition' if bpm<=130 else 'celebration','limitation':'Trailer dialogue and effects affect beat estimates; centroid is timbral brightness, not a validated valence measure.'}}
Path('references/audio-analysis.json').write_text(json.dumps(result,indent=2)+'\n')
ledger=json.loads(Path('provenance.json').read_text());ledger=[x for x in ledger if x['id']!=result['id']];ledger.append(result)
Path('provenance.json').write_text(json.dumps(ledger,indent=2)+'\n')
print('Analyzed 20-second reference:',round(bpm,1),'BPM')
