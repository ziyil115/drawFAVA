#!/usr/bin/env bash
###############################################################################
# Script to use git to add, commit, and push any new annotations.

# Error handling:
set -euo pipefail

# First: figure out what directory this script is in.
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# Go to that directory.
cd "${REPO_DIR}"

# Next: find all the files that need to be added or committed.
#readarray -t FILES < <(git -C "annotations/" ls-files -m -o --exclude-standard)

FILES=()
while IFS= read -r -d '' file
do ext="${file##*.}"
   if [ "$ext" = "tsv" ]
   then FILES+=("$file")
   fi
done < <(git -C "annotations/" ls-files -z -m -o --exclude-standard)
if [ ${#FILES} -eq 0 ]
then echo "-------------------------------------------------------------------"
     echo "No modified annotation files found!"
     echo "Please make sure you ran the sync.sh script from the same directory"
     echo 'you were in when you ran `docker compose up`.'
     exit 1
fi
# Print a message about how many annotations:
echo "-------------------------------------------------------------------"
echo "Found ${#FILES[@]} annotation files."
echo "Adding files to git repository..."
echo ""
# Add the annotations to git.
for file in "${FILES[@]}"
do git add annotations/"${file}"
done

# Commit everything.
echo "-------------------------------------------------------------------"
echo "Committing files..."
echo ""
if ! git commit -m"Annotations: `date -u -Iminutes`"
then echo ""
     echo "-------------------------------------------------------------------"
     echo "Failed to commit!"
     echo "Note that your files were successfully added to the git staging"
     echo "area but could not be committed."
     exit 1
fi

# Run git push:
echo ""
echo "-------------------------------------------------------------------"
echo "Files committed; pushing to GitHub..."
echo ""
if ! git push
then echo "-------------------------------------------------------------------"
     echo "Failed to push annotations to GitHub!"
     echo "Note that your files were successfully added and committed, but"
     echo "could not be pushed. This is usually because your local changes"
     echo "are out of sync with your GitHub repository; this can happen,"
     echo "for example, because you cloned a new copy of the repo and made"
     echo "edits in both places."
     exit 1
fi

echo ""
echo "-------------------------------------------------------------------"
echo "Done!"
exit 0
