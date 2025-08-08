#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m" # reset
echo -e "${color}Setting nsadmin zsh shell${reset}"

TARGET_USER="nsadmin"
TARGET_HOME="/home/$TARGET_USER"
ZSH_CUSTOM_DIR="$TARGET_HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH_CUSTOM_DIR/custom"

# Install Zsh if not already installed
sudo apt update
sudo apt install -y zsh curl git

# Change default shell to Zsh for the user
sudo chsh -s $(which zsh) $TARGET_USER

# Install Oh My Zsh for the target user
sudo -u $TARGET_USER bash -c "
    export HOME=/home/$TARGET_USER;
    export RUNZSH=no;
    sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"
"
# Install Zsh plugins
sudo -u $TARGET_USER git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
sudo -u $TARGET_USER git clone https://github.com/zsh-users/zsh-completions.git $ZSH_CUSTOM/plugins/zsh-completions
sudo -u $TARGET_USER git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# Ensure fzf is installed
sudo -u $TARGET_USER git clone --depth 1 https://github.com/junegunn/fzf.git $TARGET_HOME/.fzf
sudo -u $TARGET_USER bash -c "export HOME=$TARGET_HOME; $TARGET_HOME/.fzf/install --all"

# Update .zshrc to include plugins
ZSHRC="$TARGET_HOME/.zshrc"
sudo -u $TARGET_USER bash -c "sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-completions zsh-syntax-highlighting fzf)/' $ZSHRC"

# Set custom Zsh prompt
CUSTOM_PROMPT='PROMPT="%F{cyan}%n@%m%f %F{yellow}%~%f %# "'
sudo -u $TARGET_USER bash -c "echo '$CUSTOM_PROMPT' >> $ZSHRC"

# Set proper ownership
sudo chown -R $TARGET_USER:$TARGET_USER $ZSH_CUSTOM_DIR $TARGET_HOME/.zshrc

echo "Oh My Zsh installed successfully for $TARGET_USER!"