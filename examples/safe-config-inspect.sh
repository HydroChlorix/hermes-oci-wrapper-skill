#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${HOME}/.oci/config"

if [ ! -f "$CONFIG_FILE" ]; then
  printf '[safe-config][warn] missing %s\n' "$CONFIG_FILE" >&2
  exit 0
fi

python3 - <<'PY'
from pathlib import Path
import re

config_path = Path.home() / '.oci' / 'config'
content = config_path.read_text()

# Parse manually — ConfigParser skips [DEFAULT] in sections()
# and OCI config may have leading blanks or comments
lines = [l for l in content.split('\n') if l.strip() and not l.strip().startswith('#')]
current_section = None
sections = {}

for line in lines:
    m = re.match(r'^\[(.+)\]', line.strip())
    if m:
        current_section = m.group(1)
        sections[current_section] = {}
    elif current_section and '=' in line:
        k, v = line.strip().split('=', 1)
        sections[current_section][k.strip()] = v.strip()

print('[safe-config] profiles:')
for section in ('DEFAULT',) + tuple(k for k in sections if k != 'DEFAULT'):
    props = sections.get(section, {})
    print(f'  - {section}')
    for key in ('user', 'tenancy', 'region', 'fingerprint', 'key_file'):
        value = props.get(key)
        if value is None:
            continue
        if key in {'user', 'tenancy'}:
            redacted = value[:6] + '...' if value else '[empty]'
        elif key == 'fingerprint':
            parts = value.split(':')
            redacted = ':'.join(parts[:2] + ['**']) if value else '[empty]'
        elif key == 'key_file':
            redacted = value if value.startswith('/') else f'[relative] {value}'
        else:
            redacted = value
        print(f'    {key}: {redacted}')
PY
