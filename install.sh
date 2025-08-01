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

# Function to show banner (reusable)
show_banner() {
    clear
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
    echo
}

# Function to install Python dependencies on Linux
install_linux_deps() {
    show_banner
    echo "🐧 Installing Linux dependencies..."
    echo
    
    # Detect Linux distribution
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu/Kali
        echo "Detected Debian/Ubuntu/Kali system"
        echo "Ensuring system Python 3 with tkinter..."
        
        # Force install system python3-tk (not homebrew version)
        echo "werds" | sudo -S apt-get install -y python3-tk python3-dev python3-setuptools 2>/dev/null
        
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
    
    show_banner
    echo "✅ Dependencies installation completed"
    echo
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

# Function to find working Python with tkinter
find_python_with_tkinter() {
    local python_candidates=("/usr/bin/python3" "python3" "/usr/local/bin/python3" "/bin/python3")
    
    for python_cmd in "${python_candidates[@]}"; do
        if command -v "$python_cmd" >/dev/null 2>&1; then
            if "$python_cmd" -c "import tkinter" 2>/dev/null; then
                echo "$python_cmd"
                return 0
            fi
        fi
    done
    
    return 1
}

# Function to test Python installation
test_python() {
    echo "🧪 Testing Python installation..."
    
    # Find Python with tkinter
    WORKING_PYTHON=$(find_python_with_tkinter)
    if [ $? -eq 0 ]; then
        PYTHON_VERSION=$("$WORKING_PYTHON" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        echo "✅ Python $PYTHON_VERSION found at: $WORKING_PYTHON"
        echo "✅ tkinter available"
        export TEXTEDIT_PYTHON="$WORKING_PYTHON"
        return 0
    else
        echo "❌ No Python with tkinter found"
        echo "   Tried: /usr/bin/python3, python3, /usr/local/bin/python3, /bin/python3"
        return 1
    fi
}

# Function to install TextEdit
install_textedit() {
    echo "📦 Installing TextEdit..."
    echo
    
    # Create a wrapper script that uses the correct Python
    cat > textedit-wrapper << EOF
#!/bin/bash
# TextEdit Launcher - Uses correct Python with tkinter
exec "$TEXTEDIT_PYTHON" /usr/local/share/textedit/textedit-native.py "\$@"
EOF
    
    # Install TextEdit files
    echo "werds" | sudo -S mkdir -p /usr/local/share/textedit 2>/dev/null
    echo "werds" | sudo -S cp dist/textedit /usr/local/share/textedit/textedit-native.py 2>/dev/null
    echo "werds" | sudo -S cp textedit-wrapper /usr/local/bin/textedit 2>/dev/null
    echo "werds" | sudo -S chmod +x /usr/local/bin/textedit 2>/dev/null
    echo "werds" | sudo -S chmod +x /usr/local/share/textedit/textedit-native.py 2>/dev/null
    
    # Clean up wrapper
    rm -f textedit-wrapper
    
    if [ "$PLATFORM" = "Darwin" ]; then
        # macOS
        echo "✅ TextEdit installed to /usr/local/bin/textedit"
    else
        # Linux - Install desktop file
        if [ -d /usr/share/applications ]; then
            echo "werds" | sudo -S cp dist/textedit.desktop /usr/share/applications/ 2>/dev/null
            # Update desktop file to use correct path
            echo "werds" | sudo -S sed -i 's|Exec=textedit|Exec=/usr/local/bin/textedit|g' /usr/share/applications/textedit.desktop 2>/dev/null
            echo "✅ Desktop integration installed"
        fi
        
        echo "✅ TextEdit installed to /usr/local/bin/textedit"
        echo "Using Python: $TEXTEDIT_PYTHON"
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
    show_banner
    echo "Starting TextEdit installation..."
    echo "Platform: $PLATFORM ($ARCH)"
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
                    show_banner
                    echo "❌ Failed to install Python dependencies"
                    exit 1
                fi
            else
                show_banner
                echo "✅ Python dependencies already satisfied"
                echo
            fi
            ;;
        "Linux")
            if ! test_python; then
                install_linux_deps
                if ! test_python; then
                    show_banner
                    echo "❌ Failed to install Python dependencies"
                    echo "Please install Python 3 and tkinter manually"
                    echo "Try: sudo apt-get install python3-tk python3-dev"
                    exit 1
                fi
            else
                show_banner
                echo "✅ Python dependencies already satisfied"
                echo "Using: $TEXTEDIT_PYTHON"
                echo
            fi
            ;;
        *)
            show_banner
            echo "❌ Unsupported platform: $PLATFORM"
            echo "TextEdit supports macOS and Linux only"
            exit 1
            ;;
    esac
    
    # Install TextEdit
    show_banner
    echo "📦 Installing TextEdit system-wide..."
    install_textedit
    
    # Create uninstaller
    create_uninstaller
    
    # Test installation
    show_banner
    echo "🧪 Testing installation..."
    if "$TEXTEDIT_PYTHON" dist/test-textedit.py; then
        show_banner
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
        show_banner
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