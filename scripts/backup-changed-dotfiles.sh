#!/usr/bin/env bash
set -euo pipefail

REPO="$HOME/dotfiles-Omarchy"
BACKUP_ROOT="$HOME/.config-backups"

cd "$REPO" || {
  echo "Could not find repo at $REPO"
  exit 1
}

mkdir -p "$BACKUP_ROOT"

# 1) Check if there are any changes at all
if git diff --quiet && git diff --cached --quiet; then
  echo "No uncommitted changes in dotfiles. Nothing to back up."
  exit 0
fi

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/changed-$TIMESTAMP"

echo "Creating backup of changed dotfiles in: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Top-level items we care about
ITEMS=(autostart ghostty hypr waybar obsidian starship.toml)

for item in "${ITEMS[@]}"; do
  PATH_IN_REPO="config/$item"

  # Check if this item has changes
  if git status --porcelain -- "$PATH_IN_REPO" | grep -q .; then
    echo "Backing up changed $item ..."
    if [ -d "$PATH_IN_REPO" ]; then
      cp -r "$PATH_IN_REPO" "$BACKUP_DIR/"
    elif [ -f "$PATH_IN_REPO" ]; then
      cp "$PATH_IN_REPO" "$BACKUP_DIR/"
    fi
  fi
done

echo "Backup complete."
echo "Changed configs are stored in: $BACKUP_DIR"

# 2) Keep only the last TWO changed-* backups (do NOT touch backup-*)
mapfile -t CHANGED_DIRS < <(find "$BACKUP_ROOT" -maxdepth 1 -type d -name 'changed-*' | sort)

if ((${#CHANGED_DIRS[@]} > 2)); then
  # All but the last two
  TO_DELETE=("${CHANGED_DIRS[@]:0:${#CHANGED_DIRS[@]}-2}")
  for dir in "${TO_DELETE[@]}"; do
    echo "Removing old changed-backup: $dir"
    rm -rf "$dir"
  done
fi

