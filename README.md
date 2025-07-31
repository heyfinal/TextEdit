<p align="center">
  <img width="128" align="center" src="src/Notepads/Assets/appicon_ws.gif">
</p>
<h1 align="center">
  TextEdit
</h1>
<p align="center">
  A modern, cross-platform text editor with permanent dark mode.
</p>

## 🚀 Quick Install

**One-command installation for macOS and Linux:**

```bash
git clone https://github.com/heyfinal/TextEdit.git
cd TextEdit
./install.sh
```

Then launch with: `textedit` or `textedit filename.txt`

## What is TextEdit?

TextEdit is a modern, cross-platform text editor with **permanent dark mode**. Available in two versions:

1. **Native (macOS/Linux)** - Python-based with tkinter (recommended)
2. **Windows UWP** - Forked from Notepads project

This editor is designed for developers and writers who prefer consistent dark themes without system-dependent switching.

## ✨ Key Features

### Native Version (macOS/Linux)
* **🌙 Permanent Dark Mode** - Always stays dark, comfortable for long sessions
* **⚡ Lightning Fast** - Native Python/tkinter, instant startup
* **🔍 Smart Search** - Find and replace with highlighting
* **📊 Word Count** - Live statistics and document info
* **🔧 Zoom Controls** - Cmd/Ctrl +/- for perfect readability
* **📁 Recent Files** - Quick access to your work
* **🎨 Multi-Format** - .txt, .md, .py, .js, .html, .css, .json support
* **⌨️ Command Line** - `textedit file.txt` integration

### Windows UWP Version
* **🌙 Permanent Dark Mode** - Always stays dark, regardless of system theme
* **🎨 Fluent Design** - Built-in tab system with modern UI
* **📝 Markdown Preview** - Live preview with side-by-side diff
* **✏️ Handwriting Support** - Multi-line handwriting input
* **🔄 Session Management** - Snapshot and multi-instance support

![Screenshot Dark](ScreenShots/1.png?raw=true "Dark")
![Screenshot Markdown](ScreenShots/2.png?raw=true "Markdown")
![Screenshot DiffViewer](ScreenShots/3.png?raw=true "DiffViewer")

## 📦 Installation Options

### Auto-Install (Recommended)
```bash
git clone https://github.com/heyfinal/TextEdit.git
cd TextEdit
./install.sh
```

### Manual Install
**macOS:**
```bash
# Install dependencies
brew install python python-tk

# Install TextEdit
sudo cp dist/textedit /usr/local/bin/textedit
sudo chmod +x /usr/local/bin/textedit
```

**Linux (Debian/Ubuntu):**
```bash
# Install dependencies  
sudo apt-get install python3 python3-tk

# Install TextEdit
sudo cp dist/textedit /usr/local/bin/textedit
sudo cp dist/textedit.desktop /usr/share/applications/
sudo chmod +x /usr/local/bin/textedit
```

**Windows UWP:**
1. Clone this repository
2. Open `src/Notepads.sln` in Visual Studio 2019+
3. Build and install the .appx package

## 🎯 Usage

### Command Line
```bash
textedit                    # Start with empty document
textedit myfile.txt        # Open specific file  
textedit *.py              # Open multiple Python files
textedit --help            # Show help
```

### Keyboard Shortcuts

| Action | macOS | Linux | Windows |
|--------|-------|-------|---------|
| New File | Cmd+N | Ctrl+N | Ctrl+N |
| Open File | Cmd+O | Ctrl+O | Ctrl+O |
| Save | Cmd+S | Ctrl+S | Ctrl+S |
| Find | Cmd+F | Ctrl+F | Ctrl+F |
| Replace | Cmd+R | Ctrl+R | Ctrl+H |
| Zoom In | Cmd++ | Ctrl++ | Ctrl++ |
| Zoom Out | Cmd+- | Ctrl+- | Ctrl+- |
| Word Count | - | - | - |
| Select All | Cmd+A | Ctrl+A | Ctrl+A |

### Windows UWP Shortcuts
* Ctrl+T - New tab
* Ctrl+Tab - Switch tabs
* Ctrl+1-9 - Quick tab switching
* Alt+P - Toggle Markdown preview
* Alt+D - Toggle diff viewer

## 🔧 Requirements

### Native Version (macOS/Linux)
* **macOS:** 10.14+ with Python 3.6+
* **Linux:** Any distribution with Python 3.6+ and X11/Wayland
* **Dependencies:** python3, python3-tk (auto-installed by installer)

### Windows UWP Version
* **Windows:** 10 version 17763.0 or higher, Windows 11
* **Development:** Visual Studio 2019+ with UWP workload
* **Runtime:** .NET Core UWP, Windows SDK

## 🧪 Testing

Test your installation:
```bash
python3 dist/test-textedit.py
```

## 🗑️ Uninstall

After installation, run the generated uninstaller:
```bash
./uninstall-textedit.sh
```

Or manually remove:
```bash
sudo rm /usr/local/bin/textedit
sudo rm /usr/share/applications/textedit.desktop  # Linux only
rm -rf ~/.textedit  # User config
```

## 🐛 Troubleshooting

**"Python 3 not found"**
- macOS: `brew install python python-tk`
- Linux: `sudo apt-get install python3 python3-tk`

**"tkinter not available"**
- macOS: `brew install python-tk`
- Linux: `sudo apt-get install python3-tk`
- Arch: `sudo pacman -S tk`

**Permission denied**
- Run installer with sudo: `sudo ./install.sh`
- Or install to user directory manually

**Command not found after install**
- Check PATH includes `/usr/local/bin`
- Restart terminal or run `source ~/.bashrc`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test thoroughly
4. Commit: `git commit -m "Add feature"`
5. Push: `git push origin feature-name`
6. Create a Pull Request

### Development Setup
```bash
git clone https://github.com/heyfinal/TextEdit.git
cd TextEdit
python3 textedit-native.py  # Test directly
```

## 📄 License

This project maintains the same license as the original Notepads project.

## 🙏 Credits

**Native Version:** Built with Python/tkinter for cross-platform compatibility.

**Windows UWP Version:** Based on the outstanding [Notepads](https://github.com/0x7c13/Notepads) project by Jackie Liu. All core UWP functionality comes from the original Notepads codebase.

### Dependencies

**Native Version:**
* Python 3.6+
* tkinter (Python standard library)

**Windows UWP Version:**
* [Windows Community Toolkit](https://github.com/windows-toolkit/WindowsCommunityToolkit)
* [XAML Controls Gallery](https://github.com/microsoft/Xaml-Controls-Gallery)
* [Windows UI Library](https://github.com/Microsoft/microsoft-ui-xaml)
* [ColorCode Universal](https://github.com/WilliamABradley/ColorCode-Universal)
* [UTF Unknown](https://github.com/CharsetDetector/UTF-unknown)
* [DiffPlex](https://github.com/mmanela/diffplex)
* [Win2D](https://github.com/microsoft/Win2D)

---

<p align="center">
  <strong>Built with ❤️ for developers who love dark themes</strong>
</p>