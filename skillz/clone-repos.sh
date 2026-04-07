#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <groups.yaml>"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: file '$1' not found"
    exit 1
fi

grep '^\s*repo:' "$1" | sed 's/.*repo:\s*//' | while read -r repo; do
    echo "Cloning $repo ..."
    git clone "$repo" || echo "Failed to clone $repo"
done
