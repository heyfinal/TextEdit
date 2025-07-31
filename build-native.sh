#!/bin/bash
# TextEdit Native Build Script for macOS and Linux
# Creates distribution packages for both platforms

set -e  # Exit on error

echo "🚀 TextEdit Native Build Script"
echo "==============================="

# Detect platform
PLATFORM=$(uname -s)
ARCH=$(uname -m)
VERSION="1.0.0"
BUILD_DATE=$(date '+%Y-%m-%d')

echo "Platform: $PLATFORM ($ARCH)"
echo "Version: $VERSION"
echo "Build Date: $BUILD_DATE"
echo

# Create build directories
BUILD_DIR="/mnt/mycloud-kali/current active projects/TextEdit/build-native"
DIST_DIR="/mnt/mycloud-kali/current active projects/TextEdit/dist"

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR"

echo "📦 Creating distribution packages..."

case "$PLATFORM" in
    "Darwin")  # macOS
        echo "🍎 Building macOS App Bundle..."
        
        APP_NAME="TextEdit.app"
        APP_DIR="$BUILD_DIR/$APP_NAME"
        
        # Create app bundle structure
        mkdir -p "$APP_DIR/Contents/MacOS"
        mkdir -p "$APP_DIR/Contents/Resources"
        
        # Copy main script
        cp "/mnt/mycloud-kali/current active projects/TextEdit/textedit-native.py" "$APP_DIR/Contents/MacOS/TextEdit"
        chmod +x "$APP_DIR/Contents/MacOS/TextEdit"
        
        # Create Info.plist
        cat > "$APP_DIR/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>TextEdit</string>
    <key>CFBundleDisplayName</key>
    <string>TextEdit</string>
    <key>CFBundleIdentifier</key>
    <string>com.heyfinal.textedit</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleExecutable</key>
    <string>TextEdit</string>
    <key>CFBundleIconFile</key>
    <string>TextEdit</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.14</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>txt</string>
                <string>md</string>
                <string>py</string>
                <string>js</string>
                <string>html</string>
                <string>css</string>
                <string>json</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>Text Document</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
        </dict>
    </array>
    <key>NSAppleScriptEnabled</key>
    <true/>
</dict>
</plist>
EOF
        
        # Create app icon (placeholder)
        if command -v sips >/dev/null 2>&1; then
            # Create a simple icon using built-in tools
            mkdir -p "$APP_DIR/Contents/Resources/TextEdit.iconset"
            # You would normally create proper icon files here
            echo "⚠️  Icon creation requires design assets"
        fi
        
        # Create launcher script that ensures Python 3
        cat > "$APP_DIR/Contents/MacOS/TextEdit" << 'EOF'
#!/bin/bash
# TextEdit macOS Launcher

# Find Python 3
PYTHON=""
for cmd in python3 python; do
    if command -v "$cmd" >/dev/null 2>&1; then
        if "$cmd" -c "import sys; exit(0 if sys.version_info[0] >= 3 else 1)" 2>/dev/null; then
            PYTHON="$cmd"
            break
        fi
    fi
done

if [ -z "$PYTHON" ]; then
    osascript -e 'display dialog "Python 3 is required but not found. Please install Python 3 from python.org or Homebrew." with title "TextEdit" buttons {"OK"} default button "OK"'
    exit 1
fi

# Check for tkinter
if ! "$PYTHON" -c "import tkinter" 2>/dev/null; then
    osascript -e 'display dialog "Python tkinter module is missing. Install with: brew install python-tk" with title "TextEdit" buttons {"OK"} default button "OK"'
    exit 1
fi

