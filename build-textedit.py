#!/usr/bin/env python3
"""
TextEdit UWP Build Script
Builds the TextEdit Universal Windows Platform application.
Designed for cross-platform use, but UWP requires Windows/MSBuild.
"""

import os
import sys
import subprocess
import json
import platform
from pathlib import Path

class TextEditBuilder:
    def __init__(self):
        self.project_root = Path("/mnt/mycloud-kali/current active projects/TextEdit")
        self.src_dir = self.project_root / "src"
        self.solution_file = self.src_dir / "Notepads.sln"
        self.project_file = self.src_dir / "Notepads" / "Notepads.csproj"
        self.output_dir = self.project_root / "build-output"
        
        # Build configurations
        self.configurations = ["Debug", "Release", "Production"]
        self.platforms = ["x86", "x64", "ARM64"]
        
    def check_environment(self):
        """Check if build environment is ready"""
        print("🔍 Checking build environment...")
        
        # Check if running on Windows (required for UWP)
        if platform.system() != "Windows":
            print("⚠️  Warning: UWP builds require Windows and Visual Studio")
            print("   This script will prepare the build configuration")
            print("   but actual compilation must be done on Windows.")
            return False
            
        # Check for MSBuild
        try:
            result = subprocess.run(["msbuild", "/version"], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                print("✅ MSBuild found")
                return True
        except FileNotFoundError:
            pass
            
        print("❌ MSBuild not found. Please install Visual Studio or Build Tools.")
        return False
    
    def restore_packages(self):
        """Restore NuGet packages"""
        print("\n📦 Restoring NuGet packages...")
        
        try:
            cmd = ["nuget", "restore", str(self.solution_file)]
            result = subprocess.run(cmd, cwd=self.src_dir, 
                                  capture_output=True, text=True)
            
            if result.returncode == 0:
                print("✅ Packages restored successfully")
                return True
            else:
                print(f"❌ Package restore failed: {result.stderr}")
                return False
                
        except FileNotFoundError:
            print("⚠️  NuGet not found. Attempting MSBuild restore...")
            
            try:
                cmd = ["msbuild", str(self.solution_file), "/t:Restore"]
                result = subprocess.run(cmd, cwd=self.src_dir,
                                      capture_output=True, text=True)
                
                if result.returncode == 0:
                    print("✅ Packages restored via MSBuild")
                    return True
                else:
                    print(f"❌ MSBuild restore failed: {result.stderr}")
                    return False
                    
            except FileNotFoundError:
                print("❌ Neither NuGet nor MSBuild available")
                return False
    
    def build_configuration(self, config, platform):
        """Build specific configuration and platform"""
        print(f"\n🔨 Building {config}|{platform}...")
        
        cmd = [
            "msbuild",
            str(self.solution_file),
            f"/p:Configuration={config}",
            f"/p:Platform={platform}",
            "/p:AppxBundle=Always",
            "/p:AppxBundlePlatforms=x86|x64|ARM64",
            "/p:UapAppxPackageBuildMode=StoreUpload",
            "/p:AppxPackageDir=" + str(self.output_dir / config / platform),
            "/m",  # Multi-processor build
            "/v:minimal"  # Minimal verbosity
        ]
        
        try:
            result = subprocess.run(cmd, cwd=self.src_dir,
                                  capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"✅ {config}|{platform} build successful")
                return True
            else:
                print(f"❌ {config}|{platform} build failed:")
                print(result.stderr)
                return False
                
        except FileNotFoundError:
            print("❌ MSBuild not found")
            return False
    
    def create_deployment_package(self):
        """Create deployment package with all builds"""
        print("\n📦 Creating deployment package...")
        
        deployment_dir = self.project_root / "TextEdit-Deployment"
        deployment_dir.mkdir(exist_ok=True)
        
        # Copy built packages
        for config in self.configurations:
            config_dir = self.output_dir / config
            if config_dir.exists():
                # Copy to deployment directory
                import shutil
                dest_dir = deployment_dir / config
                if dest_dir.exists():
                    shutil.rmtree(dest_dir)
                shutil.copytree(config_dir, dest_dir)
        
        # Create installation script
        install_script = deployment_dir / "install.ps1"
        install_script.write_text("""
# TextEdit Installation Script
# Run as Administrator

Write-Host "Installing TextEdit..." -ForegroundColor Green

# Check for Release build first, then Production, then Debug
$BuildPaths = @(
    "Release\\x64\\TextEdit*.appx",
    "Production\\x64\\TextEdit*.appx", 
    "Debug\\x64\\TextEdit*.appx"
)

$PackageFound = $false
foreach ($Path in $BuildPaths) {
    $Package = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($Package) {
        Write-Host "Installing: $($Package.Name)" -ForegroundColor Yellow
        Add-AppxPackage -Path $Package.FullName -ForceApplicationShutdown
        $PackageFound = $true
        break
    }
}

if (-not $PackageFound) {
    Write-Host "No TextEdit package found!" -ForegroundColor Red
    exit 1
}

Write-Host "TextEdit installed successfully!" -ForegroundColor Green
""")
        
        # Create README
        readme = deployment_dir / "README.md"
        readme.write_text("""# TextEdit Deployment Package

## Installation (Windows 10/11)

1. **Enable Developer Mode** (if installing unsigned package):
   - Settings > Update & Security > For Developers > Developer mode

2. **Install via PowerShell** (Run as Administrator):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   .\\install.ps1
   ```

3. **Manual Installation**:
   - Navigate to Release\\x64\\ folder
   - Right-click on TextEdit*.appx
   - Select "Install"

## Package Contents

- **Debug/**: Debug builds for development
- **Release/**: Optimized release builds (recommended)
- **Production/**: Production builds for distribution

## System Requirements

- Windows 10 version 17763.0 or higher
- Windows 11 (all versions)
- x64, x86, or ARM64 architecture

## Features

- Permanent dark mode text editor
- Based on the excellent Notepads project
- Fluent design with tab system
- Markdown preview and diff viewer
- Command line support: `textedit` or `textedit [file]`

## Troubleshooting

If installation fails:
1. Ensure Windows is up to date
2. Enable Developer Mode in Windows Settings
3. Try installing dependencies first:
   - Microsoft Visual C++ 2015-2019 Runtime
   - .NET Core Runtime
""")
        
        print(f"✅ Deployment package created: {deployment_dir}")
        return deployment_dir
    
    def generate_build_info(self):
        """Generate build information file"""
        build_info = {
            "project": "TextEdit",
            "version": "1.0.0",
            "build_date": subprocess.check_output(["date", "+%Y-%m-%d %H:%M:%S"]).decode().strip(),
            "platform": platform.system(),
            "architecture": platform.machine(),
            "configurations": self.configurations,
            "platforms": self.platforms,
            "source_path": str(self.project_root),
            "build_requirements": {
                "os": "Windows 10/11",
                "tools": ["Visual Studio 2019+", "MSBuild", "NuGet"],
                "frameworks": [".NET Core UWP", "Windows SDK 10.0.22621.0"]
            }
        }
        
        build_info_file = self.project_root / "build-info.json"
        with open(build_info_file, 'w') as f:
            json.dump(build_info, f, indent=2)
        
        print(f"✅ Build info saved: {build_info_file}")
    
    def build_all(self):
        """Build all configurations and platforms"""
        print("🚀 Starting TextEdit build process...")
        print(f"📁 Project root: {self.project_root}")
        print(f"📁 Solution file: {self.solution_file}")
        
        # Create output directory
        self.output_dir.mkdir(exist_ok=True)
        
        # Generate build info
        self.generate_build_info()
        
        # Check environment
        has_build_tools = self.check_environment()
        
        if not has_build_tools:
            print("\n📋 Build Instructions for Windows:")
            print("1. Install Visual Studio 2019 or later with UWP workload")
            print("2. Open Developer Command Prompt")
            print("3. Navigate to project directory")
            print("4. Run: python build-textedit.py")
            print("\nOr use Visual Studio:")
            print(f"1. Open: {self.solution_file}")
            print("2. Build > Batch Build > Select all configurations")
            print("3. Build")
            return False
        
        # Restore packages
        if not self.restore_packages():
            print("❌ Cannot proceed without package restore")
            return False
        
        # Build all configurations
        success_count = 0
        total_builds = len(self.configurations) * len(self.platforms)
        
        for config in self.configurations:
            for platform in self.platforms:
                if self.build_configuration(config, platform):
                    success_count += 1
        
        print(f"\n📊 Build Results: {success_count}/{total_builds} successful")
        
        if success_count > 0:
            # Create deployment package
            deployment_dir = self.create_deployment_package()
            print(f"\n🎉 TextEdit build completed!")
            print(f"📦 Deployment package: {deployment_dir}")
            return True
        else:
            print("\n❌ All builds failed")
            return False

def main():
    """Main entry point"""
    if len(sys.argv) > 1 and sys.argv[1] == "--info":
        builder = TextEditBuilder()
        builder.generate_build_info()
        return
    
    builder = TextEditBuilder()
    success = builder.build_all()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()