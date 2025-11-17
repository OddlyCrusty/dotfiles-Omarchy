#!/usr/bin/env bash
REPO="$HOME/dotfiles-Omarchy"

if [ ! -d "$REPO" ]; then
  exit 0
fi

if git -C "$REPO" diff --quiet && git -C "$REPO" diff --cached --quiet; then
  exit 0
fi

echo "⚠️  You have uncommitted dotfiles changes in $REPO"
echo "    -> Run: backup-dotfiles && update-dotfiles"

