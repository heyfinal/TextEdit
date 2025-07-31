#!/usr/bin/env python3
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
    
    print("\n🎉 All tests passed! TextEdit should work correctly.")
    return True

if __name__ == "__main__":
    success = test_dependencies()
    sys.exit(0 if success else 1)