# Launch TextEdit
cd "$(dirname "$0")"
exec "$PYTHON" textedit-native.py "$@"
EOF
        
        chmod +x "$APP_DIR/Contents/MacOS/TextEdit"
        
        # Copy the Python script
        cp "/mnt/mycloud-kali/current active projects/TextEdit/textedit-native.py" "$APP_DIR/Contents/MacOS/"
        
        # Create DMG installer
        if command -v hdiutil >/dev/null 2>&1; then
            echo "📦 Creating DMG installer..."
            DMG_NAME="TextEdit-$VERSION-macOS.dmg"
            
            # Create temporary DMG directory
            DMG_DIR="$BUILD_DIR/dmg"
            mkdir -p "$DMG_DIR"
            cp -R "$APP_DIR" "$DMG_DIR/"
            
            # Create Applications symlink
            ln -s /Applications "$DMG_DIR/Applications"
            
            # Create DMG
            hdiutil create -size 50m -srcfolder "$DMG_DIR" -format UDZO -o "$DIST_DIR/$DMG_NAME"
            echo "✅ DMG created: $DIST_DIR/$DMG_NAME"
        else
            # Just copy the app bundle
            cp -R "$APP_DIR" "$DIST_DIR/"
            echo "✅ App bundle created: $DIST_DIR/$APP_NAME"
        fi
        
        # Create install script
        cat > "$DIST_DIR/install-macos.sh" << 'EOF'
#!/bin/bash
# TextEdit macOS Installation Script

echo "Installing TextEdit for macOS..."

# Check for Python 3
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ Python 3 is required but not found."
    echo "   Install from: https://www.python.org/downloads/"
    echo "   Or use Homebrew: brew install python"
    exit 1
fi

# Check for tkinter
if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "❌ Python tkinter module is missing."
    echo "   Install with: brew install python-tk"
    exit 1
fi

# Copy app to Applications (if not already there)
if [ -d "TextEdit.app" ]; then
    echo "📱 Copying TextEdit.app to /Applications..."
    cp -R TextEdit.app /Applications/
    echo "✅ TextEdit installed successfully!"
    echo "   Launch from Applications folder or Spotlight"
else
    echo "❌ TextEdit.app not found in current directory"
    exit 1
fi
EOF
        chmod +x "$DIST_DIR/install-macos.sh"
        ;;
        
    "Linux")  # Linux
        echo "🐧 Building Linux packages..."
        
        # Create AppImage structure
        APPDIR="$BUILD_DIR/TextEdit.AppDir"
        mkdir -p "$APPDIR/usr/bin"
        mkdir -p "$APPDIR/usr/share/applications"
        mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"
        
        # Copy main script
        cp "/mnt/mycloud-kali/current active projects/TextEdit/textedit-native.py" "$APPDIR/usr/bin/textedit"
        chmod +x "$APPDIR/usr/bin/textedit"
        
        # Create desktop file
        cat > "$APPDIR/usr/share/applications/textedit.desktop" << 'EOF'
[Desktop Entry]
Name=TextEdit
Comment=A modern, lightweight text editor with permanent dark mode
Exec=textedit %F
Icon=textedit
Type=Application
Categories=TextEditor;Utility;
MimeType=text/plain;text/x-python;text/markdown;application/json;text/html;text/css;text/javascript;
StartupNotify=true
EOF
        
        # Create AppRun script
        cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
# TextEdit AppImage Launcher

# Find Python 3
PYTHON=""
for cmd in python3 python; do
    if command -v "$cmd" >/dev/null 2>&1; then
        if "$cmd" -c "import sys; exit(0 if sys.version_info[0] >= 3 else 1)" 2>/dev/null; then
            PYTHON="$cmd"
            break
        fi
    fi
done

if [ -z "$PYTHON" ]; then
    if command -v zenity >/dev/null 2>&1; then
        zenity --error --text="Python 3 is required but not found.\nInstall with: sudo apt-get install python3 python3-tk"
    else
        echo "❌ Python 3 is required but not found."
        echo "   Install with: sudo apt-get install python3 python3-tk"
    fi
    exit 1
fi

# Check for tkinter
if ! "$PYTHON" -c "import tkinter" 2>/dev/null; then
    if command -v zenity >/dev/null 2>&1; then
        zenity --error --text="Python tkinter module is missing.\nInstall with: sudo apt-get install python3-tk"
    else
        echo "❌ Python tkinter module is missing."
        echo "   Install with: sudo apt-get install python3-tk"
    fi
    exit 1
fi

