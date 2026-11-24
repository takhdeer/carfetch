#!/usr/bin/env bash

if [ ! -f ./fetch.sh ]; then
    echo "Error: fetch.sh not found in current directory"
    exit 1
fi

echo "Installing carfetch..."
sudo cp ./fetch.sh /usr/local/bin/fetch
sudo chmod +x /usr/local/bin/fetch

echo ""
echo "Run carfetch every new instance"
echo " 1) Every new tab"
echo " 2) Only when called"
echo ""
read -p "Enter 1 or 2: " choice

if [ "$choice" = "1" ]; then
    # If Ghostty already runs fetch via its `command` setting, adding it to
    # .zshrc too would make it run twice in every Ghostty window.
    ghostty_cfg=""
    for f in \
        "$HOME/.config/ghostty/config" \
        "$HOME/.config/ghostty/config.ghostty" \
        "$HOME/Library/Application Support/com.mitchellh.ghostty/config" \
        "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"; do
        if [ -f "$f" ] && grep -qE '^[[:space:]]*command[[:space:]]*=.*fetch' "$f"; then
            ghostty_cfg="$f"
            break
        fi
    done

    if [ -n "$ghostty_cfg" ]; then
        echo "Ghostty already runs fetch on launch ($ghostty_cfg)."
        echo "Skipping ~/.zshrc so it doesn't run twice."
    elif grep -qx "fetch" ~/.zshrc 2>/dev/null; then
        echo "fetch is already in ~/.zshrc, skipping."
    else
        echo "fetch" >> ~/.zshrc
        echo "Done. fetch will run on every new tab."
    fi
elif [ "$choice" = "2" ]; then
    echo "Done. Just type 'fetch' to run it."
else
    echo "Invalid choice, skipping .zshrc update. You can run 'fetch' manually."
fi

echo "Done. Restart your terminal or run 'source ~/.zshrc'"