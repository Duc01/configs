#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 {cli|zsh|basics|code}"
	exit 1
fi

case ${1,,} in
cli)
	echo "Installing zsh..."
	sudo dnf install zsh
  chsh -s $(which zsh)
	echo "Installing Oh My Zsh..."
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	if [ -f ".zshrc" ]; then
		cp .zshrc ~/
		echo "Copied .zshrc to home directory."
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
	flatpak install flathub -y org.videolan.VLC org.qbittorrent.qBittorrent com.github.tchx84.Flatseal com.usebottles.bottles com.discordapp.Discord org.libreoffice.LibreOffice
	echo "Software installs are done. Install the Advanced Audio Gain preset for better audio."
	;;
code)
	sudo dnf upgrade -y --refresh
	sudo dnf install -y nodejs curl gcc gcc-c++ make wget

	echo "Installing Nerdfonts: Lilex, FiraCode, Jetbrains Mono"
	wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Lilex.zip"
	wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
	wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
	echo "All Font zip files have been downloaded, please unzip and install"
	echo "Verifying installations..."
	echo -n "Node version: "
	node -v
	echo -n "NPM version: "
	npm -v

	echo "Installing Rust..."
	sh -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

	echo "Installing VS Code..."
	wget https://update.code.visualstudio.com/latest/linux-rpm-x64/stable -O code-latest-x64.rpm
	sudo dnf install -y ./code-latest-x64.rpm
	rm code-latest-x64.rpm
	echo "Installing Kitty"
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	kitty themes Gruvbox\ Dark
	echo Installing Neovim
	sudo dnf install -y neovim python3-neovim
	rm -rf ~/.config/nvim
	git clone "https://github.com/Duc01/nvim-config.git" ~/.config/nvim
	;;
*)
	echo "Usage: $0 {cli|zsh|basics|code}"
	;;
esac
