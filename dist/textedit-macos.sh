#!/bin/bash
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
