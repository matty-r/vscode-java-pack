# Current Dir
$CURRENT_DIR = Get-Location

# Path to package.json
$PACKAGE_JSON = "package.json"

# Define extension packs array
$extension_packs = @((Get-Content $PACKAGE_JSON | ConvertFrom-Json).extensionPack)
$extension_packs += "matty-r.vscode-java-pack"

# Directory where VS Code extensions are installed
$VSCODE_EXTENSIONS_DIR = "$env:USERPROFILE\.vscode\extensions"

# Destination directory to copy matching extensions
$DESTINATION_DIR = Join-Path -Path $CURRENT_DIR -ChildPath "extensions"

if (Test-Path $DESTINATION_DIR) {
    Remove-Item -Path $DESTINATION_DIR -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $DESTINATION_DIR | Out-Null

foreach ($pack_name in $extension_packs) {
    $matching_dirs = Get-ChildItem -Path $VSCODE_EXTENSIONS_DIR -Directory | Where-Object { $_.Name -like "$pack_name*" }
    foreach ($dir in $matching_dirs) {
        Copy-Item -Path $dir.FullName -Destination $DESTINATION_DIR -Recurse
        Write-Host "Copied $($dir.Name) to $DESTINATION_DIR"
    }
}

# Create a zip file of the extensions
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($DESTINATION_DIR, "win_extensions.zip")

Write-Host "done."