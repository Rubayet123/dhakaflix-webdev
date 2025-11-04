# 🎬 DHAKA-FLIX WebDAV Server on Android (Termux)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Android](https://img.shields.io/badge/Platform-Android%20%7C%20Termux-green.svg)](https://termux.com/)
[![Rclone](https://img.shields.io/badge/Powered%20by-Rclone-blue.svg)](https://rclone.org/)

This guide documents the setup for running an **Rclone Union Remote** as an **unauthenticated WebDAV Server** on a local Android device via Termux. This allows network devices (PCs, Smart TVs, streaming devices, etc.) to stream content over Wi-Fi.

---

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#%EF%B8%8F-configuration)
- [Usage](#-usage)
- [Network Access](#-network-access)
- [Troubleshooting](#-troubleshooting)
- [Advanced Tips](#-advanced-tips)
- [License](#-license)

---

## ✨ Features

- 🔗 **Unified Access**: Combines multiple HTTP sources into a single WebDAV endpoint
- 📱 **Android-Based**: Runs entirely on your Android device using Termux
- 🌐 **Network Streaming**: Stream to any device on your local network
- 🚀 **Easy Management**: Simple start/stop commands with tmux
- ⚡ **Optimized**: Configured with buffer and timeout settings for smooth streaming
- 🔓 **No Authentication**: Quick local network access (use on trusted networks only)

---

## 📦 Prerequisites

- **Android device** (phone or tablet)
- **Termux** app installed ([F-Droid](https://f-droid.org/packages/com.termux/) or [GitHub](https://github.com/termux/termux-app))
- **Local Wi-Fi network**
- Access to your HTTP media sources

---

## 🛠️ Installation

### 1. Update Termux and Install Required Packages

```bash
pkg update && pkg upgrade -y
pkg install rclone tmux -y
```

### 2. Create Rclone Configuration Directory

```bash
mkdir -p ~/.config/rclone
```

### 3. Create Configuration File

```bash
nano ~/.config/rclone/rclone.conf
```

Paste the configuration from the [Configuration](#%EF%B8%8F-configuration) section below, then save:
- Press `Ctrl+X`
- Press `Y` to confirm
- Press `Enter` to save

---

## ⚙️ Configuration

### Rclone Configuration (`~/.config/rclone/rclone.conf`)

This configuration combines individual HTTP sources (`DHAKA-FLIX-1` through `4`) into one unified remote (`DHAKA-FLIX-All`).

```ini
[DHAKA-FLIX-1]
type = http
url = http://172.16.50.7/DHAKA-FLIX-1/

[DHAKA-FLIX-2]
type = http
url = http://172.16.50.7/DHAKA-FLIX-2/

[DHAKA-FLIX-3]
type = http
url = http://172.16.50.7/DHAKA-FLIX-3/

[DHAKA-FLIX-4]
type = http
url = http://172.16.50.7/DHAKA-FLIX-4/

[DHAKA-FLIX-All]
type = union
upstreams = DHAKA-FLIX-1: DHAKA-FLIX-2: DHAKA-FLIX-3: DHAKA-FLIX-4:
```

> **Note**: Replace the URLs with your actual HTTP source addresses.

### Bash Aliases Setup

Add management shortcuts to your `~/.bashrc`:

```bash
nano ~/.bashrc
```

Paste these aliases at the end of the file:

```bash
# DHAKA-FLIX WebDAV Server Management
alias startwebdav='tmux new -d -s rclone_webdav "rclone serve webdav DHAKA-FLIX-All: --addr 0.0.0.0:8080 --buffer-size 32M --timeout 60m"'
alias stopwebdav='tmux kill-session -t rclone_webdav'
alias webdavlogs='tmux a -t rclone_webdav'
```

Save and activate:

```bash
source ~/.bashrc
```

---

## 🚀 Usage

### Server Management Commands

| Action | Command | Description |
|--------|---------|-------------|
| **Start Server** | `startwebdav` | Starts the WebDAV server in the background |
| **Stop Server** | `stopwebdav` | Stops the WebDAV server |
| **View Logs** | `webdavlogs` | Attach to tmux session to see server logs |
| **Check Status** | `tmux ls` | List all tmux sessions |

### Starting the Server

```bash
startwebdav
```

✅ The server is now running silently in the background!

### Stopping the Server

```bash
stopwebdav
```

### Viewing Live Logs

```bash
webdavlogs
```

To detach from logs without stopping the server:
- Press `Ctrl+B`, then press `D`

---

## 🌐 Network Access

Once the server is running, you can access it from any device on your local network.

### Connection Details

| Setting | Value |
|---------|-------|
| **Protocol** | WebDAV |
| **URL** | `http://[YOUR_PHONE_IP]:8080` |
| **Port** | `8080` |
| **Username** | *(none)* |
| **Password** | *(none)* |

### Finding Your Phone's IP Address

```bash
ifconfig wlan0 | grep "inet "
```

Or use a simpler command:

```bash
ip addr show wlan0 | grep "inet "
```

Example output: `192.168.1.100` — use this in the URL: `http://192.168.1.100:8080`

### Client Examples

#### Windows (File Explorer)
1. Open File Explorer
2. Right-click "This PC" → "Add a network location"
3. Enter: `http://YOUR_PHONE_IP:8080`

#### VLC Media Player
1. Open VLC
2. Media → Open Network Stream
3. Enter: `http://YOUR_PHONE_IP:8080`

#### Smart TV
1. Use your TV's file browser or media player app
2. Add network location with the WebDAV URL

---

## 🔧 Troubleshooting

### Problem: `stopwebdav` doesn't work

**Cause**: The server was started manually instead of using `startwebdav`, so it's not running in tmux.

**Solution**:

```bash
# Kill any rclone processes
pkill rclone

# Verify it's stopped
pgrep rclone

# Start correctly using startwebdav
startwebdav
```

### Problem: Can't connect from other devices

**Check if server is running:**

```bash
tmux ls
```

You should see `rclone_webdav` in the list.

**Check if port is listening:**

```bash
pkg install net-tools
netstat -tuln | grep 8080
```

**Firewall/Network issues:**
- Ensure your phone and client device are on the same Wi-Fi network
- Some networks isolate devices (guest networks, public Wi-Fi) — use your home network
- Check if any firewall app on Android is blocking connections

### Problem: Slow streaming or buffering

**Increase buffer size** in `~/.bashrc`:

```bash
alias startwebdav='tmux new -d -s rclone_webdav "rclone serve webdav DHAKA-FLIX-All: --addr 0.0.0.0:8080 --buffer-size 64M --timeout 60m"'
```

Then reload:

```bash
source ~/.bashrc
stopwebdav
startwebdav
```

### Problem: Server stops when Termux closes

**Enable Termux Wake Lock:**
- Open Termux
- Swipe from the left edge
- Tap "Acquire wakelock"

Or use this command:

```bash
termux-wake-lock
```

---

## 💡 Advanced Tips

### Auto-start on Termux Boot

Install Termux:Boot from F-Droid, then create:

```bash
mkdir -p ~/.termux/boot
nano ~/.termux/boot/start-webdav.sh
```

Add:

```bash
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
tmux new -d -s rclone_webdav "rclone serve webdav DHAKA-FLIX-All: --addr 0.0.0.0:8080 --buffer-size 32M --timeout 60m"
```

Make executable:

```bash
chmod +x ~/.termux/boot/start-webdav.sh
```

### Adding Authentication (Optional)

If you want password protection, modify the `startwebdav` alias:

```bash
alias startwebdav='tmux new -d -s rclone_webdav "rclone serve webdav DHAKA-FLIX-All: --addr 0.0.0.0:8080 --buffer-size 32M --timeout 60m --user YOUR_USERNAME --pass YOUR_PASSWORD"'
```

### Change Port

To use a different port (e.g., 9090):

```bash
alias startwebdav='tmux new -d -s rclone_webdav "rclone serve webdav DHAKA-FLIX-All: --addr 0.0.0.0:9090 --buffer-size 32M --timeout 60m"'
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Rclone](https://rclone.org/) - The swiss army knife of cloud storage
- [Termux](https://termux.com/) - Android terminal emulator
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer

---

## 📞 Support

If you encounter any issues or have questions:
1. Check the [Troubleshooting](#-troubleshooting) section
2. Review [Rclone documentation](https://rclone.org/commands/rclone_serve_webdav/)
3. Open an issue on GitHub

---

**Made with ❤️ for seamless local media streaming**
