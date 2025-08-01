#!/bin/bash

# Configuration deployment.json must be in project root directory
if [[ ! -f "deployment.json" ]]; then
    echo "[!] deployment.json not found in project root, see README"
    exit 1
fi

GODOT_PATH=$(jq -r '.godot_path' deployment.json)
echo "$GODOT_PATH"
PROJECT_PATH=$(jq -r '.project_path' deployment.json)
echo "$PROJECT_PATH"
BUILD_PATH=$(jq -r '.build_path' deployment.json)
echo "$BUILD_PATH"

REMOTE_SERVER="blog"  # key config must be setup in .ssh
REMOTE_PATH="/home/wes/blog/gamejam"
PROJECT_NAME="bigmode25-dev-$USER"

if [[ "$1" == "main" ]]; then
    PROJECT_NAME="bigmode25-dev-main"
fi

URL="https://ogsyn.dev/gamejam/$PROJECT_NAME.html"

# Remove existing build directory if it exists
if [[ -d "$BUILD_PATH" ]]; then
    echo "[*] Removing existing build directory..."
    rm -rf "$BUILD_PATH"
fi

# Create fresh build directory
mkdir -p "$BUILD_PATH"

# Check if necessary paths exist before trying to build
paths=("$GODOT_PATH" "$PROJECT_PATH" "$BUILD_PATH")
for path in "${paths[@]}"; do
    if [[ ! -e "$path" ]]; then
        echo "[!] Path not found: $path"
        exit 1
    fi
done

# Build the web export
echo "[*] Building web export..."
if "$GODOT_PATH" --headless --export-release "Web" "$BUILD_PATH/$PROJECT_NAME.html" "$PROJECT_PATH"; then
    echo "[*] Build successful, deploying to server..."
    
    # Execute rsync command directly (no WSL needed on Linux)
    if rsync -avz --delete --include="${PROJECT_NAME}.*" --exclude="*" "${BUILD_PATH}/" "${REMOTE_SERVER}:${REMOTE_PATH}/"; then
        echo
        echo "[*] Deployment for '$PROJECT_NAME' complete!"
        echo "[*] Available to play at '$URL'"
    else
        echo "[!] Rsync failed with exit code: $?"
        exit 1
    fi
else
    echo
    echo "[!] Build failed with exit code: $?"
    exit 1
fi
