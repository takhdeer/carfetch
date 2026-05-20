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
    if ! grep -q "fetch" ~/.zshrc 2>/dev/null; then
        echo "fetch" >> ~/.zshrc
    fi
    echo "Done. fetch will run on every new tab."
elif [ "$choice" = "2" ]; then
    echo "Done. Just type 'fetch' to run it."
else
    echo "Invalid choice, skipping .zshrc update. You can run 'fetch' manually."
fi

echo "Done. Restart your terminal or run 'source ~/.zshrc'"