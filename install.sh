#!/usr/bin/env bash

if [ ! -f ./fetch.sh ]; then
    echo "Error: fetch.sh not found in current directory"
    exit 1
fi

echo "Installing fetch..."
sudo cp ./fetch.sh /usr/local/bin/fetch
sudo chmod +x /usr/local/bin/fetch

# Add to .zshrc if not already there
if ! grep -q "fetch" ~/.zshrc; then
    echo "fetch" >> ~/.zshrc
    echo "Added fetch to ~/.zshrc"
fi

echo "Done. Restart your terminal or run 'source ~/.zshrc'"