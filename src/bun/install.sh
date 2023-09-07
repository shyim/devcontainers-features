#!/usr/bin/env bash

set -e

prerequisites=()

if ! command -v curl &> /dev/null; then
    prerequisites+=("curl")
fi

if ! command -v unzip &> /dev/null; then
    prerequisites+=("unzip")
fi

# check that prerequisites is not empty
if [ ${#prerequisites[@]} -eq 0 ]; then
    echo "No packages to install"
else
    echo "Installing prerequisites: ${prerequisites[@]}"
    apt-get update
    apt-get install -y ${prerequisites[@]}
fi

export BUN_INSTALL=/usr/local
curl -fsSL https://bun.sh/install | bash