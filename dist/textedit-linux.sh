#!/bin/bash
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
