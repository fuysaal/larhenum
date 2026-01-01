#!/bin/bash

echo -e "\033[1;36m"
echo "╔══════════════════════════════════════════════╗"
echo "║      La'Rhen Recon Tool Installation         ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "\033[0m"

if ! command -v python3 &> /dev/null; then
    echo -e "\033[1;33m[*] Installing Python3...\033[0m"
    sudo apt update
    sudo apt install -y python3 python3-pip
fi

echo -e "\033[1;33m[*] Installing Python libraries...\033[0m"
pip3 install colorama --quiet

if ! command -v go &> /dev/null; then
    echo -e "\033[1;33m[*] Installing Go...\033[0m"
    sudo apt update
    sudo apt install -y golang
fi

if ! command -v jq &> /dev/null; then
    echo -e "\033[1;33m[*] Installing jq...\033[0m"
    sudo apt update
    sudo apt install -y jq curl
fi

echo -e "\033[1;33m[*] Installing Go tools...\033[0m"

tools=(
    "github.com/tomnomnom/assetfinder@latest"
    "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    "github.com/tomnomnom/anew@latest"
    "github.com/samogod/samoscout@latest"
    "github.com/projectdiscovery/httpx/cmd/httpx@latest"
)

for tool in "${tools[@]}"; do
    echo -e "\033[1;34m  ›\033[0m $tool"
    go install $tool 2>/dev/null || echo -e "\033[1;31m  ✗ Failed: $tool\033[0m"
done

echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc

chmod +x larhennum.py

echo -e "\n\033[1;32m[✓] Installation completed!\033[0m"
echo -e "\033[1;36m[*] Usage: python3 larhenum.py\033[0m"
echo -e "\033[1;36m[*] Or: ./larhenum.py\033[0m"
echo -e "\033[1;33m[*] Make sure jq and curl are installed for CRT.sh\033[0m"