# Launch TextEdit
cd "$(dirname "$0")"
exec "$PYTHON" usr/bin/textedit "$@"
EOF
        chmod +x "$APPDIR/AppRun"
        
        # Create simple icon (text-based)
        cat > "$APPDIR/textedit.svg" << 'EOF'
<svg width="256" height="256" xmlns="http://www.w3.org/2000/svg">
  <rect width="256" height="256" fill="#1e1e1e" rx="20"/>
  <rect x="32" y="48" width="192" height="128" fill="#2d2d2d" rx="8"/>
  <rect x="48" y="64" width="160" height="8" fill="#ffffff"/>
  <rect x="48" y="88" width="120" height="8" fill="#ffffff"/>
  <rect x="48" y="112" width="140" height="8" fill="#ffffff"/>
  <rect x="48" y="136" width="80" height="8" fill="#ffffff"/>
  <text x="128" y="220" font-family="Arial" font-size="24" fill="#ffffff" text-anchor="middle">TextEdit</text>
</svg>
EOF
        
        cp "$APPDIR/textedit.svg" "$APPDIR/usr/share/icons/hicolor/256x256/apps/"
        
        # Try to create AppImage if appimagetool is available
        if command -v appimagetool >/dev/null 2>&1; then
            echo "📦 Creating AppImage..."
            APPIMAGE_NAME="TextEdit-$VERSION-$ARCH.AppImage"
            appimagetool "$APPDIR" "$DIST_DIR/$APPIMAGE_NAME"
            echo "✅ AppImage created: $DIST_DIR/$APPIMAGE_NAME"
        else
            echo "⚠️  appimagetool not found, creating portable directory instead"
            cp -R "$APPDIR" "$DIST_DIR/TextEdit-portable"
        fi
        
        # Create DEB package structure
        DEB_DIR="$BUILD_DIR/textedit-deb"
        mkdir -p "$DEB_DIR/DEBIAN"
        mkdir -p "$DEB_DIR/usr/local/bin"
        mkdir -p "$DEB_DIR/usr/share/applications"
        mkdir -p "$DEB_DIR/usr/share/icons/hicolor/256x256/apps"
        
        # Copy files for DEB
        cp "/mnt/mycloud-kali/current active projects/TextEdit/textedit-native.py" "$DEB_DIR/usr/local/bin/textedit"
        chmod +x "$DEB_DIR/usr/local/bin/textedit"
        cp "$APPDIR/usr/share/applications/textedit.desktop" "$DEB_DIR/usr/share/applications/"
        cp "$APPDIR/textedit.svg" "$DEB_DIR/usr/share/icons/hicolor/256x256/apps/"
        
        # Create control file
        cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: textedit
Version: $VERSION
Section: editors
Priority: optional
Architecture: all
Depends: python3, python3-tk
Maintainer: TextEdit Team <noreply@example.com>
Description: A modern, lightweight text editor with permanent dark mode
 TextEdit is a cross-platform text editor with a permanent dark theme,
 designed for developers and writers who prefer consistent dark interfaces.
 Features include syntax highlighting, find/replace, and multi-format support.
EOF
        
        # Create postinst script
        cat > "$DEB_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
update-desktop-database /usr/share/applications 2>/dev/null || true
gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true
EOF
        chmod 755 "$DEB_DIR/DEBIAN/postinst"
        
        # Build DEB package
        if command -v dpkg-deb >/dev/null 2>&1; then
            echo "📦 Creating DEB package..."
            DEB_NAME="textedit_${VERSION}_all.deb"
            dpkg-deb --build "$DEB_DIR" "$DIST_DIR/$DEB_NAME"
            echo "✅ DEB package created: $DIST_DIR/$DEB_NAME"
        fi
        
        # Create install script
        cat > "$DIST_DIR/install-linux.sh" << 'EOF'
#!/bin/bash
# TextEdit Linux Installation Script

echo "Installing TextEdit for Linux..."

# Check for Python 3
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ Python 3 is required but not found."
    echo "   Install with: sudo apt-get install python3 python3-tk"
    echo "   Or: sudo yum install python3 python3-tkinter"
    exit 1
