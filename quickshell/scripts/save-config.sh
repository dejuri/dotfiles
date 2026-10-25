#!/usr/bin/env bash

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
TARGET_FILE="$CONFIG_DIR/settings.json"
TEMP_FILE="$CONFIG_DIR/.settings.json.tmp"

mkdir -p "$CONFIG_DIR"

if [ -n "$1" ]; then
    if [ -f "$1" ]; then
        cat "$1" > "$TEMP_FILE"
        rm -f "$1"
    else
        # Якщо передано готовий рядок JSON
        printf '%s\n' "$1" > "$TEMP_FILE"
    fi
else
    cat > "$TEMP_FILE"
fi

# Атомарна заміна
mv "$TEMP_FILE" "$TARGET_FILE"