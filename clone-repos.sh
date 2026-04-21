#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <groups.yaml> [group_name ...]"
    exit 1
fi

YAML="$1"
shift

if [ ! -f "$YAML" ]; then
    echo "Error: file '$YAML' not found"
    exit 1
fi

# If group names given, filter to just those; otherwise process all
FILTER=("$@")

paste <(grep '^\s*name:' "$YAML" | sed 's/.*name:\s*//') \
      <(grep '^\s*repo:' "$YAML" | sed 's/.*repo:\s*//') |
while read -r name repo; do
    if [ ${#FILTER[@]} -gt 0 ]; then
        match=0
        for f in "${FILTER[@]}"; do [ "$f" = "$name" ] && match=1 && break; done
        [ "$match" -eq 0 ] && continue
    fi
    if [ -d "$name" ]; then
        echo "Updating $name ..."
        git -C "$name" pull --ff-only || echo "Failed to update $name"
    else
        echo "Cloning $repo into $name ..."
        git clone "$repo" "$name" || echo "Failed to clone $repo"
    fi
done

# Clone/update extra_repos
python3 -c "
import yaml, sys, os, subprocess
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)
filt = set(sys.argv[2:])
for g in data.get('groups', []):
    name = g.get('name', '')
    if filt and name not in filt:
        continue
    for url in g.get('extra_repos', []):
        basename = url.rstrip('/').removesuffix('.git').split('/')[-1]
        target = os.path.join(name, basename)
        if os.path.isdir(target):
            print(f'Updating {target} ...')
            subprocess.run(['git', '-C', target, 'pull', '--ff-only'])
        else:
            print(f'Cloning {url} into {target} ...')
            subprocess.run(['git', 'clone', url, target])
" "$YAML" "$@"
