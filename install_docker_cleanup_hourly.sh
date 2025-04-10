#!/bin/bash
# Auto-detect user and install Docker cleanup cronjob (hourly)

# Get current username
CURRENT_USER=$(whoami)
SCRIPTS_DIR="$HOME/scripts"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
LOG_DIR="$HOME/Library/Logs"

# Create necessary directories
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$LAUNCH_AGENTS_DIR"
mkdir -p "$LOG_DIR"

# Create the cleanup script
cat > "$SCRIPTS_DIR/docker_cleanup.sh" << 'EOF'
#!/bin/bash
# Simple script to remove orphaned Docker images

# Remove all dangling (untagged) images
echo "$(date): Removing dangling Docker images..."
docker image prune -f

# Optional: To also remove unused images (not used in last 24h)
# docker image prune -a --filter "until=24h" -f

echo "$(date): Cleanup complete"
EOF

# Make the script executable
chmod +x "$SCRIPTS_DIR/docker_cleanup.sh"

# Create the plist file with proper paths - set to run every hour
cat > "$LAUNCH_AGENTS_DIR/com.user.docker.cleanup.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.docker.cleanup</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPTS_DIR/docker_cleanup.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>3600</integer>
    <key>StandardOutPath</key>
    <string>$LOG_DIR/docker_cleanup.log</string>
    <key>StandardErrorPath</key>
    <string>$LOG_DIR/docker_cleanup.log</string>
</dict>
</plist>
EOF

# Unload existing job if it exists (in case of reinstallation)
launchctl unload "$LAUNCH_AGENTS_DIR/com.user.docker.cleanup.plist" 2>/dev/null || true

# Load the job
launchctl load "$LAUNCH_AGENTS_DIR/com.user.docker.cleanup.plist"

echo "Docker cleanup job installed successfully!"
echo "The job will run hourly"
echo "Logs will be saved to: $LOG_DIR/docker_cleanup.log"
echo "To test it now, run: $SCRIPTS_DIR/docker_cleanup.sh"