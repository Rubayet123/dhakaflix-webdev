#!/data/data/com.termux/files/usr/bin/bash

# DHAKA-FLIX WebDAV Server Setup Script
# This script automates the installation and configuration process

set -e

echo "🎬 DHAKA-FLIX WebDAV Server Setup"
echo "=================================="
echo ""

# Update packages
echo "📦 Updating Termux packages..."
pkg update -y && pkg upgrade -y

# Install required packages
echo "📥 Installing rclone and tmux..."
pkg install rclone tmux -y

# Create config directory
echo "📁 Creating rclone configuration directory..."
mkdir -p ~/.config/rclone

# Check if config exists
if [ -f ~/.config/rclone/rclone.conf ]; then
    echo "⚠️  Configuration file already exists!"
    read -p "Do you want to backup and replace it? (y/n): " choice
    if [ "$choice" = "y" ]; then
        cp ~/.config/rclone/rclone.conf ~/.config/rclone/rclone.conf.backup
        echo "✅ Backup created at ~/.config/rclone/rclone.conf.backup"
    else
        echo "⏭️  Skipping configuration file creation"
        SKIP_CONFIG=true
    fi
fi

if [ "$SKIP_CONFIG" != true ]; then
    echo "📝 Creating example configuration file..."
    echo "Please edit ~/.config/rclone/rclone.conf with your actual URLs"
    
    cat > ~/.config/rclone/rclone.conf << 'EOF'
[DHAKA-FLIX-1]
type = http
url = http://YOUR_SERVER_IP/DHAKA-FLIX-1/

[DHAKA-FLIX-2]
type = http
url = http://YOUR_SERVER_IP/DHAKA-FLIX-2/

[DHAKA-FLIX-3]
type = http
url = http://YOUR_SERVER_IP/DHAKA-FLIX-3/

[DHAKA-FLIX-4]
type = http
url = http://YOUR_SERVER_IP/DHAKA-FLIX-4/

[DHAKA-FLIX-All]
type = union
upstreams = DHAKA-FLIX-1: DHAKA-FLIX-2: DHAKA-FLIX-3: DHAKA-FLIX-4:
EOF
fi

# Add aliases to .bashrc
echo "⚡ Setting up bash aliases..."

# Check if aliases already exist
if grep -q "startwebdav" ~/.bashrc; then
    echo "⚠️  Aliases already exist in ~/.bashrc"
    read -p "Do you want to update them? (y/n): " choice
    if [ "$choice" = "y" ]; then
        # Remove old aliases
        sed -i '/# DHAKA-FLIX WebDAV Server Management/,/alias webdavlogs=/d' ~/.bashrc
    else
        echo "⏭️  Skipping alias setup"
        SKIP_ALIASES=true
    fi
fi

if [ "$SKIP_ALIASES" != true ]; then
    cat >> ~/.bashrc << 'EOF'

# DHAKA-FLIX WebDAV Server Management
alias startwebdav='tmux new -d -s rclone_webdav "rclone serve webdav DHAKA-FLIX-All: --addr 0.0.0.0:8080 --buffer-size 32M --timeout 60m"'
alias stopwebdav='tmux kill-session -t rclone_webdav'
alias webdavlogs='tmux a -t rclone_webdav'
EOF
fi

# Reload bashrc
source ~/.bashrc

echo ""
echo "✅ Setup Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Edit your configuration:"
echo "   nano ~/.config/rclone/rclone.conf"
echo ""
echo "2. Replace 'YOUR_SERVER_IP' with your actual HTTP server addresses"
echo ""
echo "3. Start the server:"
echo "   startwebdav"
echo ""
echo "4. Find your phone's IP address:"
echo "   ip addr show wlan0 | grep 'inet '"
echo ""
echo "5. Access from other devices:"
echo "   http://YOUR_PHONE_IP:8080"
echo ""
echo "📖 For more information, read the README.md"
echo ""