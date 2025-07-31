#!/bin/bash
# TextEdit Auto-Installer for macOS and Linux
# Detects platform, installs dependencies, and sets up TextEdit

set -e

# Clear screen and show banner
clear

# TextEdit ASCII Banner
cat << 'EOF'
                                                                      
                                                     ,,    ,,         
MMP""MM""YMM                 mm   `7MM"""YMM       `7MM    db   mm    
P'   MM   `7                 MM     MM    `7         MM         MM    
     MM  .gP"Ya `7M'   `MF'mmMMmm   MM   d      ,M""bMM  `7MM mmMMmm  
     MM ,M'   Yb  `VA ,V'    MM     MMmmMM    ,AP    MM    MM   MM    
     MM 8M""""""    XMX      MM     MM   Y  , 8MI    MM    MM   MM    
     MM YM.    ,  ,V' VA.    MM     MM     ,M `Mb    MM    MM   MM    
   .JMML.`Mbmmd'.AM.   .MA.  `Mbmo.JMMmmmmMMM  `Wbmd"MML..JMML. `Mbmo 
                                                                      
                                                                      

EOF

echo "🚀 TextEdit Auto-Installer"
echo "========================="

# Detect platform
PLATFORM=$(uname -s)
ARCH=$(uname -m)

echo "Platform: $PLATFORM ($ARCH)"
echo

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Python dependencies on Linux
install_linux_deps() {
    echo "🐧 Installing Linux dependencies..."
    
    # Detect Linux distribution
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        echo "Detected Debian/Ubuntu system"
        sudo apt-get update
        sudo apt-get install -y python3 python3-tk python3-pip
    elif [ -f /etc/redhat-release ]; then
        # RHEL/CentOS/Fedora
        echo "Detected RHEL/CentOS/Fedora system"
        if command_exists dnf; then
            sudo dnf install -y python3 python3-tkinter python3-pip
        elif command_exists yum; then
            sudo yum install -y python3 python3-tkinter python3-pip
        fi
    elif [ -f /etc/arch-release ]; then
        # Arch Linux
        echo "Detected Arch Linux system"
        sudo pacman -S --needed python python-pip tk
    else
        echo "⚠️  Unknown Linux distribution"
        echo "Please install Python 3 and tkinter manually:"
        echo "  - Python 3.6 or later"
        echo "  - tkinter (python3-tk package)"
        return 1
    fi
}

# Function to install Python dependencies on macOS
install_macos_deps() {
    echo "🍎 Installing macOS dependencies..."
    
    # Check for Homebrew
    if ! command_exists brew; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install Python with tkinter
    echo "Installing Python with tkinter..."
    brew install python python-tk
}

# Function to test Python installation
test_python() {
    echo "🧪 Testing Python installation..."
    
    # Check Python 3
    if ! command_exists python3; then
        echo "❌ Python 3 not found"
        return 1
    fi
    
    # Check Python version
    PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    echo "✅ Python $PYTHON_VERSION found"
    
    # Check tkinter
    if ! python3 -c "import tkinter" 2>/dev/null; then
        echo "❌ tkinter not available"
        return 1
    fi
    
    echo "✅ tkinter available"
    return 0
}

# Function to install TextEdit
install_textedit() {
    echo "📦 Installing TextEdit..."
    
    # Copy TextEdit script to system location
    if [ "$PLATFORM" = "Darwin" ]; then
        # macOS
        sudo cp dist/textedit /usr/local/bin/textedit
        sudo chmod +x /usr/local/bin/textedit
        echo "✅ TextEdit installed to /usr/local/bin/textedit"
    else
        # Linux
        sudo cp dist/textedit /usr/local/bin/textedit
        sudo chmod +x /usr/local/bin/textedit
        
        # Install desktop file
        if [ -d /usr/share/applications ]; then
            sudo cp dist/textedit.desktop /usr/share/applications/
            echo "✅ Desktop integration installed"
        fi
        
        echo "✅ TextEdit installed to /usr/local/bin/textedit"
    fi
}

# Function to create uninstaller
create_uninstaller() {
    cat > uninstall-textedit.sh << 'EOF'
#!/bin/bash
# TextEdit Uninstaller

echo "Removing TextEdit..."

# Remove binary
sudo rm -f /usr/local/bin/textedit

# Remove desktop file (Linux)
sudo rm -f /usr/share/applications/textedit.desktop

# Remove user config
rm -rf ~/.textedit

echo "✅ TextEdit uninstalled successfully"
EOF

    chmod +x uninstall-textedit.sh
    echo "📝 Uninstaller created: ./uninstall-textedit.sh"
}

# Main installation process
main() {
    echo "Starting TextEdit installation..."
    echo
    
    # Check if running from git repository
    if [ ! -f "dist/textedit" ]; then
        echo "❌ TextEdit distribution files not found"
        echo "Please run from the TextEdit git repository root"
        echo "Or download from: https://github.com/heyfinal/TextEdit"
        exit 1
    fi
    
    # Install platform-specific dependencies
    case "$PLATFORM" in
        "Darwin")
            if ! test_python; then
                install_macos_deps
                if ! test_python; then
                    echo "❌ Failed to install Python dependencies"
                    exit 1
                fi
            else
                echo "✅ Python dependencies already satisfied"
            fi
            ;;
        "Linux")
            if ! test_python; then
                install_linux_deps
                if ! test_python; then
                    echo "❌ Failed to install Python dependencies"
                    echo "Please install Python 3 and tkinter manually"
                    exit 1
                fi
            else
                echo "✅ Python dependencies already satisfied"
            fi
            ;;
        *)
            echo "❌ Unsupported platform: $PLATFORM"
            echo "TextEdit supports macOS and Linux only"
            exit 1
            ;;
    esac
    
    # Install TextEdit
    install_textedit
    
    # Create uninstaller
    create_uninstaller
    
    # Test installation
    echo
    echo "🧪 Testing installation..."
    if python3 dist/test-textedit.py; then
        echo
        echo "🎉 TextEdit installed successfully!"
        echo
        echo "Usage:"
        echo "  textedit                 # Start with empty document"
        echo "  textedit myfile.txt      # Open specific file"
        echo "  textedit *.py            # Open multiple files"
        echo
        echo "Features:"
        echo "  • Permanent dark mode theme"
        echo "  • Find and replace"
        echo "  • Word count and statistics"
        echo "  • Zoom controls"
        echo "  • Recent files menu"
        echo "  • Multiple file format support"
        echo
        echo "To uninstall: ./uninstall-textedit.sh"
    else
        echo "❌ Installation test failed"
        echo "TextEdit may not work correctly"
        exit 1
    fi
}

# Check for help flag
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "TextEdit Auto-Installer"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --help, -h    Show this help message"
    echo "  --test        Test dependencies only"
    echo
    echo "This script will:"
    echo "1. Detect your platform (macOS/Linux)"
    echo "2. Install Python 3 and tkinter if needed"
    echo "3. Install TextEdit to /usr/local/bin"
    echo "4. Set up desktop integration (Linux)"
    echo "5. Create an uninstaller script"
    echo
    echo "Requirements:"
    echo "  • macOS 10.14+ or Linux with X11/Wayland"
    echo "  • Administrator/sudo access for installation"
    echo "  • Internet connection for dependency installation"
    exit 0
fi

# Test mode
if [ "$1" = "--test" ]; then
    test_python
    exit $?
fi

# Run main installation
main