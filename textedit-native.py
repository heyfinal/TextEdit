#!/usr/bin/env python3
"""
TextEdit - Cross-Platform Dark Mode Text Editor
A modern, lightweight text editor with permanent dark mode for macOS and Linux.
Based on the TextEdit/Notepads concept but built natively for Unix systems.
"""

import sys
import os
import json
import platform
from pathlib import Path
from datetime import datetime

try:
    import tkinter as tk
    from tkinter import ttk, filedialog, messagebox, font as tkfont
    from tkinter.scrolledtext import ScrolledText
except ImportError:
    print("Error: tkinter not available. Install with:")
    print("  macOS: brew install python-tk")
    print("  Linux: sudo apt-get install python3-tk")
    sys.exit(1)

class TextEditApp:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("TextEdit")
        self.root.geometry("1200x800")
        
        # Dark theme colors
        self.colors = {
            'bg': '#1e1e1e',
            'fg': '#ffffff',
            'select_bg': '#404040',
            'select_fg': '#ffffff',
            'menu_bg': '#2d2d2d',
            'menu_fg': '#ffffff',
            'cursor': '#ffffff',
            'highlight': '#0078d4'
        }
        
        # File management
        self.current_file = None
        self.files = []  # Tab support
        self.modified = False
        
        # Recent files
        self.config_dir = Path.home() / '.textedit'
        self.config_dir.mkdir(exist_ok=True)
        self.config_file = self.config_dir / 'config.json'
        self.recent_files = self.load_config().get('recent_files', [])
        
        self.setup_ui()
        self.setup_bindings()
        self.apply_dark_theme()
        
    def load_config(self):
        """Load configuration from file"""
        try:
            if self.config_file.exists():
                with open(self.config_file, 'r') as f:
                    return json.load(f)
        except Exception:
            pass
        return {}
    
    def save_config(self):
        """Save configuration to file"""
        config = {
            'recent_files': self.recent_files[:10],  # Keep last 10
            'window_geometry': self.root.geometry(),
            'last_directory': str(Path.cwd())
        }
        try:
            with open(self.config_file, 'w') as f:
                json.dump(config, f, indent=2)
        except Exception:
            pass
    
    def setup_ui(self):
        """Setup the user interface"""
        # Menu bar
        self.menubar = tk.Menu(self.root)
        self.root.config(menu=self.menubar)
        
        # File menu
        file_menu = tk.Menu(self.menubar, tearoff=0)
        self.menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="New", command=self.new_file, accelerator="Cmd+N")
        file_menu.add_command(label="Open", command=self.open_file, accelerator="Cmd+O")
        file_menu.add_separator()
        file_menu.add_command(label="Save", command=self.save_file, accelerator="Cmd+S")
        file_menu.add_command(label="Save As", command=self.save_as_file, accelerator="Cmd+Shift+S")
        file_menu.add_separator()
        
        # Recent files submenu
        self.recent_menu = tk.Menu(file_menu, tearoff=0)
        file_menu.add_cascade(label="Recent Files", menu=self.recent_menu)
        self.update_recent_menu()
        
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.quit_app, accelerator="Cmd+Q")
        
        # Edit menu
        edit_menu = tk.Menu(self.menubar, tearoff=0)
        self.menubar.add_cascade(label="Edit", menu=edit_menu)
        edit_menu.add_command(label="Undo", command=self.undo, accelerator="Cmd+Z")
        edit_menu.add_command(label="Redo", command=self.redo, accelerator="Cmd+Shift+Z")
        edit_menu.add_separator()
        edit_menu.add_command(label="Cut", command=self.cut, accelerator="Cmd+X")
        edit_menu.add_command(label="Copy", command=self.copy, accelerator="Cmd+C")
        edit_menu.add_command(label="Paste", command=self.paste, accelerator="Cmd+V")
        edit_menu.add_separator()
        edit_menu.add_command(label="Select All", command=self.select_all, accelerator="Cmd+A")
        edit_menu.add_command(label="Find", command=self.find, accelerator="Cmd+F")
        edit_menu.add_command(label="Replace", command=self.replace, accelerator="Cmd+R")
        
        # View menu
        view_menu = tk.Menu(self.menubar, tearoff=0)
        self.menubar.add_cascade(label="View", menu=view_menu)
        view_menu.add_command(label="Zoom In", command=self.zoom_in, accelerator="Cmd++")
        view_menu.add_command(label="Zoom Out", command=self.zoom_out, accelerator="Cmd+-")
        view_menu.add_command(label="Reset Zoom", command=self.reset_zoom, accelerator="Cmd+0")
        view_menu.add_separator()
        view_menu.add_command(label="Word Count", command=self.show_word_count)
        
        # Main frame
        self.main_frame = tk.Frame(self.root)
        self.main_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Status bar
        self.status_bar = tk.Frame(self.root, relief=tk.SUNKEN, bd=1)
        self.status_bar.pack(side=tk.BOTTOM, fill=tk.X)
        
        self.status_label = tk.Label(self.status_bar, text="Ready", anchor=tk.W)
        self.status_label.pack(side=tk.LEFT, padx=5)
        
        self.cursor_label = tk.Label(self.status_bar, text="Line 1, Col 1", anchor=tk.E)
        self.cursor_label.pack(side=tk.RIGHT, padx=5)
        
        # Text editor
        self.text_editor = ScrolledText(
            self.main_frame,
            wrap=tk.WORD,
            undo=True,
            font=('Monaco', 14) if platform.system() == 'Darwin' else ('Consolas', 11),
            insertwidth=2,
            selectbackground=self.colors['select_bg'],
            selectforeground=self.colors['select_fg'],
            insertbackground=self.colors['cursor'],
            bg=self.colors['bg'],
            fg=self.colors['fg']
        )
        self.text_editor.pack(fill=tk.BOTH, expand=True)
        
        # Add default TextEdit ASCII banner
        default_text = """                                                                      
                                                     ,,    ,,         
MMP""MM""YMM                 mm   `7MM"""YMM       `7MM    db   mm    
P'   MM   `7                 MM     MM    `7         MM         MM    
     MM  .gP"Ya `7M'   `MF'mmMMmm   MM   d      ,M""bMM  `7MM mmMMmm  
     MM ,M'   Yb  `VA ,V'    MM     MMmmMM    ,AP    MM    MM   MM    
     MM 8M""""""    XMX      MM     MM   Y  , 8MI    MM    MM   MM    
     MM YM.    ,  ,V' VA.    MM     MM     ,M `Mb    MM    MM   MM    
   .JMML.`Mbmmd'.AM.   .MA.  `Mbmo.JMMmmmmMMM  `Wbmd"MML..JMML. `Mbmo 
                                                                      
                                                                      


