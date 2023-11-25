#!/bin/bash

# Create vsix package
vsce package

# Current Dir
CURRENT_DIR=$(pwd)

# Path to package.json
PACKAGE_JSON="package.json"

# Read extension pack names from package.json
extension_packs=($(jq -r '.extensionPack[]' < "$PACKAGE_JSON"))

# Directory where VS Code extensions are installed
VSCODE_EXTENSIONS_DIR="$HOME/.vscode/extensions"

# Destination directory to copy matching extensions
DESTINATION_DIR="$CURRENT_DIR/extensions"

mkdir -p "$DESTINATION_DIR"

for pack_name in "${extension_packs[@]}"
do
    find "$VSCODE_EXTENSIONS_DIR" -maxdepth 1 -type d -iname "${pack_name}*" -exec cp -r {} "$DESTINATION_DIR" \;
    copied_dirs=$(find "$DESTINATION_DIR" -maxdepth 1 -type d -iname "${pack_name}*")
    if [ -n "$copied_dirs" ]; then
        echo "Copied directories starting with $pack_name to $DESTINATION_DIR"
    else
        echo "No directories starting with $pack_name found in $VSCODE_EXTENSIONS_DIR"
    fi
done

# Create a zip file of the extensions
zip -r "extensions.zip" "extensions"

echo "done."