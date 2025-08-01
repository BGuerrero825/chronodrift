# Configuration deployment.json must be in project root directory

if (-not (Test-Path "deployment.json")) {
   Write-Host "[!] deployment.json not found in project root, see README"
   exit 1
}
$config = Get-Content -Path "deployment.json" | ConvertFrom-Json
$GODOT_PATH = $config.godot_path
Write-Host $GODOT_PATH
$PROJECT_PATH = $config.project_path
Write-Host $PROJECT_PATH
$BUILD_PATH = $config.build_path
Write-Host $BUILD_PATH

$REMOTE_SERVER = "blog"  # key config must be setup in .ssh

$REMOTE_PATH = "/home/wes/blog/gamejam"
$PROJECT_NAME = "bigmode25-dev-" + $env:USERNAME

if ($args[0] -eq "main") {
   $PROJECT_NAME = "bigmode25-dev-main"
}

$URL = "https://ogsyn.dev/gamejam/$PROJECT_NAME.html"

# Remove existing build directory if it exists
if (Test-Path $BUILD_PATH) {
   Write-Host "[*] Removing existing build directory..."
   Remove-Item -Path $BUILD_PATH -Recurse -Force
}

# Create fresh build directory
New-Item -ItemType Directory -Force -Path $BUILD_PATH

# Check if necessary paths exist before trying to build
$paths = @($GODOT_PATH, $PROJECT_PATH, $BUILD_PATH)
foreach ($path in $paths) {
   if (-not (Test-Path $path)) {
       Write-Host "[!] Path not found: $path"
       exit 1
   }
}

# Build the web export
Write-Host "[*] Building web export..."

$buildProcess = Start-Process -FilePath $GODOT_PATH -ArgumentList "--headless", "--export-release", "Web", "`"$BUILD_PATH\$PROJECT_NAME.html`"", $PROJECT_PATH -NoNewWindow -PassThru -Wait

if ($buildProcess.ExitCode -eq 0) {
   Write-Host "[*] Build successful, deploying to server..."
   
   # Convert Windows path to WSL path format
   $wslSource = $BUILD_PATH -replace "\\", "/"
   $wslSource = $wslSource -replace "C:", "/mnt/c"
   
   # Execute rsync command through WSL
   wsl rsync -avz --delete --include="${PROJECT_NAME}.*" --exclude="*" "${wslSource}/" "${REMOTE_SERVER}:${REMOTE_PATH}/"
   if ($LASTEXITCODE -ne 0) {
      Write-Host "[!] Rsync failed with exit code: $LASTEXITCODE"
      exit 1
  }
   
   Write-Host
   Write-Host "[*] Deployment for '$PROJECT_NAME' complete!"
   Write-Host "[*] Available to play at '$URL'"
} else {
   Write-Host
   Write-Host "[!] Build failed with exit code: $($buildProcess.ExitCode)"
   exit 1
}
