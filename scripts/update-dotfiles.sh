#!/usr/bin/env bash

REPO="$HOME/dotfiles-Omarchy"
cd "$REPO" || {
    echo "Could not find repo at $REPO"
    exit 1
}

# Allow optional custom commit message:
# update-dotfiles "my message"
if [ $# -eq 0 ]; then
    MESSAGE="Update dotfiles: $(date '+%Y-%m-%d %H:%M:%S')"
else
    MESSAGE="$1"
fi

echo "🔍 Checking for changes..."
if git diff --quiet && git diff --cached --quiet; then
    echo "No changes detected."
    exit 0
fi

# Stage all changes
git add .

echo "📝 Committing with message: $MESSAGE"
git commit -m "$MESSAGE"

echo "📤 Pushing to GitHub..."
git push

echo "✅ Dotfiles updated and pushed successfully!"

