#!/usr/bin/env python3
"""
Simple TextEdit Build Script
Creates deployment packages for macOS and Linux
"""

import os
import sys
import shutil
import platform
import subprocess
from pathlib import Path

def create_deployment():
    """Create deployment package"""
    print("🚀 TextEdit Simple Deployment")
    print("============================")
    
    project_dir = Path("/mnt/mycloud-kali/current active projects/TextEdit")
    dist_dir = project_dir / "dist"
    
    # Clean and create dist directory
    if dist_dir.exists():
        shutil.rmtree(dist_dir)
    dist_dir.mkdir()
    
    # Copy main script
    main_script = project_dir / "textedit-native.py"
    shutil.copy2(main_script, dist_dir / "textedit")
    
    # Make executable
    (dist_dir / "textedit").chmod(0o755)
    
    # Create launcher script for Linux
    linux_launcher = dist_dir / "textedit-linux.sh"
    linux_launcher.write_text("""#!/bin/bash
# TextEdit Linux Launcher

# Check for Python 3 and tkinter
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ Python 3 required. Install with:"
    echo "   sudo apt-get install python3 python3-tk"
    exit 1
fi

if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "❌ Python tkinter missing. Install with:"
    echo "   sudo apt-get install python3-tk"
    exit 1
fi

# Launch TextEdit
DIR="$(dirname "$0")"
exec python3 "$DIR/textedit" "$@"
""")
    linux_launcher.chmod(0o755)
    
    # Create launcher script for macOS
    macos_launcher = dist_dir / "textedit-macos.sh"
    macos_launcher.write_text("""#!/bin/bash
# TextEdit macOS Launcher

# Check for Python 3 and tkinter
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ Python 3 required. Install from python.org or:"
    echo "   brew install python python-tk"
    exit 1
fi

if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "❌ Python tkinter missing. Install with:"
    echo "   brew install python-tk"
    exit 1
fi

# Launch TextEdit
DIR="$(dirname "$0")"
exec python3 "$DIR/textedit" "$@"
""")
    macos_launcher.chmod(0o755)
    
    # Create desktop file for Linux
    desktop_file = dist_dir / "textedit.desktop"
    desktop_file.write_text("""[Desktop Entry]
Name=TextEdit
Comment=Dark mode text editor
Exec=textedit %F
Icon=text-editor
Type=Application
Categories=TextEditor;Utility;
MimeType=text/plain;text/markdown;text/x-python;
StartupNotify=true
""")
    
    # Create installation instructions
    readme = dist_dir / "INSTALL.md"
    readme.write_text("""# TextEdit Installation

## Quick Install (Linux)
```bash
sudo cp textedit /usr/local/bin/
sudo cp textedit.desktop /usr/share/applications/
```

## Quick Install (macOS)
```bash
sudo cp textedit /usr/local/bin/
```

## Manual Install
1. Copy `textedit` to your PATH
2. Run: `./textedit-linux.sh` or `./textedit-macos.sh`

## Requirements
- Python 3.6+ with tkinter
- Linux: `sudo apt-get install python3 python3-tk`  
- macOS: `brew install python python-tk`

## Usage
- Launch: `textedit` or `textedit filename.txt`
- Features permanent dark mode theme
- Supports .txt, .md, .py, .js, .html, .css files
""")
    
    # Create test script
    test_script = dist_dir / "test-textedit.py"
    test_script.write_text("""#!/usr/bin/env python3
# TextEdit Test Script

import sys
import subprocess
from pathlib import Path

def test_dependencies():
    print("🧪 Testing TextEdit Dependencies")
    print("================================")
    
    # Test Python 3
    try:
        version = sys.version_info
        if version.major >= 3 and version.minor >= 6:
            print(f"✅ Python {version.major}.{version.minor}.{version.micro}")
        else:
            print(f"❌ Python {version.major}.{version.minor} (need 3.6+)")
            return False
    except Exception as e:
        print(f"❌ Python version check failed: {e}")
        return False
    
    # Test tkinter
    try:
        import tkinter
        print("✅ tkinter available")
    except ImportError:
        print("❌ tkinter not available")
        print("   Install with: sudo apt-get install python3-tk")
        return False
    
    # Test TextEdit script
    script_path = Path(__file__).parent / "textedit"
    if script_path.exists():
        print(f"✅ TextEdit script found: {script_path}")
    else:
        print(f"❌ TextEdit script not found: {script_path}")
        return False
    
    print("\\n🎉 All tests passed! TextEdit should work correctly.")
    return True

if __name__ == "__main__":
    success = test_dependencies()
    sys.exit(0 if success else 1)
""")
    test_script.chmod(0o755)
    
    print(f"✅ Deployment package created: {dist_dir}")
    print("\nFiles created:")
    for file in dist_dir.iterdir():
        print(f"  📄 {file.name}")
    
    print(f"\n🎯 Ready for deployment!")
    print(f"📁 Package location: {dist_dir}")
    
    return dist_dir

if __name__ == "__main__":
    create_deployment()