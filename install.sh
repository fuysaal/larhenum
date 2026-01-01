#!/bin/bash

# Advanced Recon Tool - Installation Script
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${RED}"
    echo "$$\              $$\ $$$$$$$\  $$\ "
    echo "$$ |             $  |$$  __$$\ $$ |"
    echo "$$ |      $$$$$$\_/ $$ |  $$ |$$$$$$$\   $$$$$$\  $$$$$$$\ "
    echo "$$ |      \____$$\   $$$$$$$  |$$  __$$\ $$  __$$\ $$  __$$\ "
    echo "$$ |      $$$$$$$ |  $$  __$$< $$ |  $$ |$$$$$$$$ |$$ |  $$ |"
    echo "$$ |     $$  __$$ |  $$ |  $$ |$$ |  $$ |$$   ____|$$ |  $$ |"
    echo "$$$$$$$$\\$$$$$$$ |  $$ |  $$ |$$ |  $$ |\$$$$$$$\ $$ |  $$ |"
    echo "\________|\_______|  \__|  \__|\__|  \__| \_______|\__|  \__|"
    echo -e "${NC}"
    echo -e "${YELLOW}╔══════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║         Advanced Reconnaissance Tool     ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════╝${NC}"
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
    
    tools=(
        "github.com/tomnomnom/assetfinder@latest"
        "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        "github.com/tomnomnom/anew@latest"
        "github.com/samogod/samoscout@latest"
        "github.com/projectdiscovery/httpx/cmd/httpx@latest"
    )
    
    for tool in "${tools[@]}"; do
        tool_name=$(echo $tool | awk -F'/' '{print $NF}' | awk -F'@' '{print $1}')
        print_step "Installing $tool_name..."
        
        if go install $tool 2>/dev/null; then
            print_success "$tool_name installed successfully"
            
            # Add to PATH if not already
            if [ ! -f ~/.bashrc ] || ! grep -q "$tool_name" ~/.bashrc; then
                echo "export PATH=\$PATH:\$(go env GOPATH)/bin" >> ~/.bashrc
            fi
        else
            print_error "Failed to install $tool_name"
        fi
    done
    
    # Source bashrc
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
    fi
}

install_python_deps() {
    print_step "Installing Python dependencies..."
    
    if pip3 install colorama 2>/dev/null; then
        print_success "Python dependencies installed"
    else
        print_warning "Could not install Python dependencies with pip3"
        print_step "Trying pip..."
        if pip install colorama 2>/dev/null; then
            print_success "Python dependencies installed with pip"
        else
            print_error "Failed to install Python dependencies"
        fi
    fi
}

install_system_deps() {
    print_step "Installing system dependencies..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v apt &> /dev/null; then
            # Debian/Ubuntu
            sudo apt update
            sudo apt install -y curl jq git python3 python3-pip
            print_success "System dependencies installed (APT)"
        elif command -v yum &> /dev/null; then
            # RHEL/CentOS
            sudo yum install -y curl jq git python3 python3-pip
            print_success "System dependencies installed (YUM)"
        elif command -v pacman &> /dev/null; then
            # Arch
            sudo pacman -Syu --noconfirm curl jq git python python-pip
            print_success "System dependencies installed (Pacman)"
        else
            print_warning "Unknown package manager. Please install manually:"
            print_warning "curl, jq, git, python3, python3-pip"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install curl jq git python3
            print_success "System dependencies installed (Homebrew)"
        else
            print_warning "Homebrew not found. Please install manually:"
            print_warning "brew install curl jq git python3"
        fi
    else
        print_warning "Unsupported OS. Please install manually:"
        print_warning "curl, jq, git, python3, python3-pip"
    fi
}

setup_tool() {
    print_step "Setting up Advanced Recon Tool..."
    
    # Make the script executable
    if [ -f "advanced_recon.py" ]; then
        chmod +x advanced_recon.py
        print_success "Made advanced_recon.py executable"
        
        # Create symbolic link in /usr/local/bin if possible
        if [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then
            sudo ln -sf "$(pwd)/advanced_recon.py" /usr/local/bin/advanced_recon
            print_success "Created symbolic link: /usr/local/bin/advanced_recon"
        else
            # Add to ~/.local/bin
            if [ -d ~/.local/bin ]; then
                ln -sf "$(pwd)/advanced_recon.py" ~/.local/bin/advanced_recon
                print_success "Created symbolic link: ~/.local/bin/advanced_recon"
            else
                mkdir -p ~/.local/bin
                ln -sf "$(pwd)/advanced_recon.py" ~/.local/bin/advanced_recon
                print_success "Created ~/.local/bin and symbolic link"
            fi
        fi
    fi
}

verify_installation() {
    print_step "Verifying installation..."
    
    missing_tools=()
    
    # Check Go tools
    go_tools=("assetfinder" "subfinder" "anew" "samoscout" "httpx")
    for tool in "${go_tools[@]}"; do
        if command -v $tool &> /dev/null; then
            print_success "$tool is available"
        else
            print_error "$tool is NOT available"
            missing_tools+=($tool)
        fi
    done
    
    # Check system tools
    sys_tools=("curl" "jq" "python3")
    for tool in "${sys_tools[@]}"; do
        if command -v $tool &> /dev/null; then
            print_success "$tool is available"
        else
            print_error "$tool is NOT available"
            missing_tools+=($tool)
        fi
    done
    
    # Check Python module
    if python3 -c "import colorama" 2>/dev/null; then
        print_success "colorama Python module is available"
    else
        print_error "colorama Python module is NOT available"
        missing_tools+=("colorama")
    fi
    
    if [ ${#missing_tools[@]} -eq 0 ]; then
        print_success "All dependencies are installed!"
        return 0
    else
        print_error "Missing tools: ${missing_tools[*]}"
        return 1
    fi
}

show_usage() {
    print_step "Installation complete!"
    echo
    echo -e "${GREEN}Usage:${NC}"
    echo "  ./advanced_recon.py                    # Run from current directory"
    echo "  advanced_recon                         # If symlink was created"
    echo
    echo -e "${GREEN}Example:${NC}"
    echo "  advanced_recon"
    echo "  ./advanced_recon.py"
    echo
    echo -e "${YELLOW}Note:${NC} Make sure ~/.local/bin is in your PATH if using symlink"
    echo "  Add this to your ~/.bashrc or ~/.zshrc:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
}

main() {
    clear
    print_banner
    
    echo -e "${YELLOW}Advanced Recon Tool Installer${NC}"
    echo "======================================"
    echo
    
    # Check prerequisites
    if ! check_go; then
        print_error "Please install Go first: https://golang.org/dl/"
        exit 1
    fi
    
    if ! check_python; then
        print_error "Please install Python3 first"
        exit 1
    fi
    
    # Install dependencies
    install_system_deps
    install_go_tools
    install_python_deps
    
    # Setup tool
    setup_tool
    
    # Verify installation
    if verify_installation; then
        print_success "Installation completed successfully!"
        show_usage
    else
        print_error "Installation completed with errors"
        print_warning "Some tools may not work properly"
        show_usage
        exit 1
    fi
}

# Run main function
main
