#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    clear
    echo -e "${RED}"
    cat << "EOF"
    
 _          _ ____  _                                                         
| |    __ _( )  _ \| |__   ___ _ __  _   _ _ __ ___                           
| |   / _` |/| |_) | '_ \ / _ \ '_ \| | | | '_ ` _ \                          
| |__| (_| | |  _ <| | | |  __/ | | | |_| | | | | | |                         
|_____\__,_| |_| \_\_| |_|\___|_| |_|\__,_|_| |_| |_|       _   _             
                          |_ _|_ __  ___| |_ __ _| | | __ _| |_(_) ___  _ __  
                           | || '_ \/ __| __/ _` | | |/ _` | __| |/ _ \| '_ \ 
                           | || | | \__ \ || (_| | | | (_| | |_| | (_) | | | |
                          |___|_| |_|___/\__\__,_|_|_|\__,_|\__|_|\___/|_| |_|
                                                                                                                                       
                                                                                                                                                                                                                                                                    
EOF
    echo -e "${NC}${YELLOW}"
    echo "╔══════════════════════════════════════════╗"
    echo "║         Advanced Reconnaissance Tool     ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${CYAN}Version: 1.0.0${NC}"
    echo -e "${CYAN}Author: La'Rhen${NC}"
    echo "════════════════════════════════════════════"
    echo
}

print_step() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

check_go() {
    print_step "Checking Go installation..."
    if command -v go &> /dev/null; then
        go_version=$(go version | awk '{print $3}')
        print_success "Go is installed: $go_version"
        
        if [ -z "$(go env GOPATH)" ]; then
            print_warning "GOPATH is not set. Setting GOPATH..."
            export GOPATH="$HOME/go"
            export PATH="$PATH:$GOPATH/bin"
            if [ -f ~/.bashrc ]; then
                echo 'export GOPATH="$HOME/go"' >> ~/.bashrc
                echo 'export PATH="$PATH:$GOPATH/bin"' >> ~/.bashrc
            fi
            if [ -f ~/.zshrc ]; then
                echo 'export GOPATH="$HOME/go"' >> ~/.zshrc
                echo 'export PATH="$PATH:$GOPATH/bin"' >> ~/.zshrc
            fi
        fi
        return 0
    else
        print_error "Go is not installed"
        return 1
    fi
}

check_python() {
    print_step "Checking Python installation..."
    if command -v python3 &> /dev/null; then
        python_version=$(python3 --version)
        print_success "Python3 is installed: $python_version"
        return 0
    else
        print_error "Python3 is not installed"
        return 1
    fi
}

install_go_tools() {
    print_step "Installing Go tools..."
    
    export PATH="$PATH:$(go env GOPATH)/bin"
    
    tools=(
        "github.com/tomnomnom/assetfinder@latest"
        "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        "github.com/tomnomnom/anew@latest"
        "github.com/samogod/samoscout@latest"
        "github.com/projectdiscovery/httpx/cmd/httpx@latest"
        "github.com/assetnote/kiterunner/cmd/kr@latest"
    )
    
    for tool in "${tools[@]}"; do
        tool_name=$(echo $tool | awk -F'/' '{print $NF}' | awk -F'@' '{print $1}')
        print_step "Installing $tool_name..."
        
        if command -v $tool_name &> /dev/null; then
            print_success "$tool_name is already installed"
            continue
        fi
        
        if timeout 300 go install $tool 2>&1; then
            print_success "$tool_name installed successfully"
        else
            print_error "Failed to install $tool_name"
            print_warning "Will continue with installation..."
        fi
    done
    
    if [ -f ~/.bashrc ]; then
        if ! grep -q "go env GOPATH" ~/.bashrc; then
            echo 'export PATH="$PATH:$(go env GOPATH)/bin"' >> ~/.bashrc
        fi
    fi
    
    if [ -f ~/.zshrc ]; then
        if ! grep -q "go env GOPATH" ~/.zshrc; then
            echo 'export PATH="$PATH:$(go env GOPATH)/bin"' >> ~/.zshrc
        fi
    fi
}

install_python_deps() {
    print_step "Installing Python dependencies..."
    
    if command -v pip3 &> /dev/null; then
        print_step "Using pip3..."
        if pip3 install colorama 2>&1; then
            print_success "colorama installed with pip3"
            return 0
        fi
    fi
    
    if command -v pip &> /dev/null; then
        print_step "Trying pip..."
        if pip install colorama 2>&1; then
            print_success "colorama installed with pip"
            return 0
        fi
    fi
    
    if python3 -m pip install colorama 2>&1; then
        print_success "colorama installed with python3 -m pip"
        return 0
    fi
    
    print_error "Failed to install colorama"
    print_warning "You may need to install it manually: pip3 install colorama"
    return 1
}

install_system_deps() {
    print_step "Installing system dependencies..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y curl wget jq git python3 python3-pip python3-venv arjun tar gzip
            print_success "System dependencies installed (APT)"
        elif command -v yum &> /dev/null; then
            sudo yum install -y curl wget jq git python3 python3-pip tar gzip
            sudo pip3 install arjun
            print_success "System dependencies installed (YUM)"
        elif command -v pacman &> /dev/null; then
            sudo pacman -Syu --noconfirm curl wget jq git python python-pip tar gzip
            sudo pip install arjun
            print_success "System dependencies installed (Pacman)"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install curl wget jq git python3
            pip3 install arjun
            print_success "System dependencies installed (Homebrew)"
        fi
    fi
}

setup_tool() {
    print_step "Setting up Advanced Recon Tool..."
    
    if [ ! -f "larhenum.py" ]; then
        print_error "larhenum.py not found!"
        return 1
    fi
    
    chmod +x larhenum.py
    print_success "Made larhenum.py executable"
    
    if sudo ln -sf "$(pwd)/larhenum.py" /usr/local/bin/larhenum 2>/dev/null; then
        print_success "Installed to /usr/local/bin/larhenum"
    else
        mkdir -p ~/.local/bin
        ln -sf "$(pwd)/larhenum.py" ~/.local/bin/larhenum
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc 2>/dev/null
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null
        print_success "Installed to ~/.local/bin/larhenum"
    fi
    
    return 0
}

download_kiterunner_wordlists() {
    print_step "Downloading Kiterunner wordlists..."
    
    LARHEN_TOOLS_DIR="$HOME/Larhen_Tools"
    WORDLISTS_DIR="$LARHEN_TOOLS_DIR/wordlists"
    
    mkdir -p "$WORDLISTS_DIR"
    print_success "Created wordlists directory: $WORDLISTS_DIR"
    
    download_and_extract() {
        local url="$1"
        local filename="$2"
        local output_name="$3"
        
        print_step "Downloading $filename..."
        
        rm -f "$WORDLISTS_DIR/$filename" "$WORDLISTS_DIR/$output_name" 2>/dev/null
        
        if command -v wget &> /dev/null; then
            wget -q --show-progress -O "$WORDLISTS_DIR/$filename" "$url"
        elif command -v curl &> /dev/null; then
            curl -L --progress-bar "$url" -o "$WORDLISTS_DIR/$filename"
        else
            print_error "No download tool available"
            return 1
        fi
        
        if [ ! -f "$WORDLISTS_DIR/$filename" ]; then
            print_error "Download failed"
            return 1
        fi
        
        print_success "Downloaded $filename"
        
        if [[ "$filename" == *.tar.gz ]]; then
            print_step "Extracting $filename..."
            
            TEMP_DIR=$(mktemp -d)
            
            if tar -xzf "$WORDLISTS_DIR/$filename" -C "$TEMP_DIR" 2>/dev/null; then
                kite_file=$(find "$TEMP_DIR" -type f -name "*.kite" | head -1)
                
                if [ -n "$kite_file" ]; then
                    mv "$kite_file" "$WORDLISTS_DIR/$output_name"
                    print_success "Extracted to $output_name"
                else
                    any_file=$(find "$TEMP_DIR" -type f | head -1)
                    if [ -n "$any_file" ]; then
                        mv "$any_file" "$WORDLISTS_DIR/$output_name"
                        print_warning "Using $(basename "$any_file") as $output_name"
                    else
                        print_error "No files found in archive"
                        rm -rf "$TEMP_DIR"
                        return 1
                    fi
                fi
                
                rm -rf "$TEMP_DIR"
                
                rm -f "$WORDLISTS_DIR/$filename"
                print_success "Cleaned up $filename"
                
            else
                print_error "Extraction failed"
                rm -f "$WORDLISTS_DIR/$filename"
                return 1
            fi
        else
            mv "$WORDLISTS_DIR/$filename" "$WORDLISTS_DIR/$output_name" 2>/dev/null || true
        fi
        
        if [ -f "$WORDLISTS_DIR/$output_name" ] && [ -s "$WORDLISTS_DIR/$output_name" ]; then
            size=$(du -h "$WORDLISTS_DIR/$output_name" | cut -f1)
            print_success "$output_name ready ($size)"
            return 0
        else
            print_error "$output_name is missing or empty"
            return 1
        fi
    }
    
    declare -A wordlists=(
        ["routes-large.kite"]="routes-large.kite.tar.gz"
        ["routes-small.kite"]="routes-small.kite.tar.gz"
        ["swagger-wordlist.txt"]="swagger-wordlist.txt"
    )
    
    success=0
    total=0
    
    for output in "${!wordlists[@]}"; do
        filename="${wordlists[$output]}"
        url="https://wordlists-cdn.assetnote.io/data/kiterunner/$filename"
        
        ((total++))
        
        if download_and_extract "$url" "$filename" "$output"; then
            ((success++))
            ln -sf "$WORDLISTS_DIR/$output" "./$output" 2>/dev/null
        fi
        
        echo
    done
    
    chmod -R 755 "$WORDLISTS_DIR"
    
    if [ $success -eq $total ]; then
        print_success "All $total wordlists downloaded successfully!"
    else
        print_warning "Downloaded $success/$total wordlists"
    fi
    
    return $((total - success))
}

verify_installation() {
    print_step "Verifying installation..."
    
    echo
    echo "Essential Tools:"
    echo "----------------"
    
    essential_tools=("assetfinder" "subfinder" "httpx" "python3" "arjun")
    for tool in "${essential_tools[@]}"; do
        if command -v $tool &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} $tool"
        else
            echo -e "  ${RED}✗${NC} $tool"
        fi
    done
    
    echo
    echo "Optional Tools:"
    echo "---------------"
    
    optional_tools=("anew" "samoscout" "kr")
    for tool in "${optional_tools[@]}"; do
        if command -v $tool &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} $tool"
        else
            echo -e "  ${YELLOW}⚠${NC} $tool"
        fi
    done
    
    echo
    echo "Python Modules:"
    echo "---------------"
    
    if python3 -c "import colorama" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} colorama"
    else
        echo -e "  ${YELLOW}⚠${NC} colorama"
    fi
    
    echo
    echo "Wordlists:"
    echo "----------"
    
    WORDLISTS_DIR="$HOME/Larhen_Tools/wordlists"
    wordlist_files=("routes-large.kite" "routes-small.kite" "swagger-wordlist.txt")
    
    for wordlist in "${wordlist_files[@]}"; do
        if [ -f "$WORDLISTS_DIR/$wordlist" ] && [ -s "$WORDLISTS_DIR/$wordlist" ]; then
            size=$(du -h "$WORDLISTS_DIR/$wordlist" 2>/dev/null | cut -f1 || echo "N/A")
            echo -e "  ${GREEN}✓${NC} $wordlist ($size)"
        elif [ -f "$WORDLISTS_DIR/$wordlist" ]; then
            echo -e "  ${YELLOW}⚠${NC} $wordlist (empty)"
        else
            echo -e "  ${RED}✗${NC} $wordlist"
        fi
    done
    
    echo
}

