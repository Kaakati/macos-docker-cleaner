# Docker Cleanup Utility for macOS

A simple, lightweight utility that automatically cleans up orphaned Docker images on macOS systems. This tool runs hourly to free up disk space and keep your Docker environment tidy.

## Features

- **Automated cleanup**: Removes dangling (untagged) Docker images every hour
- **Easy installation**: Single script handles the entire setup process
- **Zero configuration**: Uses sensible defaults that work out of the box
- **User detection**: Automatically configures for the current user
- **Logging**: All cleanup activities are logged for review

## Requirements

- macOS operating system
- Docker installed and configured
- Bash shell

## Installation

1. Download the installation script:
   ```bash
   curl -O https://raw.githubusercontent.com/kaakati/macos-docker-cleaner/main/install_docker_cleanup_hourly.sh
   ```

2. Make it executable:
   ```bash
   chmod +x install_docker_cleanup_hourly.sh
   ```

3. Run the installer:
   ```bash
   ./install_docker_cleanup_hourly.sh
   ```

That's it! The script will automatically:
- Create necessary directories
- Install the cleanup script
- Configure it to run hourly
- Start the service immediately

## How It Works

The utility installs:

1. A shell script at `~/scripts/docker_cleanup.sh` that runs `docker image prune -f`
2. A launchd plist at `~/Library/LaunchAgents/com.user.docker.cleanup.plist` that runs the script hourly
3. Logs are written to `~/Library/Logs/docker_cleanup.log`

## Manual Testing

To manually test the cleanup process:

```bash
~/scripts/docker_cleanup.sh
```

## Customization

### Change the Cleanup Frequency

Edit the plist file and modify the interval (value is in seconds):

```bash
nano ~/Library/LaunchAgents/com.user.docker.cleanup.plist
```

Change the `StartInterval` value (e.g., 7200 for every 2 hours), then reload:

```bash
launchctl unload ~/Library/LaunchAgents/com.user.docker.cleanup.plist
launchctl load ~/Library/LaunchAgents/com.user.docker.cleanup.plist
```

### Clean Up More Aggressively

To also remove unused images (not just dangling ones), edit the cleanup script:

```bash
nano ~/scripts/docker_cleanup.sh
```

Uncomment the following line by removing the # character:

```bash
# docker image prune -a --filter "until=24h" -f
```

## Uninstallation

To remove the utility:

```bash
launchctl unload ~/Library/LaunchAgents/com.user.docker.cleanup.plist
rm ~/Library/LaunchAgents/com.user.docker.cleanup.plist
rm ~/scripts/docker_cleanup.sh
```

## Troubleshooting

- **No cleanup happening?** Check the log file: `cat ~/Library/Logs/docker_cleanup.log`
- **Script not running?** Verify the job is loaded: `launchctl list | grep docker`
- **Docker command not found?** Ensure Docker is in your PATH when running as a service

## License

This utility is released under the MIT License. See the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