fi

# Check for tkinter
if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "❌ Python tkinter module is missing."
    echo "   Install with: sudo apt-get install python3-tk"
    echo "   Or: sudo yum install python3-tkinter"
    exit 1
fi

# Install DEB package if available
if [ -f "textedit_"*"_all.deb" ]; then
    echo "📦 Installing DEB package..."
    sudo dpkg -i textedit_*_all.deb
    echo "✅ TextEdit installed successfully!"
    echo "   Launch with: textedit"
elif [ -d "TextEdit-portable" ]; then
    echo "📦 Installing portable version..."
    sudo cp -R TextEdit-portable /opt/textedit
    sudo ln -sf /opt/textedit/AppRun /usr/local/bin/textedit
    echo "✅ TextEdit installed successfully!"
    echo "   Launch with: textedit"
else
    echo "❌ No installation package found"
    exit 1
fi
EOF
        chmod +x "$DIST_DIR/install-linux.sh"
        ;;
        
    *)
        echo "❌ Unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

# Create README for distribution
cat > "$DIST_DIR/README.md" << EOF
# TextEdit - Cross-Platform Dark Mode Text Editor

Version: $VERSION  
Build Date: $BUILD_DATE  
Platform: $PLATFORM ($ARCH)

## What is TextEdit?

TextEdit is a modern, lightweight text editor with permanent dark mode, designed for macOS and Linux. It features:

- **Permanent Dark Mode** - Always stays dark, comfortable for long editing sessions
- **Cross-Platform** - Native support for macOS and Linux
- **Lightweight** - Fast startup and minimal resource usage
- **Command Line Support** - Launch with \`textedit [file]\`
- **Modern Features** - Find/replace, word count, zoom controls
- **Multiple Formats** - Support for .txt, .md, .py, .js, .html, .css, .json

## Installation

### macOS
1. Install Python 3: \`brew install python python-tk\`
2. Run: \`./install-macos.sh\`
3. Or drag TextEdit.app to Applications folder

### Linux  
1. Install dependencies: \`sudo apt-get install python3 python3-tk\`
2. Run: \`./install-linux.sh\`
3. Or install DEB package: \`sudo dpkg -i textedit_*.deb\`

## Usage

- Launch from Applications (macOS) or command line
- Open files: \`textedit myfile.txt\`
- Use Cmd/Ctrl keyboard shortcuts for all operations
- Files automatically save configuration and recent files

## Requirements

- Python 3.6 or later
- tkinter (usually included with Python)
- macOS 10.14+ or Linux with X11/Wayland

## Command Line

\`\`\`bash
textedit                    # Launch with empty document
textedit file.txt          # Open specific file
textedit *.py              # Open multiple Python files
\`\`\`

## Keyboard Shortcuts

| Action | macOS | Linux |
|--------|-------|-------|
| New File | Cmd+N | Ctrl+N |
| Open File | Cmd+O | Ctrl+O |
| Save | Cmd+S | Ctrl+S |
| Find | Cmd+F | Ctrl+F |
| Zoom In | Cmd++ | Ctrl++ |
| Zoom Out | Cmd+- | Ctrl+- |

Built with ❤️ for developers who love dark themes.
EOF

echo
echo "🎉 Build completed successfully!"
echo "📁 Distribution files created in: $DIST_DIR/"
echo

# List created files
echo "📦 Created packages:"
ls -la "$DIST_DIR/"

echo
echo "✅ TextEdit is ready for deployment!"

# Test the native app if possible
if [ "$PLATFORM" = "Darwin" ] && [ -d "$DIST_DIR/TextEdit.app" ]; then
    echo
    echo "🧪 To test the macOS app:"
    echo "   open '$DIST_DIR/TextEdit.app'"
elif [ "$PLATFORM" = "Linux" ] && [ -x "$DIST_DIR/TextEdit-portable/AppRun" ]; then
    echo
    echo "🧪 To test the Linux app:"
    echo "   '$DIST_DIR/TextEdit-portable/AppRun'"
fi