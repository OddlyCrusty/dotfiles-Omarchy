#!/usr/bin/env bash
set -euo pipefail

REPO="$HOME/dotfiles-Omarchy"
BACKUP_ROOT="$REPO/backups"

cd "$REPO" || {
  echo "Could not find repo at $REPO"
  exit 1
}

mkdir -p "$BACKUP_ROOT"

# Only proceed if there are uncommitted changes
if git diff --quiet && git diff --cached --quiet; then
  echo "No uncommitted changes in dotfiles. Nothing to back up into repo."
  exit 0
fi

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
echo "Creating repo backup with timestamp: $TIMESTAMP"

ITEMS=(autostart ghostty hypr waybar obsidian starship.toml)

for item in "${ITEMS[@]}"; do
  PATH_IN_REPO="config/$item"

  # Only back up items that actually changed
  if git status --porcelain -- "$PATH_IN_REPO" | grep -q .; then
    if [ "$item" = "starship.toml" ]; then
      DEST_DIR="$BACKUP_ROOT/starship/$TIMESTAMP"
      mkdir -p "$DEST_DIR"
      echo "Backing up changed starship.toml -> backups/starship/$TIMESTAMP/"
      cp "$PATH_IN_REPO" "$DEST_DIR/"
    else
      DEST_DIR="$BACKUP_ROOT/$item/$TIMESTAMP"
      mkdir -p "$DEST_DIR"
      echo "Backing up changed $item -> backups/$item/$TIMESTAMP/"
      cp -r "$PATH_IN_REPO"/* "$DEST_DIR/"
    fi
  fi
done

echo
echo "Repo backup complete under: $BACKUP_ROOT"
echo "Remember to run: update-dotfiles  (to commit + push backups if you want them on GitHub)"

# Optional: keep only the last 2 backups per item (inside repo)
for item in "${ITEMS[@]}"; do
  # map starship.toml to folder name 'starship'
  if [ "$item" = "starship.toml" ]; then
    ITEM_DIR="$BACKUP_ROOT/starship"
  else
    ITEM_DIR="$BACKUP_ROOT/$item"
  fi

  [ -d "$ITEM_DIR" ] || continue

  # List timestamps for this item
  mapfile -t DIRS < <(find "$ITEM_DIR" -maxdepth 1 -mindepth 1 -type d | sort)

  if ((${#DIRS[@]} > 2)); then
    TO_DELETE=("${DIRS[@]:0:${#DIRS[@]}-2}")
    for dir in "${TO_DELETE[@]}"; do
      echo "Pruning old repo backup: $dir"
      rm -rf "$dir"
    done
  fi
done