Welcome to TextEdit - The permanent dark mode text editor!

Click anywhere to start editing...
"""
        self.text_editor.insert(1.0, default_text)
        self.has_default_text = True
        
        # Configure scrollbar colors
        self.text_editor.vbar.config(
            bg=self.colors['menu_bg'],
            troughcolor=self.colors['bg'],
            activebackground=self.colors['highlight']
        )
        
        # Bind text change events
        self.text_editor.bind('<KeyPress>', self.on_text_change)
        self.text_editor.bind('<Button-1>', self.on_click)
        self.text_editor.bind('<KeyRelease>', self.on_cursor_move)
        
    def apply_dark_theme(self):
        """Apply dark theme to all widgets"""
        # Root window
        self.root.configure(bg=self.colors['bg'])
        
        # Configure menu colors
        self.menubar.configure(
            bg=self.colors['menu_bg'],
            fg=self.colors['menu_fg'],
            activebackground=self.colors['highlight'],
            activeforeground=self.colors['fg']
        )
        
        # Status bar
        self.status_bar.configure(bg=self.colors['menu_bg'])
        self.status_label.configure(
            bg=self.colors['menu_bg'],
            fg=self.colors['menu_fg']
        )
        self.cursor_label.configure(
            bg=self.colors['menu_bg'],
            fg=self.colors['menu_fg']
        )
        
        # Main frame
        self.main_frame.configure(bg=self.colors['bg'])
        
    def setup_bindings(self):
        """Setup keyboard bindings"""
        # File operations
        self.root.bind('<Command-n>' if platform.system() == 'Darwin' else '<Control-n>', lambda e: self.new_file())
        self.root.bind('<Command-o>' if platform.system() == 'Darwin' else '<Control-o>', lambda e: self.open_file())
        self.root.bind('<Command-s>' if platform.system() == 'Darwin' else '<Control-s>', lambda e: self.save_file())
        self.root.bind('<Command-Shift-S>' if platform.system() == 'Darwin' else '<Control-Shift-S>', lambda e: self.save_as_file())
        self.root.bind('<Command-q>' if platform.system() == 'Darwin' else '<Control-q>', lambda e: self.quit_app())
        
        # Edit operations
        self.root.bind('<Command-z>' if platform.system() == 'Darwin' else '<Control-z>', lambda e: self.undo())
        self.root.bind('<Command-Shift-Z>' if platform.system() == 'Darwin' else '<Control-Shift-Z>', lambda e: self.redo())
        self.root.bind('<Command-f>' if platform.system() == 'Darwin' else '<Control-f>', lambda e: self.find())
        self.root.bind('<Command-r>' if platform.system() == 'Darwin' else '<Control-r>', lambda e: self.replace())
        
        # View operations
        self.root.bind('<Command-plus>' if platform.system() == 'Darwin' else '<Control-plus>', lambda e: self.zoom_in())
        self.root.bind('<Command-minus>' if platform.system() == 'Darwin' else '<Control-minus>', lambda e: self.zoom_out())
        self.root.bind('<Command-0>' if platform.system() == 'Darwin' else '<Control-0>', lambda e: self.reset_zoom())
        
        # Window close
        self.root.protocol("WM_DELETE_WINDOW", self.quit_app)
    
    def update_title(self):
        """Update window title"""
        title = "TextEdit"
        if self.current_file:
            title = f"{Path(self.current_file).name} - TextEdit"
        if self.modified:
            title = "• " + title
        self.root.title(title)
    
    def update_status(self, message="Ready"):
        """Update status bar"""
        self.status_label.config(text=message)
    
    def update_cursor_position(self):
        """Update cursor position in status bar"""
        cursor_pos = self.text_editor.index(tk.INSERT)
        line, col = cursor_pos.split('.')
        self.cursor_label.config(text=f"Line {line}, Col {int(col)+1}")
    
    def on_text_change(self, event=None):
        """Handle text changes"""
        # Clear default text on first edit
        if hasattr(self, 'has_default_text') and self.has_default_text:
            self.clear_default_text()
        
        self.modified = True
        self.update_title()
        self.root.after_idle(self.update_cursor_position)
    
    def on_cursor_move(self, event=None):
        """Handle cursor movement"""
        self.root.after_idle(self.update_cursor_position)
    
    def on_click(self, event=None):
        """Handle mouse clicks"""
        # Clear default text on first click
        if hasattr(self, 'has_default_text') and self.has_default_text:
            self.clear_default_text()
        self.on_cursor_move(event)
    
    def clear_default_text(self):
        """Clear the default ASCII banner text"""
        if hasattr(self, 'has_default_text') and self.has_default_text:
            self.text_editor.delete(1.0, tk.END)
            self.has_default_text = False
            self.modified = False
            self.update_title()
            self.update_status("Ready to edit...")
    
    def update_recent_menu(self):
        """Update recent files menu"""
        self.recent_menu.delete(0, tk.END)
        for file_path in self.recent_files:
            if Path(file_path).exists():
                self.recent_menu.add_command(
                    label=Path(file_path).name,
                    command=lambda f=file_path: self.open_recent_file(f)
                )
    
    def add_to_recent(self, file_path):
        """Add file to recent files list"""
        file_path = str(Path(file_path).resolve())
        if file_path in self.recent_files:
            self.recent_files.remove(file_path)
        self.recent_files.insert(0, file_path)
        self.recent_files = self.recent_files[:10]
        self.update_recent_menu()
        self.save_config()
    
    def new_file(self):
        """Create new file"""
        if self.modified:
            if not self.ask_save_changes():
                return
        
        self.text_editor.delete(1.0, tk.END)
        
        # Add default TextEdit ASCII banner for new files
        default_text = """                                                                      
                                                     ,,    ,,         