show_usage() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║           INSTALLATION COMPLETE!             ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${CYAN}To use the tool:${NC}"
    echo "  1. Restart your terminal or run:"
    echo "     source ~/.bashrc"
    echo "  2. Run: larhenum"
    echo
    echo -e "${CYAN}Wordlists location:${NC}"
    echo "  ~/Larhen_Tools/wordlists/"
    echo
    echo -e "${CYAN}Created by: La'Rhen${NC}"
    echo -e "${CYAN}Version: 1.0.0${NC}"
    echo
    echo "## If installation failed or something wrong!"
    echo "## cd /larhenum"
    echo "## python3 -m venv venv"
    echo "## source venv/bin/activate"
    echo "## ./install.sh"
    echo "##  Finish"
    echo "## deactivate"
    
}

main() {
    print_banner
    
    echo -e "${YELLOW}Larhenum Recon Tool Installer${NC}"
    echo "════════════════════════════════════════════"
    echo
    
    check_go || exit 1
    check_python || exit 1
    
    install_system_deps
    install_go_tools
    install_python_deps
    download_kiterunner_wordlists
    setup_tool
    
    echo
    echo "════════════════════════════════════════════"
    echo
    
    verify_installation
    
    echo
    echo "════════════════════════════════════════════"
    echo
    
    show_usage
}

main
