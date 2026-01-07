@echo off
setlocal enabledelayedexpansion

:: Script checks and adds user folder to Windows Defender exclusions
:: Requires running as administrator

echo ============================================
echo   Windows Defender Exclusions Check
echo ============================================

:: Check for administrator privileges
fltmc >nul 2>&1 || (
    echo Administrator privileges are required.
    PowerShell Start -Verb RunAs '%0' 2> nul || (
        echo Right-click on the script and select "Run as administrator".
        pause & exit 1
    )
    exit 0
)

:: Get current username
set "currentUser=%USERNAME%"
echo Current user: %currentUser%

:: Path to user folder
set "userFolder=C:\Users\%currentUser%"

:: Check if folder exists
if not exist "%userFolder%" (
    echo ERROR: Folder "%userFolder%" not found!
    pause
    exit /b 1
)

echo Folder to check: %userFolder%
echo.

:: Check for exclusion
echo Checking if folder is in Windows Defender exclusions...
powershell -Command "& {(Get-MpPreference).ExclusionPath}" > exclusions.tmp 2>nul

set "found=0"
for /f "delims=" %%i in (exclusions.tmp) do (
    if "%%i"=="%userFolder%" (
        set "found=1"
    )
)

del exclusions.tmp >nul 2>&1

if %found% equ 1 (
    echo Folder is ALREADY in Windows Defender exclusions.
    echo No action required.
) else (
    echo Folder NOT found in exclusions. Adding...
    echo.
    
    :: Add exclusion
    powershell -Command "& {Add-MpPreference -ExclusionPath '%userFolder%' -ErrorAction Stop}"
    
    if %errorLevel% equ 0 (
        echo SUCCESS: Folder added to Windows Defender exclusions!
        
        :: Verify addition
        echo.
        echo Verifying addition...
        powershell -Command "& {(Get-MpPreference).ExclusionPath | Where-Object {$_ -eq '%userFolder%'}}"
        
        if %errorLevel% equ 0 (
            echo Confirmed: folder successfully added.
        ) else (
            echo WARNING: Could not confirm addition.
        )
    ) else (
        echo ERROR: Failed to add folder to exclusions.
        echo Make sure Windows Defender is active and script is run as administrator.
    )
)

echo.
echo ============================================
echo Press any key to exit...
pause >nul