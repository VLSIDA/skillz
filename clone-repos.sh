#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <groups.yaml>"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: file '$1' not found"
    exit 1
fi

# Read name/repo pairs from YAML and clone into the name directory
paste <(grep '^\s*name:' "$1" | sed 's/.*name:\s*//') \
      <(grep '^\s*repo:' "$1" | sed 's/.*repo:\s*//') |
while read -r name repo; do
    if [ -d "$name" ]; then
        echo "Skipping $name (already exists)"
    else
        echo "Cloning $repo into $name ..."
        git clone "$repo" "$name" || echo "Failed to clone $repo"
    fi
done

# Clone extra_repos into <name>/<basename> directories
python3 -c "
import yaml, sys, os, subprocess
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)
for g in data.get('groups', []):
    name = g.get('name', '')
    for url in g.get('extra_repos', []):
        basename = url.rstrip('/').removesuffix('.git').split('/')[-1]
        target = os.path.join(name, basename)
        if os.path.isdir(target):
            print(f'Skipping {target} (already exists)')
        else:
            print(f'Cloning {url} into {target} ...')
            subprocess.run(['git', 'clone', url, target])
" "$1"
