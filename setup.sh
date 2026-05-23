#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 {cli|zsh|basics|code}"
    exit 1
fi

case ${1,,} in 
  cli)
    echo "Installing zsh..."
    rpm-ostree install zsh
    echo "Installation complete. Please restart your system and then run './setup.sh zsh'"
    ;;
  zsh)
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    if [ -f ".zshrc" ]; then
        cp .zshrc ~/
        echo "Copied .zshrc to home directory."
    fi
    echo "Please restart your shell to see changes."
    ;;
  basics)
    echo "Adding Flathub to flatpak repositories..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    echo "Installing EasyEffects..."
    flatpak install flathub -y com.github.wwmm.easyeffects
    echo "Cloning EasyEffects presets..."
    if [ ! -d "EasyEffects-Presets" ]; then
        git clone https://github.com/JackHack96/EasyEffects-Presets.git
    else
        echo "EasyEffects-Presets directory already exists, skipping clone."
    fi
    echo "Installing other essential software..."
    flatpak install flathub -y org.videolan.VLC org.qbittorrent.qBittorrent com.github.tchx84.Flatseal com.usebottles.bottles
    echo "Software installs are done. Install the Advanced Audio Gain preset for better audio."
    ;;
  code)
    TOOLBOX_NAME="dev-toolbox"
    echo "Creating toolbox '$TOOLBOX_NAME'..."
    toolbox create -y -c $TOOLBOX_NAME
    
    echo "Upgrading and installing dependencies inside toolbox..."
    toolbox run -c $TOOLBOX_NAME sudo dnf upgrade -y --refresh
    toolbox run -c $TOOLBOX_NAME sudo dnf install -y nodejs curl gcc gcc-c++ make wget
    
    echo "Verifying installations..."
    echo -n "Node version: "
    toolbox run -c $TOOLBOX_NAME node -v
    echo -n "NPM version: "
    toolbox run -c $TOOLBOX_NAME npm -v
    
    echo "Installing Rust..."
    toolbox run -c $TOOLBOX_NAME sh -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    
    echo "Installing VS Code..."
    toolbox run -c $TOOLBOX_NAME wget https://update.code.visualstudio.com/latest/linux-rpm-x64/stable -O code-latest-x64.rpm
    toolbox run -c $TOOLBOX_NAME sudo dnf install -y ./code-latest-x64.rpm
    toolbox run -c $TOOLBOX_NAME rm code-latest-x64.rpm

    echo "Creating desktop shortcut..."
    DESKTOP_FILE="$HOME/.local/share/applications/vscode-toolbox.desktop"
    mkdir -p "$(dirname "$DESKTOP_FILE")"
    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=VS Code (Toolbox)
Comment=Open Visual Studio Code inside $TOOLBOX_NAME toolbox
Exec=toolbox run -c $TOOLBOX_NAME code
Icon=com.visualstudio.code
Type=Application
Terminal=false
Categories=Development;IDE;
EOF
    chmod +x "$DESKTOP_FILE"
    
    echo "Programming environment setup complete."
    echo "You can enter the toolbox with: toolbox enter -c $TOOLBOX_NAME"
    echo "A desktop shortcut 'VS Code (Toolbox)' has been created."
    ;;
  *)
    echo "Usage: $0 {cli|zsh|basics|code}"
    ;;
esac
