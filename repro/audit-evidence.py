from pathlib import Path
import json,re,hashlib,struct
r=Path('/Users/yashsingh/p/projects/latex-screenshots/Upstream-PR-repros')
base='766fc0e679059ea9fc412cb60f24b8102e5c3e5f';heads={'991':'bd6f647f3857479c3a80672d4afb79efe0ffcb11','994':'eb70edc1e48b0f1b09a0ff714314884e617a6e8e','995':'3be6e76a8a9292a487a8d1a04ae8d7611ddb3c16'}
checks=[];hashes={}
for pr,cases in {'991':['hard-break-width'],'994':['character-references'],'995':['breaks','markdown']}.items():
 for platform in ['iOS','Android']:
  for case in cases:
   pair=[]
   for variant in ['before','after']:
    stem=r/'Evidence'/pr/platform/f'{variant}-{case}';d=json.loads(stem.with_suffix('.json').read_text());a=stem.with_suffix('.a11y.txt').read_text();png=(r/d['imagePath']).read_bytes()
    assert d['sourceRevision']==(base if variant=='before' else heads[pr]),stem
    assert png[:8]==b'\x89PNG\r\n\x1a\n';assert hashlib.sha256(png).hexdigest()==d['screenshotSha256'];hashes.setdefault(pr,set()).add(d['appFixtureSha256'])
    if pr=='995': assert d['sourceRevision'][:7] in d['nativeResult']['revision']
    pair.append((d,a))
   before,after=pair
   if pr=='991':
    b=float(re.search(r'Native onLayout width: ([\d.]+)',before[1])[1]);f=float(re.search(r'Native onLayout width: ([\d.]+)',after[1])[1]);assert (b>250 and f<50) if platform=='iOS' else b==f
    detail=f'{b:.1f} pt -> {f:.1f} pt'+(' (regression control)' if platform=='Android' else '')
   elif pr=='994':
    for ch in ['©','é','α','😀']: assert ch not in before[1] and ch in after[1],(platform,ch)
    assert '&amp; and &#x1F600;' in before[1] and '&amp; and &#x1F600;' in after[1]
    assert '[1] stays text' in after[1]
    detail='Named and numeric symbols restored; code stays literal; encoded citation stays text.'
   else:
    b=before[0]['nativeResult'];f=after[0]['nativeResult']
    if case=='breaks': assert 'first<br>second' not in b['fullHtml'] and 'first<br>second' in f['fullHtml'];assert b['pasted']=='first second' and f['pasted']=='first\nsecond';detail='Native HTML import changes from one line to two.'
    else: assert b['payload']=='x_1' and f['payload']=='$x_1$';detail='Copied table-cell Markdown renders as a formula.'
   checks.append({'pr':int(pr),'platform':platform,'case':case,'result':'passed','detail':detail})
assert all(len(values)==1 for values in hashes.values()),hashes
assert len(list(r.glob('[0-9]*/*/*.png')))==16
assert len(list((r/'Evidence').glob('*/*/*.json')))==16
report={'base':base,'heads':heads,'sampleDirectory':'/Users/yashsingh/p/projects/enriched-markdown-repro','screenshotCount':16,'comparisonCount':8,'fixtureSha256ByPr':{pr:next(iter(values)) for pr,values in hashes.items()},'checks':checks,'notes':['Each after build uses only its own PR on the common upstream base.','PR #991 changes iOS only; Android captures are a regression control.','Clipboard tests use actual native exporters, system clipboard and platform HTML import.','HTML style attributes are hidden on screen; complete native HTML is saved in each JSON.','Evidence is local only. No screenshots have been uploaded.']}
previous=json.loads((r/'manifest.json').read_text()) if (r/'manifest.json').exists() else {}
for key in ['publishedEvidence','scopeUpdates']:
 if key in previous: report[key]=previous[key]
if report.get('publishedEvidence'):
 report['notes']=[note for note in report['notes'] if note!='Evidence is local only. No screenshots have been uploaded.']
 for publication in report['publishedEvidence']:
  report['notes'].append('PR #'+str(publication['pr'])+' evidence was uploaded with user authorization to '+publication.get('descriptionUrl',publication.get('commentUrl','GitHub'))+'.')
(r/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
for check in checks: print(check['pr'],check['platform'],check['case'],check['detail'])
print('Verified 16 screenshots and 8 before/after comparisons.')
