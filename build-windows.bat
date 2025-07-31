@echo off
REM TextEdit Windows Build Script
REM Run this on Windows with Visual Studio installed

echo.
echo ========================================
echo   TextEdit UWP Build Script
echo ========================================
echo.

REM Check for Visual Studio/MSBuild
where msbuild >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: MSBuild not found in PATH
    echo Please run from Visual Studio Developer Command Prompt
    echo Or install Visual Studio Build Tools
    pause
    exit /b 1
)

echo Found MSBuild, proceeding with build...
echo.

REM Set build variables
set SOLUTION=src\Notepads.sln
set CONFIG=Release
set PLATFORM=x64
set OUTPUT_DIR=build-output

REM Create output directory
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo Building TextEdit UWP Application...
echo Solution: %SOLUTION%
echo Configuration: %CONFIG%
echo Platform: %PLATFORM%
echo.

REM Restore NuGet packages
echo Restoring NuGet packages...
nuget restore "%SOLUTION%"
if %ERRORLEVEL% NEQ 0 (
    echo Package restore failed, trying MSBuild restore...
    msbuild "%SOLUTION%" /t:Restore
    if %ERRORLEVEL% NEQ 0 (
        echo Error: Package restore failed
        pause
        exit /b 1
    )
)

echo.
echo Building Release x64...
msbuild "%SOLUTION%" ^
    /p:Configuration=%CONFIG% ^
    /p:Platform=%PLATFORM% ^
    /p:AppxBundle=Always ^
    /p:AppxBundlePlatforms="x86|x64|ARM64" ^
    /p:UapAppxPackageBuildMode=StoreUpload ^
    /p:AppxPackageDir="%CD%\%OUTPUT_DIR%\%CONFIG%\%PLATFORM%\" ^
    /m ^
    /v:minimal

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo   BUILD FAILED
    echo ========================================
    pause
    exit /b 1
)

echo.
echo Building x86 version...
msbuild "%SOLUTION%" ^
    /p:Configuration=%CONFIG% ^
    /p:Platform=x86 ^
    /p:AppxBundle=Always ^
    /p:AppxBundlePlatforms="x86|x64|ARM64" ^
    /p:UapAppxPackageBuildMode=StoreUpload ^
    /p:AppxPackageDir="%CD%\%OUTPUT_DIR%\%CONFIG%\x86\" ^
    /m ^
    /v:minimal

echo.
echo Building ARM64 version...
msbuild "%SOLUTION%" ^
    /p:Configuration=%CONFIG% ^
    /p:Platform=ARM64 ^
    /p:AppxBundle=Always ^
    /p:AppxBundlePlatforms="x86|x64|ARM64" ^
    /p:UapAppxPackageBuildMode=StoreUpload ^
    /p:AppxPackageDir="%CD%\%OUTPUT_DIR%\%CONFIG%\ARM64\" ^
    /m ^
    /v:minimal

echo.
echo ========================================
echo   BUILD COMPLETED SUCCESSFULLY
echo ========================================
echo.
echo Build outputs saved to: %OUTPUT_DIR%
echo.
echo To install TextEdit:
echo 1. Navigate to %OUTPUT_DIR%\%CONFIG%\%PLATFORM%
echo 2. Right-click on TextEdit*.appx and select Install
echo 3. Or run: Add-AppxPackage -Path "path\to\TextEdit.appx"
echo.

REM Create installation script
echo Creating installation script...
> install-textedit.ps1 (
echo # TextEdit Installation Script
echo # Run as Administrator in PowerShell
echo.
echo Write-Host "Installing TextEdit..." -ForegroundColor Green
echo.
echo $AppxPath = Get-ChildItem -Path "%OUTPUT_DIR%\%CONFIG%\%PLATFORM%\TextEdit*.appx" ^| Select-Object -First 1
echo if ^($AppxPath^) {
echo     Write-Host "Installing: $^($AppxPath.Name^)" -ForegroundColor Yellow  
echo     Add-AppxPackage -Path $AppxPath.FullName -ForceApplicationShutdown
echo     Write-Host "TextEdit installed successfully!" -ForegroundColor Green
echo } else {
echo     Write-Host "TextEdit package not found!" -ForegroundColor Red
echo     exit 1
echo }
)

echo Installation script created: install-textedit.ps1
echo.
echo Run the following in PowerShell as Administrator:
echo   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
echo   .\install-textedit.ps1
echo.
pause