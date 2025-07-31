# TextEdit Installation

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
