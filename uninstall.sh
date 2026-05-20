#!/usr/bin/env bash

echo "Uinstalling fetch..."

# Remove binary
if [ -f /usr/local/bin/fetch ]; then
    sudo rm /usr/local/bin/fetch
    echo "Removed /usr/local/bin/fetch"
else
    echo "fetch not found in /usr/local/bin, skipping"
fi

# Remove from .zshrc
if grep -q "^fetch$" ~/.zshrc 2>/dev/null; then
    sed -i '' '/^fetch$/d' ~/.zshrc
    echo "Removed fetch from ~/.zshrc"
else
    echo "fetch not found in ~/.zshrc, skipping"
fi

echo "Done. Restart your terminal or run 'source ~/.zshrc'"