"""Validate the source-linked learning companion without dependencies."""
import json
import pathlib
import re
import xml.etree.ElementTree as ET
from urllib.parse import quote
root=pathlib.Path(__file__).resolve().parents[2]
directory=root/'docs/portfolio'
config=json.loads((directory/'lesson-config.json').read_text(encoding='utf-8'))
assert len(config['lessons'])>=1
ids=[x['id'] for x in config['lessons']]
assert len(ids)==len(set(ids))
for lesson in config['lessons']:
    assert lesson['title'] and lesson['objective'] and lesson['checkpoint']
    assert len(lesson['source_paths'])==len(lesson['source_urls'])
    for source in lesson['source_paths']:
        candidate=root/source
        assert candidate.resolve().is_relative_to(root.resolve()), 'Source path escapes repository'
        assert candidate.exists(), 'Missing source: '+source
ET.parse(root/'assets/portfolio/hero-25d.svg')
page=(directory/'index.html').read_text(encoding='utf-8')
embedded=re.search(r'<script type="application/json" id="workspaceData">(.*?)</script>',page,re.S)
assert embedded and json.loads(embedded.group(1))==config, 'Guide and canonical JSON disagree'
assert 'showModal()' in page and 'prefers-reduced-motion' in page
assert re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9][A-Za-z0-9_.-]*', config['repository'])
assert re.fullmatch(r'[a-f0-9]{40}', config['source_revision'])
for lesson in config['lessons']:
    for source, url in zip(lesson['source_paths'], lesson['source_urls'], strict=True):
        assert '\\' not in source and all(part not in ('', '.', '..') for part in source.split('/'))
        expected = 'https://github.com/' + config['repository'] + '/blob/' + config['source_revision'] + '/' + quote(source, safe='/')
        assert url == expected, 'Source URL must be a canonical HTTPS GitHub commit link'

print(str(len(config['lessons']))+' source-linked learning paths validated')
