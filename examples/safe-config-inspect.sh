#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${HOME}/.oci/config"

if [ ! -f "$CONFIG_FILE" ]; then
  printf '[safe-config][warn] missing %s
' "$CONFIG_FILE" >&2
  exit 0
fi

python3 - <<'PY'
from configparser import ConfigParser
from pathlib import Path

config_path = Path.home() / '.oci' / 'config'
parser = ConfigParser()
parser.read(config_path)

print('[safe-config] profiles:')
for section in parser.sections():
    print(f'  - {section}')
    for key in ('user', 'tenancy', 'region', 'fingerprint', 'key_file'):
        if parser.has_option(section, key):
            value = parser.get(section, key)
            if key in {'user', 'tenancy'}:
                redacted = value[:6] + '...' if value else '[empty]'
            elif key == 'fingerprint':
                parts = value.split(':')
                redacted = ':'.join(parts[:2] + ['**'] * max(0, len(parts) - 2)) if value else '[empty]'
            elif key == 'key_file':
                redacted = value if value.startswith('/') else f'[relative] {value}'
            else:
                redacted = value
            print(f'    {key}: {redacted}')
PY
