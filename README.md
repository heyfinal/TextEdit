<p align="center">
  <img width="128" align="center" src="src/Notepads/Assets/appicon_ws.gif">
</p>
<h1 align="center">
  TextEdit
</h1>
<p align="center">
  A modern, lightweight text editor with permanent dark mode.
</p>

## What is TextEdit?

TextEdit is a modern Windows text editor forked from the excellent Notepads project, with one key difference: **permanent dark mode**. This editor is designed for users who prefer the dark theme and don't want it to change based on system settings.

## Key Features

* **Permanent Dark Mode** - Always stays dark, regardless of system theme
* Fluent design with a built-in tab system
* Blazingly fast and lightweight
* Launch from command line: `textedit` or `textedit %FilePath%`
* Multi-line handwriting support
* Built-in Markdown live preview
* Built-in diff viewer (preview your changes)
* Session snapshot and multi-instances

![Screenshot Dark](ScreenShots/1.png?raw=true "Dark")
![Screenshot Markdown](ScreenShots/2.png?raw=true "Markdown")
![Screenshot DiffViewer](ScreenShots/3.png?raw=true "DiffViewer")

## Shortcuts

* Ctrl+N/T to create new tab
* Ctrl+(Shift)+Tab to switch between tabs
* Ctrl+Num(1-9) to quickly switch to specified tab
* Ctrl+"+"/"-" for zooming. Ctrl+"0" to reset zooming to default
* Ctrl+L/R to change text flow direction (LTR/RTL)
* Alt+P to toggle preview split view for Markdown file
* Alt+D to toggle side-by-side diff viewer

## Platform limitations (UWP)

* You won't be able to save files to system folders due to UWP restriction (windows, system32, etc.)
* You cannot associate potentially harmful file types (.cmd, .bat etc.) with TextEdit
* TextEdit does not work well with large files; the file size limit is set to 1MB for now

## Why Dark Mode Only?

Many developers and writers prefer dark themes for reduced eye strain during long coding/writing sessions. TextEdit eliminates the distraction of theme switching and provides a consistent, comfortable dark environment.

## Building from Source

1. Clone this repository
2. Open `src/Notepads.sln` in Visual Studio 2019 or later
3. Build and run

## Credits

TextEdit is based on the outstanding [Notepads](https://github.com/0x7c13/Notepads) project by Jackie Liu. All core functionality and design patterns come from the original Notepads codebase. This fork simply enforces permanent dark mode for users who prefer it.

## Dependencies and References

* [Windows Community Toolkit](https://github.com/windows-toolkit/WindowsCommunityToolkit)
* [XAML Controls Gallery](https://github.com/microsoft/Xaml-Controls-Gallery)
* [Windows UI Library](https://github.com/Microsoft/microsoft-ui-xaml)
* [ColorCode Universal](https://github.com/WilliamABradley/ColorCode-Universal)
* [UTF Unknown](https://github.com/CharsetDetector/UTF-unknown)
* [DiffPlex](https://github.com/mmanela/diffplex)
* [Win2D](https://github.com/microsoft/Win2D)

## Original Notepads Project

Full credit goes to the original [Notepads](https://github.com/0x7c13/Notepads) project and its contributors. TextEdit is simply a specialized version with enforced dark mode.