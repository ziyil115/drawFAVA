#!/usr/bin/env bash
###############################################################################
# Script to update the current branch from the repo and from the upstream.

# Error handling:
set -euo pipefail

# First: figure out what directory this script is in.
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# Go to that directory.
cd "${REPO_DIR}"

# First, see if the origin is already nbenlab
ghaddr="`git remote get-url origin`"
if echo "$ghaddr" | grep -q "git@github.com:nbenlab/drawFAVA"
then echo "Your local repository appears to be cloned from nbenlab/drawFAVA"
     echo "instead of from <your GitHub username>/drawFAVA. In order to use"
     echo "this repository, you need to first fork nbenlab/drawFAVA repository"
     echo "to your user account then clone the forked repository."
     exit 1
fi

# Next, git pull!
# First check if the repo is clean.
if [ -n "`git status --porcelain | grep -v '^ \??'`" ]
then echo "-------------------------------------------------------------------"
     echo "Your repository contains changed files. If you've edited"
     echo 'annotations, try running the `bash sync.sh` script first.'
     exit 1
fi
# Next, do the pull.
echo "-------------------------------------------------------------------"
echo "Pulling from user repository..."
if ! git pull --ff-only
then echo ""
     echo "Git pull failed!"
     echo "This likely means that something in your local GitHub repo isn't"
     echo "committed. If you've edited annotations, try running the"
     echo '`bash sync.sh` script first.'
     exit 1
fi

# Git pull the upstream; if the upstream doesn't exist, add it first.
echo ""
if git remote -vv | grep -q '^upstream'
then echo "-------------------------------------------------------------------"
     echo "Git upstream already found."
else echo "-------------------------------------------------------------------"
     echo "Adding nbenlab/drawFAVA upstream repository."
     git remote add upstream git@github.com:nbenlab/drawFAVA
fi

# Fetch from upstream.
echo ""
echo "-------------------------------------------------------------------"
echo "Checking nbenlab/drawFAVA for updates..."
git fetch upstream main
git merge --no-edit upstream/main

echo ""
echo "-------------------------------------------------------------------"
echo "Success!"

exit 0
