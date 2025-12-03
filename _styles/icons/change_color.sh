#!/bin/bash

# SVG Color Changer - Overwrites all colors with a new color
# Usage: ./change_svg_color.sh <path> <new_color>
# Example: ./change_svg_color.sh ./icons "#FF5733"
# Example: ./change_svg_color.sh logo.svg red

show_usage() {
    echo "Usage: $0 <file_or_directory> <new_color>"
    echo ""
    echo "Examples:"
    echo "  $0 logo.svg \"#FF5733\""
    echo "  $0 ./icons red"
    echo "  $0 . \"rgb(255,87,51)\""
    echo ""
    echo "Note: This will replace ALL colors in the SVG with the new color"
    echo "      Supports hex (#FF5733), named (red), or rgb format"
    exit 1
}

# Check arguments
if [ $# -ne 2 ]; then
    show_usage
fi

PATH_INPUT="$1"
NEW_COLOR="$2"

# Check if path exists
if [ ! -e "$PATH_INPUT" ]; then
    echo "Error: Path '$PATH_INPUT' does not exist"
    exit 1
fi

# Escape special characters for sed
escape_sed() {
    echo "$1" | sed 's/[&/\]/\\&/g'
}

NEW_ESCAPED=$(escape_sed "$NEW_COLOR")

# Process a single SVG file
process_svg() {
    local file="$1"
    echo "Processing: $file"
    # Use a single sed command with multiple expressions to avoid re-matching
    # Also match colors in fill, stroke, stop-color, and style attributes
    sed -i -E \
        -e "s/(fill|stroke|stop-color|color)=\"#[0-9A-Fa-f]{3,6}\"/\1=\"$NEW_ESCAPED\"/g" \
        -e "s/(fill|stroke|stop-color|color)='#[0-9A-Fa-f]{3,6}'/\1='$NEW_ESCAPED'/g" \
        -e "s/(fill|stroke|stop-color|color):\s*#[0-9A-Fa-f]{3,6}/\1: $NEW_ESCAPED/g" \
        -e "s/(fill|stroke|stop-color|color)=\"rgba?\([^)]+\)\"/\1=\"$NEW_ESCAPED\"/g" \
        -e "s/(fill|stroke|stop-color|color)='rgba?\([^)]+\)'/\1='$NEW_ESCAPED'/g" \
        -e "s/(fill|stroke|stop-color|color):\s*rgba?\([^)]+\)/\1: $NEW_ESCAPED/g" \
        -e "s/(fill|stroke|stop-color|color)=\"(black|white|red|green|blue|yellow|orange|purple|pink|brown|gray|grey|cyan|magenta|silver|gold|navy|teal|lime|maroon|olive|aqua|fuchsia)\"/\1=\"$NEW_ESCAPED\"/gi" \
        -e "s/(fill|stroke|stop-color|color)='(black|white|red|green|blue|yellow|orange|purple|pink|brown|gray|grey|cyan|magenta|silver|gold|navy|teal|lime|maroon|olive|aqua|fuchsia)'/\1='$NEW_ESCAPED'/gi" \
        -e "s/(fill|stroke|stop-color|color):\s*(black|white|red|green|blue|yellow|orange|purple|pink|brown|gray|grey|cyan|magenta|silver|gold|navy|teal|lime|maroon|olive|aqua|fuchsia)/\1: $NEW_ESCAPED/gi" \
        "$file"
}

# Main logic
if [ -f "$PATH_INPUT" ]; then
    # Single file
    if [[ "$PATH_INPUT" == *.svg ]]; then
        process_svg "$PATH_INPUT"
        echo "✓ Done! Changed all colors to '$NEW_COLOR' in $PATH_INPUT"
    else
        echo "Error: File is not an SVG"
        exit 1
    fi
elif [ -d "$PATH_INPUT" ]; then
    # Directory - find all SVG files recursively
    COUNT=0
    while IFS= read -r -d '' file; do
        process_svg "$file"
        ((COUNT++))
    done < <(find "$PATH_INPUT" -type f -name "*.svg" -print0)
    
    if [ $COUNT -eq 0 ]; then
        echo "No SVG files found in $PATH_INPUT"
    else
        echo "✓ Done! Changed all colors to '$NEW_COLOR' in $COUNT file(s)"
    fi
fi