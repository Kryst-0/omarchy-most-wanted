#!/usr/bin/env python3
import datetime, json, shutil
from pathlib import Path
source=Path(__file__).resolve().parent
config=Path.home()/'.config/omarchy'
shell=config/'shell.json'
plugin=config/'plugins/krysto.most-wanted'
stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
data=json.loads(shell.read_text())
if plugin.exists(): shutil.copytree(plugin, plugin.with_name(plugin.name+'.backup-'+stamp))
shutil.copy2(shell,shell.with_name('shell.json.backup-most-wanted-'+stamp))
plugin.mkdir(parents=True,exist_ok=True)
for name in ['Panel.qml','Road.qml','Cars.js','manifest.json','README.md','catalog.json']:
    shutil.copy2(source/name,plugin/name)
shutil.copytree(source/'i18n',plugin/'i18n',dirs_exist_ok=True)
layout=data.setdefault('bar',{}).setdefault('layout',{})
if not any(entry.get('id')=='krysto.most-wanted' for section in layout.values() if isinstance(section,list) for entry in section if isinstance(entry,dict)):
    layout.setdefault('left',[]).append({'id':'krysto.most-wanted'})
tmp=shell.with_suffix('.json.tmp-most-wanted')
tmp.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
tmp.replace(shell)
print(f'Installed {plugin}; shell.json backup: {stamp}')
