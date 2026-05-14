#!/bin/bash

# Update package list and install tmux
sudo apt update
sudo apt install -y tmux

# Install Tmux Plugin Manager (tpm)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Optional: Install example plugins (commented out for user to enable)
# echo 'Plugins
# - tmux-resurrect
# - tpm' > ~/.tmux.conf
# .tmux/plugins/tpm/bin/install_plugins