MMP""MM""YMM                 mm   `7MM"""YMM       `7MM    db   mm    
P'   MM   `7                 MM     MM    `7         MM         MM    
     MM  .gP"Ya `7M'   `MF'mmMMmm   MM   d      ,M""bMM  `7MM mmMMmm  
     MM ,M'   Yb  `VA ,V'    MM     MMmmMM    ,AP    MM    MM   MM    
     MM 8M""""""    XMX      MM     MM   Y  , 8MI    MM    MM   MM    
     MM YM.    ,  ,V' VA.    MM     MM     ,M `Mb    MM    MM   MM    
   .JMML.`Mbmmd'.AM.   .MA.  `Mbmo.JMMmmmmMMM  `Wbmd"MML..JMML. `Mbmo 
                                                                      
                                                                      


Welcome to TextEdit - The permanent dark mode text editor!

Click anywhere to start editing...
"""
        self.text_editor.insert(1.0, default_text)
        self.has_default_text = True
        
        self.current_file = None
        self.modified = False
        self.update_title()
        self.update_status("New file created")
    
    def open_file(self):
        """Open file dialog"""
        if self.modified:
            if not self.ask_save_changes():
                return
        
        file_path = filedialog.askopenfilename(
            title="Open File",
            filetypes=[
                ("Text files", "*.txt"),
                ("Markdown files", "*.md"),
                ("Python files", "*.py"),
                ("All files", "*.*")
            ]
        )
        
        if file_path:
            self.load_file(file_path)
    
    def open_recent_file(self, file_path):
        """Open recent file"""
        if self.modified:
            if not self.ask_save_changes():
                return
        self.load_file(file_path)
    
    def load_file(self, file_path):
        """Load file content"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            self.text_editor.delete(1.0, tk.END)
            self.text_editor.insert(1.0, content)
            self.current_file = file_path
            self.modified = False
            self.update_title()
            self.update_status(f"Opened: {Path(file_path).name}")
            self.add_to_recent(file_path)
            
        except Exception as e:
            messagebox.showerror("Error", f"Could not open file:\n{e}")
    
    def save_file(self):
        """Save current file"""
        if self.current_file:
            self.write_file(self.current_file)
        else:
            self.save_as_file()
    
    def save_as_file(self):
        """Save as dialog"""
        file_path = filedialog.asksaveasfilename(
            title="Save As",
            defaultextension=".txt",
            filetypes=[
                ("Text files", "*.txt"),
                ("Markdown files", "*.md"),
                ("Python files", "*.py"),
                ("All files", "*.*")
            ]
        )
        
        if file_path:
            self.write_file(file_path)
            self.current_file = file_path
            self.add_to_recent(file_path)
    
    def write_file(self, file_path):
        """Write content to file"""
        try:
            content = self.text_editor.get(1.0, tk.END + '-1c')
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            self.modified = False
            self.update_title()
            self.update_status(f"Saved: {Path(file_path).name}")
            
        except Exception as e:
            messagebox.showerror("Error", f"Could not save file:\n{e}")
    
    def ask_save_changes(self):
        """Ask user to save changes"""
        result = messagebox.askyesnocancel(
            "Save Changes",
            "Do you want to save changes to the current document?"
        )
        
        if result is True:  # Yes
            self.save_file()
            return not self.modified  # Return True if save succeeded
        elif result is False:  # No
            return True
        else:  # Cancel
            return False
    
    # Edit operations
    def undo(self):
        """Undo last action"""
        try:
            self.text_editor.edit_undo()
        except tk.TclError:
            pass
    
    def redo(self):
        """Redo last action"""
        try:
            self.text_editor.edit_redo()
        except tk.TclError:
            pass
    
    def cut(self):
        """Cut selected text"""
        try:
            self.text_editor.event_generate("<<Cut>>")
        except tk.TclError:
            pass
    
    def copy(self):
        """Copy selected text"""
        try:
            self.text_editor.event_generate("<<Copy>>")
        except tk.TclError:
            pass
    
    def paste(self):
        """Paste text from clipboard"""
        try:
            self.text_editor.event_generate("<<Paste>>")
        except tk.TclError:
            pass
    
    def select_all(self):
        """Select all text"""
        self.text_editor.tag_add(tk.SEL, "1.0", tk.END)
        self.text_editor.mark_set(tk.INSERT, "1.0")
        self.text_editor.see(tk.INSERT)
    
    def find(self):
        """Find text dialog"""
        search_text = tk.simpledialog.askstring("Find", "Enter text to find:")
        if search_text:
            self.find_text(search_text)
    
    def find_text(self, search_text):
        """Find and highlight text"""
        # Remove previous highlights
        self.text_editor.tag_remove("found", "1.0", tk.END)
        
        if search_text:
            idx = "1.0"
            while True:
                idx = self.text_editor.search(search_text, idx, nocase=1, stopindex=tk.END)
                if not idx:
                    break
                
                lastidx = f"{idx}+{len(search_text)}c"
                self.text_editor.tag_add("found", idx, lastidx)
                idx = lastidx
            
            # Configure found tag
            self.text_editor.tag_config("found", 
                                      background=self.colors['highlight'],
                                      foreground=self.colors['fg'])
    
    def replace(self):
        """Replace text dialog"""
        # Simple replace - could be enhanced with a proper dialog
        find_text = tk.simpledialog.askstring("Replace", "Find:")
        if find_text:
            replace_text = tk.simpledialog.askstring("Replace", "Replace with:")
            if replace_text is not None:
                content = self.text_editor.get(1.0, tk.END)
                new_content = content.replace(find_text, replace_text)
                self.text_editor.delete(1.0, tk.END)
                self.text_editor.insert(1.0, new_content)
    
    # View operations
    def zoom_in(self):
        """Increase font size"""
        current_font = tkfont.Font(font=self.text_editor['font'])
        size = current_font['size']
        new_size = min(size + 2, 48)  # Max size 48
        current_font.configure(size=new_size)
        self.update_status(f"Font size: {new_size}")
    
    def zoom_out(self):
        """Decrease font size"""
        current_font = tkfont.Font(font=self.text_editor['font'])
        size = current_font['size']
        new_size = max(size - 2, 8)  # Min size 8
        current_font.configure(size=new_size)
        self.update_status(f"Font size: {new_size}")
    
    def reset_zoom(self):
        """Reset font size"""
        default_size = 14 if platform.system() == 'Darwin' else 11
        current_font = tkfont.Font(font=self.text_editor['font'])
        current_font.configure(size=default_size)
        self.update_status(f"Font size reset to {default_size}")
    
    def show_word_count(self):
        """Show word count dialog"""
        content = self.text_editor.get(1.0, tk.END + '-1c')
        lines = len(content.splitlines())
        words = len(content.split())
        chars = len(content)
        chars_no_spaces = len(content.replace(' ', '').replace('\n', '').replace('\t', ''))
        
        messagebox.showinfo("Document Statistics", 
                          f"Lines: {lines}\n"
                          f"Words: {words}\n"
                          f"Characters: {chars}\n"
                          f"Characters (no spaces): {chars_no_spaces}")
    
    def quit_app(self):
        """Quit application"""
        if self.modified:
            if not self.ask_save_changes():
                return
        
        self.save_config()
        self.root.destroy()
    
    def run(self):
        """Start the application"""
        self.root.mainloop()

def main():
    """Main entry point"""
    if len(sys.argv) > 1:
        # Command line file argument
        file_path = sys.argv[1]
        app = TextEditApp()
        if Path(file_path).exists():
            app.load_file(file_path)
        app.run()
    else:
        app = TextEditApp()
        app.run()

if __name__ == "__main__":
    main()