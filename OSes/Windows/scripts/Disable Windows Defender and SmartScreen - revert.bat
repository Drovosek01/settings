@echo off
:: https://privacy.sexy — v0.12.2 — Mon, 28 Aug 2023 11:28:16 GMT
:: Ensure admin privileges
fltmc >nul 2>&1 || (
    echo Administrator privileges are required.
    PowerShell Start -Verb RunAs '%0' 2> nul || (
        echo Right-click on the script and select "Run as administrator".
        pause & exit 1
    )
    exit 0
)


:: ----------------------------------------------------------
:: ------Disable Microsoft Defender Antivirus (revert)-------
:: ----------------------------------------------------------
echo --- Disable Microsoft Defender Antivirus (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -----Disable SmartScreen for apps and files (revert)------
:: ----------------------------------------------------------
echo --- Disable SmartScreen for apps and files (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ------Disable SmartScreen in file explorer (revert)-------
:: ----------------------------------------------------------
echo --- Disable SmartScreen in file explorer (revert)
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /f 2>nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /f 2>nul
:: ----------------------------------------------------------


:: Disable SmartScreen preventing users from running applications (revert)
echo --- Disable SmartScreen preventing users from running applications (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "ShellSmartScreenLevel" /f 2>nul
:: ----------------------------------------------------------


:: Prevent Chromium Edge SmartScreen from blocking potentially unwanted apps (revert)
echo --- Prevent Chromium Edge SmartScreen from blocking potentially unwanted apps (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "SmartScreenPuaEnabled" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -----------Disable SmartScreen in Edge (revert)-----------
:: ----------------------------------------------------------
echo --- Disable SmartScreen in Edge (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /f 2>nul
reg delete "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "PreventOverride" /f 2>nul
reg delete "HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /f 2>nul
reg delete "HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v "PreventOverride" /f 2>nul
:: For Microsoft Edge version 77 or later
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "SmartScreenEnabled" /f 2>nul
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "PreventSmartScreenPromptOverride" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----Disable SmartScreen in Internet Explorer (revert)-----
:: ----------------------------------------------------------
echo --- Disable SmartScreen in Internet Explorer (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0" /v "2301" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: Turn off SmartScreen App Install Control feature (revert)-
:: ----------------------------------------------------------
echo --- Turn off SmartScreen App Install Control feature (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControl" /f 2>nul
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControlEnabled" /f 2>nul
:: ----------------------------------------------------------


:: Turn off SmartScreen to check web content (URLs) that apps use (revert)
echo --- Turn off SmartScreen to check web content (URLs) that apps use (revert)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "1" /f
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---Disable Windows Defender ExploitGuard task (revert)----
:: ----------------------------------------------------------
echo --- Disable Windows Defender ExploitGuard task (revert)
schtasks /Change /TN "Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh" /Enable
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -Disable Windows Defender Cache Maintenance task (revert)-
:: ----------------------------------------------------------
echo --- Disable Windows Defender Cache Maintenance task (revert)
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Enable
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ------Disable Windows Defender Cleanup task (revert)------
:: ----------------------------------------------------------
echo --- Disable Windows Defender Cleanup task (revert)
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Enable
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: --Disable Windows Defender Scheduled Scan task (revert)---
:: ----------------------------------------------------------
echo --- Disable Windows Defender Scheduled Scan task (revert)
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Enable 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---Disable Windows Defender Verification task (revert)----
:: ----------------------------------------------------------
echo --- Disable Windows Defender Verification task (revert)
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Enable
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---Disable Windows Defender Antivirus service (revert)----
:: ----------------------------------------------------------
echo --- Disable Windows Defender Antivirus service (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$command = 'reg add "^""HKLM\SYSTEM\CurrentControlSet\Services\WinDefend"^"" /v "^""Start"^"" /t REG_DWORD /d "^""2"^"" /f & sc start "^""WinDefend"^"" >nul 2>&1'; $trustedInstallerSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464'); $trustedInstallerName = $trustedInstallerSid.Translate([System.Security.Principal.NTAccount]); $streamOutFile = New-TemporaryFile; $batchFile = New-TemporaryFile; try {; $batchFile = Rename-Item $batchFile "^""$($batchFile.BaseName).bat"^"" -PassThru; "^""@echo off`r`n$command`r`nexit 0"^"" | Out-File $batchFile -Encoding ASCII; $taskName = 'privacy.sexy invoke'; schtasks.exe /delete /tn "^""$taskName"^"" /f 2>&1 | Out-Null <# Clean if something went wrong before, suppress any output #>; $taskAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "^""cmd /c `"^""$batchFile`"^"" > $streamOutFile 2>&1"^""; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Register-ScheduledTask -TaskName $taskName -Action $taskAction -Settings $settings -Force -ErrorAction Stop | Out-Null; try {; ($scheduleService = New-Object -ComObject Schedule.Service).Connect(); $scheduleService.GetFolder('\').GetTask($taskName).RunEx($null, 0, 0, $trustedInstallerName) | Out-Null; $timeOutLimit = (Get-Date).AddMinutes(5); Write-Host "^""Running as $trustedInstallerName"^""; while((Get-ScheduledTaskInfo $taskName).LastTaskResult -eq 267009) {; Start-Sleep -Milliseconds 200; if((Get-Date) -gt $timeOutLimit) {; Write-Warning "^""Skipping results, it took so long to execute script."^""; break;; }; }; if (($result = (Get-ScheduledTaskInfo $taskName).LastTaskResult) -ne 0) {; Write-Error "^""Failed to execute with exit code: $result."^""; }; } finally {; schtasks.exe /delete /tn "^""$taskName"^"" /f | Out-Null <# Outputs only errors #>; }; Get-Content $streamOutFile; } finally {; Remove-Item $streamOutFile, $batchFile; }"
:: ----------------------------------------------------------


:: Disable Microsoft Defender Antivirus Network Inspection service (revert)
echo --- Disable Microsoft Defender Antivirus Network Inspection service (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$command = 'reg add "^""HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc"^"" /v "^""Start"^"" /t REG_DWORD /d "^""2"^"" /f & sc start "^""WdNisSvc"^"" >nul 2>&1'; $trustedInstallerSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464'); $trustedInstallerName = $trustedInstallerSid.Translate([System.Security.Principal.NTAccount]); $streamOutFile = New-TemporaryFile; $batchFile = New-TemporaryFile; try {; $batchFile = Rename-Item $batchFile "^""$($batchFile.BaseName).bat"^"" -PassThru; "^""@echo off`r`n$command`r`nexit 0"^"" | Out-File $batchFile -Encoding ASCII; $taskName = 'privacy.sexy invoke'; schtasks.exe /delete /tn "^""$taskName"^"" /f 2>&1 | Out-Null <# Clean if something went wrong before, suppress any output #>; $taskAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "^""cmd /c `"^""$batchFile`"^"" > $streamOutFile 2>&1"^""; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Register-ScheduledTask -TaskName $taskName -Action $taskAction -Settings $settings -Force -ErrorAction Stop | Out-Null; try {; ($scheduleService = New-Object -ComObject Schedule.Service).Connect(); $scheduleService.GetFolder('\').GetTask($taskName).RunEx($null, 0, 0, $trustedInstallerName) | Out-Null; $timeOutLimit = (Get-Date).AddMinutes(5); Write-Host "^""Running as $trustedInstallerName"^""; while((Get-ScheduledTaskInfo $taskName).LastTaskResult -eq 267009) {; Start-Sleep -Milliseconds 200; if((Get-Date) -gt $timeOutLimit) {; Write-Warning "^""Skipping results, it took so long to execute script."^""; break;; }; }; if (($result = (Get-ScheduledTaskInfo $taskName).LastTaskResult) -ne 0) {; Write-Error "^""Failed to execute with exit code: $result."^""; }; } finally {; schtasks.exe /delete /tn "^""$taskName"^"" /f | Out-Null <# Outputs only errors #>; }; Get-Content $streamOutFile; } finally {; Remove-Item $streamOutFile, $batchFile; }"
:: ----------------------------------------------------------


:: Disable Windows Defender Advanced Threat Protection Service service (revert)
echo --- Disable Windows Defender Advanced Threat Protection Service service (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$command = 'reg add "^""HKLM\SYSTEM\CurrentControlSet\Services\Sense"^"" /v "^""Start"^"" /t REG_DWORD /d "^""3"^"" /f & sc start "^""Sense"^"" >nul 2>&1'; $trustedInstallerSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464'); $trustedInstallerName = $trustedInstallerSid.Translate([System.Security.Principal.NTAccount]); $streamOutFile = New-TemporaryFile; $batchFile = New-TemporaryFile; try {; $batchFile = Rename-Item $batchFile "^""$($batchFile.BaseName).bat"^"" -PassThru; "^""@echo off`r`n$command`r`nexit 0"^"" | Out-File $batchFile -Encoding ASCII; $taskName = 'privacy.sexy invoke'; schtasks.exe /delete /tn "^""$taskName"^"" /f 2>&1 | Out-Null <# Clean if something went wrong before, suppress any output #>; $taskAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "^""cmd /c `"^""$batchFile`"^"" > $streamOutFile 2>&1"^""; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Register-ScheduledTask -TaskName $taskName -Action $taskAction -Settings $settings -Force -ErrorAction Stop | Out-Null; try {; ($scheduleService = New-Object -ComObject Schedule.Service).Connect(); $scheduleService.GetFolder('\').GetTask($taskName).RunEx($null, 0, 0, $trustedInstallerName) | Out-Null; $timeOutLimit = (Get-Date).AddMinutes(5); Write-Host "^""Running as $trustedInstallerName"^""; while((Get-ScheduledTaskInfo $taskName).LastTaskResult -eq 267009) {; Start-Sleep -Milliseconds 200; if((Get-Date) -gt $timeOutLimit) {; Write-Warning "^""Skipping results, it took so long to execute script."^""; break;; }; }; if (($result = (Get-ScheduledTaskInfo $taskName).LastTaskResult) -ne 0) {; Write-Error "^""Failed to execute with exit code: $result."^""; }; } finally {; schtasks.exe /delete /tn "^""$taskName"^"" /f | Out-Null <# Outputs only errors #>; }; Get-Content $streamOutFile; } finally {; Remove-Item $streamOutFile, $batchFile; }"
if exist "%ProgramFiles%\Windows Defender Advanced Threat Protection\MsSense.exe.OLD" (
    takeown /f "%ProgramFiles%\Windows Defender Advanced Threat Protection\MsSense.exe.OLD"
    icacls "%ProgramFiles%\Windows Defender Advanced Threat Protection\MsSense.exe.OLD" /grant administrators:F
    move "%ProgramFiles%\Windows Defender Advanced Threat Protection\MsSense.exe.OLD" "%ProgramFiles%\Windows Defender Advanced Threat Protection\MsSense.exe" && (
        echo Moved "%ProgramFiles%\Windows Defender Advanced Threat Protection\MsSense.exe.OLD" to "%ProgramFiles%\Windows Defender Advanced Threat Protection\MsSense.exe"
    ) || (
        echo Could restore from backup file %ProgramFiles%\Windows Defender Advanced Threat Protection\MsSense.exe.OLD 1>&2
    )
) else (
    echo Could not find backup file "%ProgramFiles%\Windows Defender Advanced Threat Protection\MsSense.exe.OLD" 1>&2
)
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: Disable Windows Defender Security Center Service (revert)-
:: ----------------------------------------------------------
echo --- Disable Windows Defender Security Center Service (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$command = 'reg add "^""HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService"^"" /v Start /t REG_DWORD /d 3 /f & sc start "^""SecurityHealthService"^"" >nul 2>&1'; $trustedInstallerSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464'); $trustedInstallerName = $trustedInstallerSid.Translate([System.Security.Principal.NTAccount]); $streamOutFile = New-TemporaryFile; $batchFile = New-TemporaryFile; try {; $batchFile = Rename-Item $batchFile "^""$($batchFile.BaseName).bat"^"" -PassThru; "^""@echo off`r`n$command`r`nexit 0"^"" | Out-File $batchFile -Encoding ASCII; $taskName = 'privacy.sexy invoke'; schtasks.exe /delete /tn "^""$taskName"^"" /f 2>&1 | Out-Null <# Clean if something went wrong before, suppress any output #>; $taskAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "^""cmd /c `"^""$batchFile`"^"" > $streamOutFile 2>&1"^""; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Register-ScheduledTask -TaskName $taskName -Action $taskAction -Settings $settings -Force -ErrorAction Stop | Out-Null; try {; ($scheduleService = New-Object -ComObject Schedule.Service).Connect(); $scheduleService.GetFolder('\').GetTask($taskName).RunEx($null, 0, 0, $trustedInstallerName) | Out-Null; $timeOutLimit = (Get-Date).AddMinutes(5); Write-Host "^""Running as $trustedInstallerName"^""; while((Get-ScheduledTaskInfo $taskName).LastTaskResult -eq 267009) {; Start-Sleep -Milliseconds 200; if((Get-Date) -gt $timeOutLimit) {; Write-Warning "^""Skipping results, it took so long to execute script."^""; break;; }; }; if (($result = (Get-ScheduledTaskInfo $taskName).LastTaskResult) -ne 0) {; Write-Error "^""Failed to execute with exit code: $result."^""; }; } finally {; schtasks.exe /delete /tn "^""$taskName"^"" /f | Out-Null <# Outputs only errors #>; }; Get-Content $streamOutFile; } finally {; Remove-Item $streamOutFile, $batchFile; }"
if exist "%WinDir%\system32\SecurityHealthService.exe.OLD" (
    takeown /f "%WinDir%\system32\SecurityHealthService.exe.OLD"
    icacls "%WinDir%\system32\SecurityHealthService.exe.OLD" /grant administrators:F
    move "%WinDir%\system32\SecurityHealthService.exe.OLD" "%WinDir%\system32\SecurityHealthService.exe" && (
        echo Moved "%WinDir%\system32\SecurityHealthService.exe.OLD" to "%WinDir%\system32\SecurityHealthService.exe"
    ) || (
        echo Could restore from backup file %WinDir%\system32\SecurityHealthService.exe.OLD 1>&2
    )
) else (
    echo Could not find backup file "%WinDir%\system32\SecurityHealthService.exe.OLD" 1>&2
)
:: ----------------------------------------------------------


:: Disable Microsoft Defender Antivirus Network Inspection System Driver service (revert)
echo --- Disable Microsoft Defender Antivirus Network Inspection System Driver service (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$command = 'reg add "^""HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv"^"" /v "^""Start"^"" /t REG_DWORD /d "^""3"^"" /f & sc start "^""WdNisDrv"^"" >nul'; $trustedInstallerSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464'); $trustedInstallerName = $trustedInstallerSid.Translate([System.Security.Principal.NTAccount]); $streamOutFile = New-TemporaryFile; $batchFile = New-TemporaryFile; try {; $batchFile = Rename-Item $batchFile "^""$($batchFile.BaseName).bat"^"" -PassThru; "^""@echo off`r`n$command`r`nexit 0"^"" | Out-File $batchFile -Encoding ASCII; $taskName = 'privacy.sexy invoke'; schtasks.exe /delete /tn "^""$taskName"^"" /f 2>&1 | Out-Null <# Clean if something went wrong before, suppress any output #>; $taskAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "^""cmd /c `"^""$batchFile`"^"" > $streamOutFile 2>&1"^""; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Register-ScheduledTask -TaskName $taskName -Action $taskAction -Settings $settings -Force -ErrorAction Stop | Out-Null; try {; ($scheduleService = New-Object -ComObject Schedule.Service).Connect(); $scheduleService.GetFolder('\').GetTask($taskName).RunEx($null, 0, 0, $trustedInstallerName) | Out-Null; $timeOutLimit = (Get-Date).AddMinutes(5); Write-Host "^""Running as $trustedInstallerName"^""; while((Get-ScheduledTaskInfo $taskName).LastTaskResult -eq 267009) {; Start-Sleep -Milliseconds 200; if((Get-Date) -gt $timeOutLimit) {; Write-Warning "^""Skipping results, it took so long to execute script."^""; break;; }; }; if (($result = (Get-ScheduledTaskInfo $taskName).LastTaskResult) -ne 0) {; Write-Error "^""Failed to execute with exit code: $result."^""; }; } finally {; schtasks.exe /delete /tn "^""$taskName"^"" /f | Out-Null <# Outputs only errors #>; }; Get-Content $streamOutFile; } finally {; Remove-Item $streamOutFile, $batchFile; }"
if exist "%SystemRoot%\System32\drivers\WdNisDrv.sys.OLD" (
    takeown /f "%SystemRoot%\System32\drivers\WdNisDrv.sys.OLD"
    icacls "%SystemRoot%\System32\drivers\WdNisDrv.sys.OLD" /grant administrators:F
    move "%SystemRoot%\System32\drivers\WdNisDrv.sys.OLD" "%SystemRoot%\System32\drivers\WdNisDrv.sys" && (
        echo Moved "%SystemRoot%\System32\drivers\WdNisDrv.sys.OLD" to "%SystemRoot%\System32\drivers\WdNisDrv.sys"
    ) || (
        echo Could restore from backup file %SystemRoot%\System32\drivers\WdNisDrv.sys.OLD 1>&2
    )
) else (
    echo Could not find backup file "%SystemRoot%\System32\drivers\WdNisDrv.sys.OLD" 1>&2
)
:: ----------------------------------------------------------


:: Disable Microsoft Defender Antivirus Mini-Filter Driver service (revert)
echo --- Disable Microsoft Defender Antivirus Mini-Filter Driver service (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$command = 'reg add "^""HKLM\SYSTEM\CurrentControlSet\Services\WdFilter"^"" /v "^""Start"^"" /t REG_DWORD /d "^""0"^"" /f & sc start "^""WdFilter"^"" >nul'; $trustedInstallerSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464'); $trustedInstallerName = $trustedInstallerSid.Translate([System.Security.Principal.NTAccount]); $streamOutFile = New-TemporaryFile; $batchFile = New-TemporaryFile; try {; $batchFile = Rename-Item $batchFile "^""$($batchFile.BaseName).bat"^"" -PassThru; "^""@echo off`r`n$command`r`nexit 0"^"" | Out-File $batchFile -Encoding ASCII; $taskName = 'privacy.sexy invoke'; schtasks.exe /delete /tn "^""$taskName"^"" /f 2>&1 | Out-Null <# Clean if something went wrong before, suppress any output #>; $taskAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "^""cmd /c `"^""$batchFile`"^"" > $streamOutFile 2>&1"^""; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Register-ScheduledTask -TaskName $taskName -Action $taskAction -Settings $settings -Force -ErrorAction Stop | Out-Null; try {; ($scheduleService = New-Object -ComObject Schedule.Service).Connect(); $scheduleService.GetFolder('\').GetTask($taskName).RunEx($null, 0, 0, $trustedInstallerName) | Out-Null; $timeOutLimit = (Get-Date).AddMinutes(5); Write-Host "^""Running as $trustedInstallerName"^""; while((Get-ScheduledTaskInfo $taskName).LastTaskResult -eq 267009) {; Start-Sleep -Milliseconds 200; if((Get-Date) -gt $timeOutLimit) {; Write-Warning "^""Skipping results, it took so long to execute script."^""; break;; }; }; if (($result = (Get-ScheduledTaskInfo $taskName).LastTaskResult) -ne 0) {; Write-Error "^""Failed to execute with exit code: $result."^""; }; } finally {; schtasks.exe /delete /tn "^""$taskName"^"" /f | Out-Null <# Outputs only errors #>; }; Get-Content $streamOutFile; } finally {; Remove-Item $streamOutFile, $batchFile; }"
if exist "%SystemRoot%\System32\drivers\WdFilter.sys.OLD" (
    takeown /f "%SystemRoot%\System32\drivers\WdFilter.sys.OLD"
    icacls "%SystemRoot%\System32\drivers\WdFilter.sys.OLD" /grant administrators:F
    move "%SystemRoot%\System32\drivers\WdFilter.sys.OLD" "%SystemRoot%\System32\drivers\WdFilter.sys" && (
        echo Moved "%SystemRoot%\System32\drivers\WdFilter.sys.OLD" to "%SystemRoot%\System32\drivers\WdFilter.sys"
    ) || (
        echo Could restore from backup file %SystemRoot%\System32\drivers\WdFilter.sys.OLD 1>&2
    )
) else (
    echo Could not find backup file "%SystemRoot%\System32\drivers\WdFilter.sys.OLD" 1>&2
)
:: ----------------------------------------------------------


:: Disable Microsoft Defender Antivirus Boot Driver service (revert)
echo --- Disable Microsoft Defender Antivirus Boot Driver service (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$command = 'reg add "^""HKLM\SYSTEM\CurrentControlSet\Services\WdBoot"^"" /v "^""Start"^"" /t REG_DWORD /d "^""0"^"" /f & sc start "^""WdBoot"^"" >nul 2>&1'; $trustedInstallerSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464'); $trustedInstallerName = $trustedInstallerSid.Translate([System.Security.Principal.NTAccount]); $streamOutFile = New-TemporaryFile; $batchFile = New-TemporaryFile; try {; $batchFile = Rename-Item $batchFile "^""$($batchFile.BaseName).bat"^"" -PassThru; "^""@echo off`r`n$command`r`nexit 0"^"" | Out-File $batchFile -Encoding ASCII; $taskName = 'privacy.sexy invoke'; schtasks.exe /delete /tn "^""$taskName"^"" /f 2>&1 | Out-Null <# Clean if something went wrong before, suppress any output #>; $taskAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "^""cmd /c `"^""$batchFile`"^"" > $streamOutFile 2>&1"^""; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Register-ScheduledTask -TaskName $taskName -Action $taskAction -Settings $settings -Force -ErrorAction Stop | Out-Null; try {; ($scheduleService = New-Object -ComObject Schedule.Service).Connect(); $scheduleService.GetFolder('\').GetTask($taskName).RunEx($null, 0, 0, $trustedInstallerName) | Out-Null; $timeOutLimit = (Get-Date).AddMinutes(5); Write-Host "^""Running as $trustedInstallerName"^""; while((Get-ScheduledTaskInfo $taskName).LastTaskResult -eq 267009) {; Start-Sleep -Milliseconds 200; if((Get-Date) -gt $timeOutLimit) {; Write-Warning "^""Skipping results, it took so long to execute script."^""; break;; }; }; if (($result = (Get-ScheduledTaskInfo $taskName).LastTaskResult) -ne 0) {; Write-Error "^""Failed to execute with exit code: $result."^""; }; } finally {; schtasks.exe /delete /tn "^""$taskName"^"" /f | Out-Null <# Outputs only errors #>; }; Get-Content $streamOutFile; } finally {; Remove-Item $streamOutFile, $batchFile; }"
if exist "%SystemRoot%\System32\drivers\WdBoot.sys.OLD" (
    takeown /f "%SystemRoot%\System32\drivers\WdBoot.sys.OLD"
    icacls "%SystemRoot%\System32\drivers\WdBoot.sys.OLD" /grant administrators:F
    move "%SystemRoot%\System32\drivers\WdBoot.sys.OLD" "%SystemRoot%\System32\drivers\WdBoot.sys" && (
        echo Moved "%SystemRoot%\System32\drivers\WdBoot.sys.OLD" to "%SystemRoot%\System32\drivers\WdBoot.sys"
    ) || (
        echo Could restore from backup file %SystemRoot%\System32\drivers\WdBoot.sys.OLD 1>&2
    )
) else (
    echo Could not find backup file "%SystemRoot%\System32\drivers\WdBoot.sys.OLD" 1>&2
)
:: ----------------------------------------------------------


:: Disable the Potentially Unwanted Application (PUA) feature (revert)
echo --- Disable the Potentially Unwanted Application (PUA) feature (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'PUAProtection'; $defaultValue = '0'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: For legacy versions: Windows 10 v1809 and Windows Server 2019
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\MpEngine" /v "MpEnablePus" /f 2>nul
:: For newer Windows versions
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender" /v "PUAProtection" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -----------Turn off tamper protection (revert)------------
:: ----------------------------------------------------------
echo --- Turn off tamper protection (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$command = 'reg delete "^""HKLM\SOFTWARE\Microsoft\Windows Defender\Features"^"" /v "^""TamperProtection"^"" /f 2>nul'; $trustedInstallerSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464'); $trustedInstallerName = $trustedInstallerSid.Translate([System.Security.Principal.NTAccount]); $streamOutFile = New-TemporaryFile; $batchFile = New-TemporaryFile; try {; $batchFile = Rename-Item $batchFile "^""$($batchFile.BaseName).bat"^"" -PassThru; "^""@echo off`r`n$command`r`nexit 0"^"" | Out-File $batchFile -Encoding ASCII; $taskName = 'privacy.sexy invoke'; schtasks.exe /delete /tn "^""$taskName"^"" /f 2>&1 | Out-Null <# Clean if something went wrong before, suppress any output #>; $taskAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "^""cmd /c `"^""$batchFile`"^"" > $streamOutFile 2>&1"^""; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Register-ScheduledTask -TaskName $taskName -Action $taskAction -Settings $settings -Force -ErrorAction Stop | Out-Null; try {; ($scheduleService = New-Object -ComObject Schedule.Service).Connect(); $scheduleService.GetFolder('\').GetTask($taskName).RunEx($null, 0, 0, $trustedInstallerName) | Out-Null; $timeOutLimit = (Get-Date).AddMinutes(5); Write-Host "^""Running as $trustedInstallerName"^""; while((Get-ScheduledTaskInfo $taskName).LastTaskResult -eq 267009) {; Start-Sleep -Milliseconds 200; if((Get-Date) -gt $timeOutLimit) {; Write-Warning "^""Skipping results, it took so long to execute script."^""; break;; }; }; if (($result = (Get-ScheduledTaskInfo $taskName).LastTaskResult) -ne 0) {; Write-Error "^""Failed to execute with exit code: $result."^""; }; } finally {; schtasks.exe /delete /tn "^""$taskName"^"" /f | Out-Null <# Outputs only errors #>; }; Get-Content $streamOutFile; } finally {; Remove-Item $streamOutFile, $batchFile; }"
PowerShell -ExecutionPolicy Unrestricted -Command "$command = 'reg delete "^""HKLM\SOFTWARE\Microsoft\Windows Defender\Features"^"" /v "^""TamperProtectionSource"^"" /f 2>nul'; $trustedInstallerSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464'); $trustedInstallerName = $trustedInstallerSid.Translate([System.Security.Principal.NTAccount]); $streamOutFile = New-TemporaryFile; $batchFile = New-TemporaryFile; try {; $batchFile = Rename-Item $batchFile "^""$($batchFile.BaseName).bat"^"" -PassThru; "^""@echo off`r`n$command`r`nexit 0"^"" | Out-File $batchFile -Encoding ASCII; $taskName = 'privacy.sexy invoke'; schtasks.exe /delete /tn "^""$taskName"^"" /f 2>&1 | Out-Null <# Clean if something went wrong before, suppress any output #>; $taskAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "^""cmd /c `"^""$batchFile`"^"" > $streamOutFile 2>&1"^""; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Register-ScheduledTask -TaskName $taskName -Action $taskAction -Settings $settings -Force -ErrorAction Stop | Out-Null; try {; ($scheduleService = New-Object -ComObject Schedule.Service).Connect(); $scheduleService.GetFolder('\').GetTask($taskName).RunEx($null, 0, 0, $trustedInstallerName) | Out-Null; $timeOutLimit = (Get-Date).AddMinutes(5); Write-Host "^""Running as $trustedInstallerName"^""; while((Get-ScheduledTaskInfo $taskName).LastTaskResult -eq 267009) {; Start-Sleep -Milliseconds 200; if((Get-Date) -gt $timeOutLimit) {; Write-Warning "^""Skipping results, it took so long to execute script."^""; break;; }; }; if (($result = (Get-ScheduledTaskInfo $taskName).LastTaskResult) -ne 0) {; Write-Error "^""Failed to execute with exit code: $result."^""; }; } finally {; schtasks.exe /delete /tn "^""$taskName"^"" /f | Out-Null <# Outputs only errors #>; }; Get-Content $streamOutFile; } finally {; Remove-Item $streamOutFile, $batchFile; }"
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ------Disable file hash computation feature (revert)------
:: ----------------------------------------------------------
echo --- Disable file hash computation feature (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\MpEngine" /v "EnableFileHashComputation" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---Disable always running antimalware service (revert)----
:: ----------------------------------------------------------
echo --- Disable always running antimalware service (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -------------Disable auto-exclusions (revert)-------------
:: ----------------------------------------------------------
echo --- Disable auto-exclusions (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableAutoExclusions'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 = $true <# $false #>; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions" /v "DisableAutoExclusions" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----------Turn off block at first sight (revert)----------
:: ----------------------------------------------------------
echo --- Turn off block at first sight (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableBlockAtFirstSeen'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\SpyNet" /v "DisableBlockAtFirstSeen" /f 2>nul
:: ----------------------------------------------------------


:: Set maximum time possible for extended cloud check timeout (revert)
echo --- Set maximum time possible for extended cloud check timeout (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\MpEngine" /v "MpBafsExtendedTimeout" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---Set lowest possible cloud protection level (revert)----
:: ----------------------------------------------------------
echo --- Set lowest possible cloud protection level (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\MpEngine" /v "MpCloudBlockLevel" /f 2>nul
:: ----------------------------------------------------------


:: Disable receiving notifications to disable security intelligence (revert)
echo --- Disable receiving notifications to disable security intelligence (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "SignatureDisableNotification" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---Turn off Windows Defender SpyNet reporting (revert)----
:: ----------------------------------------------------------
echo --- Turn off Windows Defender SpyNet reporting (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'MAPSReporting'; $defaultValue = '2'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpynetReporting" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: --Do not send file samples for further analysis (revert)--
:: ----------------------------------------------------------
echo --- Do not send file samples for further analysis (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'SubmitSamplesConsent'; $defaultValue = '1'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 = $true <# $false #>; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /f 2>nul
:: ----------------------------------------------------------


:: Disable Malicious Software Reporting tool diagnostic data (revert)
echo --- Disable Malicious Software Reporting tool diagnostic data (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /f 2>nul
:: ----------------------------------------------------------


:: Disable uploading files for threat analysis in real-time (revert)
echo --- Disable uploading files for threat analysis in real-time (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "RealtimeSignatureDelivery" /f 2>nul
:: ----------------------------------------------------------


:: Disable prevention of users and apps from accessing dangerous websites (revert)
echo --- Disable prevention of users and apps from accessing dangerous websites (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" /v "EnableNetworkProtection" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: --------Disable Controlled folder access (revert)---------
:: ----------------------------------------------------------
echo --- Disable Controlled folder access (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access" /v "EnableControlledFolderAccess" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----------Disable real-time monitoring (revert)-----------
:: ----------------------------------------------------------
echo --- Disable real-time monitoring (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableRealtimeMonitoring'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----Disable Intrusion Prevention System (IPS) (revert)----
:: ----------------------------------------------------------
echo --- Disable Intrusion Prevention System (IPS) (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableIntrusionPreventionSystem'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIntrusionPreventionSystem" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: --Disable Information Protection Control (IPC) (revert)---
:: ----------------------------------------------------------
echo --- Disable Information Protection Control (IPC) (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableInformationProtectionControl" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: Disable process scanning on real-time protection (revert)-
:: ----------------------------------------------------------
echo --- Disable process scanning on real-time protection (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -----------Disable behavior monitoring (revert)-----------
:: ----------------------------------------------------------
echo --- Disable behavior monitoring (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableBehaviorMonitoring'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /f 2>nul
:: ----------------------------------------------------------


:: Disable sending raw write notifications to behavior monitoring (revert)
echo --- Disable sending raw write notifications to behavior monitoring (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRawWriteNotification" /f 2>nul
:: ----------------------------------------------------------


:: Disable scanning for all downloaded files and attachments (revert)
echo --- Disable scanning for all downloaded files and attachments (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableIOAVProtection'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /f 2>nul
:: ----------------------------------------------------------


:: Disable scanning files bigger than 1 KB (minimum possible) (revert)
echo --- Disable scanning files bigger than 1 KB (minimum possible) (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "IOAVMaxSize" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: --Disable monitoring file and program activity (revert)---
:: ----------------------------------------------------------
echo --- Disable monitoring file and program activity (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /f 2>nul
:: ----------------------------------------------------------


:: Disable bidirectional scanning of incoming and outgoing file and program activity (revert)
echo --- Disable bidirectional scanning of incoming and outgoing file and program activity (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'RealTimeScanDirection'; $defaultValue = '0'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "RealTimeScanDirection" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -----------Disable routine remediation (revert)-----------
:: ----------------------------------------------------------
echo --- Disable routine remediation (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction"  /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---Disable running scheduled auto-remediation (revert)----
:: ----------------------------------------------------------
echo --- Disable running scheduled auto-remediation (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Remediation" /v "Scan_ScheduleDay" /f 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'RemediationScheduleDay'; $defaultValue = '0'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -----------Disable remediation actions (revert)-----------
:: ----------------------------------------------------------
echo --- Disable remediation actions (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'UnknownThreatDefaultAction'; $setDefaultOnWindows10 =  $false; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Threats" /v "Threats_ThreatSeverityDefaultAction" /f 2>nul
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Threats\ThreatSeverityDefaultAction" /v "5" /f 2>nul
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Threats\ThreatSeverityDefaultAction" /v "4" /f 2>nul
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Threats\ThreatSeverityDefaultAction" /v "3" /f 2>nul
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Threats\ThreatSeverityDefaultAction" /v "2" /f 2>nul
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Threats\ThreatSeverityDefaultAction" /v "1" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -----Auto-purge items from Quarantine folder (revert)-----
:: ----------------------------------------------------------
echo --- Auto-purge items from Quarantine folder (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'QuarantinePurgeItemsAfterDelay'; $defaultValue = '90'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 = $true <# $false #>; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Quarantine" /v "PurgeItemsAfterDelay" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---Disable checking for signatures before scan (revert)---
:: ----------------------------------------------------------
echo --- Disable checking for signatures before scan (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'CheckForSignaturesBeforeRunningScan'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "CheckForSignaturesBeforeRunningScan" /f 2>nul
:: ----------------------------------------------------------


:: Disable creating system restore point on a daily basis (revert)
echo --- Disable creating system restore point on a daily basis (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableRestorePoint'; $defaultValue = $True; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "DisableRestorePoint" /f 2>nul
:: ----------------------------------------------------------


:: Set minumum time for keeping files in scan history folder (revert)
echo --- Set minumum time for keeping files in scan history folder (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'ScanPurgeItemsAfterDelay'; $defaultValue = '15'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "PurgeItemsAfterDelay" /f 2>nul
:: ----------------------------------------------------------


:: Set maximum days before a catch-up scan is forced (revert)
echo --- Set maximum days before a catch-up scan is forced (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "MissedScheduledScanCountBeforeCatchup" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -----------Disable catch-up full scans (revert)-----------
:: ----------------------------------------------------------
echo --- Disable catch-up full scans (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableCatchupFullScan'; $defaultValue = $True; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "DisableCatchupFullScan" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----------Disable catch-up quick scans (revert)-----------
:: ----------------------------------------------------------
echo --- Disable catch-up quick scans (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableCatchupQuickScan'; $defaultValue = $True; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "DisableCatchupQuickScan" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -------------Disable scan heuristics (revert)-------------
:: ----------------------------------------------------------
echo --- Disable scan heuristics (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "DisableHeuristics" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---------Disable scanning when not idle (revert)----------
:: ----------------------------------------------------------
echo --- Disable scanning when not idle (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'ScanOnlyIfIdleEnabled'; $defaultValue = $True; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "ScanOnlyIfIdle" /f 2>nul
:: ----------------------------------------------------------


:: Disable scheduled On Demand anti malware scanner (MRT) (revert)
echo --- Disable scheduled On Demand anti malware scanner (MRT) (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -----Limit CPU usage during scans to minimum (revert)-----
:: ----------------------------------------------------------
echo --- Limit CPU usage during scans to minimum (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'ScanAvgCPULoadFactor'; $defaultValue = '50'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "AvgCPULoadFactor" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: --Limit CPU usage during idle scans to minumum (revert)---
:: ----------------------------------------------------------
echo --- Limit CPU usage during idle scans to minumum (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableCpuThrottleOnIdleScans'; $defaultValue = $True; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "DisableCpuThrottleOnIdleScans" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -------------Disable e-mail scanning (revert)-------------
:: ----------------------------------------------------------
echo --- Disable e-mail scanning (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableEmailScanning'; $defaultValue = $True; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "DisableEmailScanning" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -------------Disable script scanning (revert)-------------
:: ----------------------------------------------------------
echo --- Disable script scanning (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableScriptScanning'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---------Disable reparse point scanning (revert)----------
:: ----------------------------------------------------------
echo --- Disable reparse point scanning (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "DisableReparsePointScanning" /f 2>nul
:: ----------------------------------------------------------


:: Disable scanning on mapped network drives on full-scan (revert)
echo --- Disable scanning on mapped network drives on full-scan (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "DisableScanningMappedNetworkDrivesForFullScan" /f 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableScanningMappedNetworkDrivesForFullScan'; $defaultValue = $True; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---------Disable scanning network files (revert)----------
:: ----------------------------------------------------------
echo --- Disable scanning network files (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "DisableScanningNetworkFiles" /f 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableScanningNetworkFiles'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -------Disable scanning packed executables (revert)-------
:: ----------------------------------------------------------
echo --- Disable scanning packed executables (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "DisablePackedExeScanning" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: --------Disable scanning removable drives (revert)--------
:: ----------------------------------------------------------
echo --- Disable scanning removable drives (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "DisableRemovableDriveScanning" /f 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableRemovableDriveScanning'; $defaultValue = $True; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---------Disable scanning archive files (revert)----------
:: ----------------------------------------------------------
echo --- Disable scanning archive files (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "DisableArchiveScanning" /f 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableArchiveScanning'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: Limit depth for scanning archive files to minimum (revert)
echo --- Limit depth for scanning archive files to minimum (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "ArchiveMaxDepth" /f 2>nul
:: ----------------------------------------------------------


:: Limit file size for archive files to be scanned to minimum (revert)
echo --- Limit file size for archive files to be scanned to minimum (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "ArchiveMaxSize" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -------------Disable scheduled scans (revert)-------------
:: ----------------------------------------------------------
echo --- Disable scheduled scans (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "ScheduleDay" /f 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'ScanScheduleDay'; $defaultValue = '0'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----Disable randomizing scheduled task times (revert)-----
:: ----------------------------------------------------------
echo --- Disable randomizing scheduled task times (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender" /v "RandomizeScheduleTaskTimes" /f 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'RandomizeScheduleTaskTimes'; $defaultValue = $True; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----------Disable scheduled full-scans (revert)-----------
:: ----------------------------------------------------------
echo --- Disable scheduled full-scans (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "ScanParameters" /f 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'ScanParameters'; $defaultValue = '1'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 = $true <# $false #>; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: --Limit how many times quick scans run per day (revert)---
:: ----------------------------------------------------------
echo --- Limit how many times quick scans run per day (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Scan" /v "QuickScanInterval" /f 2>nul
:: ----------------------------------------------------------


:: Disable scanning after security intelligence (signature) update (revert)
echo --- Disable scanning after security intelligence (signature) update (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "DisableScanOnUpdate" /f 2>nul
:: ----------------------------------------------------------


:: Limit Defender updates to those that complete gradual release cycle (revert)
echo --- Limit Defender updates to those that complete gradual release cycle (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisableGradualRelease'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: Limit Defender engine updates to those that complete gradual release cycle (revert)
echo --- Limit Defender engine updates to those that complete gradual release cycle (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'EngineUpdatesChannel'; $defaultValue = 'NotConfigured'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: Limit Defender platform updates to those that complete gradual release cycle (revert)
echo --- Limit Defender platform updates to those that complete gradual release cycle (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'PlatformUpdatesChannel'; $defaultValue = 'NotConfigured'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: Limit Defender definition updates to those that complete gradual release cycle (revert)
echo --- Limit Defender definition updates to those that complete gradual release cycle (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DefinitionUpdatesChannel'; $defaultValue = 'NotConfigured'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: Disable forced security intelligence (signature) updates from Microsoft Update (revert)
echo --- Disable forced security intelligence (signature) updates from Microsoft Update (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "ForceUpdateFromMU" /f 2>nul
:: ----------------------------------------------------------


:: Disable security intelligence (signature) updates when running on battery power (revert)
echo --- Disable security intelligence (signature) updates when running on battery power (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "DisableScheduledSignatureUpdateOnBattery" /f 2>nul
:: ----------------------------------------------------------


:: Disable checking for the latest virus and spyware security intelligence (signature) on startup (revert)
echo --- Disable checking for the latest virus and spyware security intelligence (signature) on startup (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "UpdateOnStartUp" /f 2>nul
:: ----------------------------------------------------------


:: Disable catch-up security intelligence (signature) updates (revert)
echo --- Disable catch-up security intelligence (signature) updates (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "SignatureUpdateCatchupInterval" /f 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'SignatureUpdateCatchupInterval'; $defaultValue = '1'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: Limit spyware security intelligence (signature) updates (revert)
echo --- Limit spyware security intelligence (signature) updates (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "ASSignatureDue" /f 2>nul
:: ----------------------------------------------------------


:: Limit virus security intelligence (signature) updates (revert)
echo --- Limit virus security intelligence (signature) updates (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "AVSignatureDue" /f 2>nul
:: ----------------------------------------------------------


:: Disable security intelligence (signature) update on startup (revert)
echo --- Disable security intelligence (signature) update on startup (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "DisableUpdateOnStartupWithoutEngine" /f 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'SignatureDisableUpdateOnStartupWithoutEngine'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: Disable automatically checking security intelligence (signature) updates (revert)
echo --- Disable automatically checking security intelligence (signature) updates (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "ScheduleDay" /f 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'SignatureScheduleDay'; $defaultValue = '8'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: Limit update checks for security intelligence (signature) updates (revert)
echo --- Limit update checks for security intelligence (signature) updates (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "SignatureUpdateInterval" /f 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'SignatureUpdateInterval'; $defaultValue = '0'; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
:: ----------------------------------------------------------


:: Disable definition updates through both WSUS and the Microsoft Malware Protection Center (revert)
echo --- Disable definition updates through both WSUS and the Microsoft Malware Protection Center (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "CheckAlternateHttpLocation" /f 2>nul
:: ----------------------------------------------------------


:: Disable definition updates through both WSUS and Windows Update (revert)
echo --- Disable definition updates through both WSUS and Windows Update (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates" /v "CheckAlternateDownloadLocation" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: --------Disable Windows Defender logging (revert)---------
:: ----------------------------------------------------------
echo --- Disable Windows Defender logging (revert)
reg add "HKLM\System\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d "1" /f
reg add "HKLM\System\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d "1" /f
:: ----------------------------------------------------------


:: Disable ETW Provider of Windows Defender (Windows Event Logs) (revert)
echo --- Disable ETW Provider of Windows Defender (Windows Event Logs) (revert)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender/Operational" /v "Enabled" /t Reg_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender/WHC" /v "Enabled" /t Reg_DWORD /d 1 /f
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ------------Do not send Watson events (revert)------------
:: ----------------------------------------------------------
echo --- Do not send Watson events (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableGenericRePorts" /f 2>nul
:: ----------------------------------------------------------


:: Send minimum Windows software trace preprocessor (WPP Software Tracing) levels (revert)
echo --- Send minimum Windows software trace preprocessor (WPP Software Tracing) levels (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Reporting" /v "WppTracingLevel" /f 2>nul
:: ----------------------------------------------------------


:: Disable auditing events in Microsoft Defender Application Guard (revert)
echo --- Disable auditing events in Microsoft Defender Application Guard (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\AppHVSI" /v "AuditApplicationGuard" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---Hide Windows Defender Security Center icon (revert)----
:: ----------------------------------------------------------
echo --- Hide Windows Defender Security Center icon (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v "HideSystray" /f 2>nul
:: ----------------------------------------------------------


:: Remove "Scan with Windows Defender" option from context menu (revert)
echo --- Remove "Scan with Windows Defender" option from context menu (revert)
reg add "HKLM\SOFTWARE\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}" /v "InprocServer32" /t REG_SZ /d "%ProgramFiles%\Windows Defender\shellext.dll" /f
reg add "HKCR\SOFTWARE\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f
reg add "HKCR\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" /ve /t REG_SZ /d "%ProgramFiles%\Windows Defender\shellext.dll" /f
reg add "HKCR\*\shellex\ContextMenuHandlers" /v "EPP" /t REG_SZ /d "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f
reg add "HKCR\Directory\shellex\ContextMenuHandlers" /v "EPP" /t REG_SZ /d "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f
reg add "HKCR\Drive\shellex\ContextMenuHandlers" /v "EPP" /t REG_SZ /d "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f
:: ----------------------------------------------------------


:: Remove Windows Defender Security Center from taskbar (revert)
echo --- Remove Windows Defender Security Center from taskbar (revert)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /t REG_EXPAND_SZ /d "%windir%\system32\SecurityHealthSystray.exe" /f
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -------------Enable headless UI mode (revert)-------------
:: ----------------------------------------------------------
echo --- Enable headless UI mode (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\UX Configuration" /v "UILockdown" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----Restrict threat history to administrators (revert)----
:: ----------------------------------------------------------
echo --- Restrict threat history to administrators (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$propertyName = 'DisablePrivacyMode'; $defaultValue = $False; $setDefaultOnWindows10 = $true <# $false #>; $setDefaultOnWindows11 =  $false; $osVersion = [System.Environment]::OSVersion.Version; function Test-IsWindows10 { ($osVersion.Major -eq 10) -and ($osVersion.Build -lt 22000) }; function Test-IsWindows11 { ($osVersion.Major -gt 10) -or (($osVersion.Major -eq 10) -and ($osVersion.Build -ge 22000)) }; <# ------ Set-MpPreference ------ #>; if(($setDefaultOnWindows10 -and (Test-IsWindows10)) -or ($setDefaultOnWindows11 -and (Test-IsWindows11))) {; if((Get-MpPreference -ErrorAction Ignore).$propertyName -eq $defaultValue) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is already configured as desired `"^""$defaultValue`"^""."^""; exit 0; }; $command = Get-Command 'Set-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Set-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName `$defaultValue -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default `"^""$defaultValue`"^""."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }; }; <# ------ Remove-MpPreference ------ #>; $command = Get-Command 'Remove-MpPreference' -ErrorAction Ignore; if (!$command) {; Write-Warning 'Skipping. Command not found: "^""Remove-MpPreference"^"".'; exit 1; }; if(!$command.Parameters.Keys.Contains($propertyName)) {; Write-Host "^""Skipping. `"^""$propertyName`"^"" is not supported for `"^""$($command.Name)`"^""."^""; exit 0; }; try {; Invoke-Expression "^""$($command.Name) -Force -$propertyName -ErrorAction Stop"^""; Write-Host "^""Successfully restored `"^""$propertyName`"^"" to its default."^""; exit 0; } catch {; if ($_.FullyQualifiedErrorId -like '*0x800106ba*') {; Write-Warning "^""Cannot $($command.Name): Defender service (WinDefend) is not running. Try to enable it (revert) and re-run this?"^""; } else {; Write-Error "^""Failed to set using $($command.Name): $_"^""; }; exit 1; }"
PowerShell -ExecutionPolicy Unrestricted -Command "$command = 'reg delete "^""HKLM\SOFTWARE\Microsoft\Windows Defender\UX Configuration"^"" /v "^""DisablePrivacyMode"^"" /f 2>nul'; $trustedInstallerSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464'); $trustedInstallerName = $trustedInstallerSid.Translate([System.Security.Principal.NTAccount]); $streamOutFile = New-TemporaryFile; $batchFile = New-TemporaryFile; try {; $batchFile = Rename-Item $batchFile "^""$($batchFile.BaseName).bat"^"" -PassThru; "^""@echo off`r`n$command`r`nexit 0"^"" | Out-File $batchFile -Encoding ASCII; $taskName = 'privacy.sexy invoke'; schtasks.exe /delete /tn "^""$taskName"^"" /f 2>&1 | Out-Null <# Clean if something went wrong before, suppress any output #>; $taskAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "^""cmd /c `"^""$batchFile`"^"" > $streamOutFile 2>&1"^""; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Register-ScheduledTask -TaskName $taskName -Action $taskAction -Settings $settings -Force -ErrorAction Stop | Out-Null; try {; ($scheduleService = New-Object -ComObject Schedule.Service).Connect(); $scheduleService.GetFolder('\').GetTask($taskName).RunEx($null, 0, 0, $trustedInstallerName) | Out-Null; $timeOutLimit = (Get-Date).AddMinutes(5); Write-Host "^""Running as $trustedInstallerName"^""; while((Get-ScheduledTaskInfo $taskName).LastTaskResult -eq 267009) {; Start-Sleep -Milliseconds 200; if((Get-Date) -gt $timeOutLimit) {; Write-Warning "^""Skipping results, it took so long to execute script."^""; break;; }; }; if (($result = (Get-ScheduledTaskInfo $taskName).LastTaskResult) -ne 0) {; Write-Error "^""Failed to execute with exit code: $result."^""; }; } finally {; schtasks.exe /delete /tn "^""$taskName"^"" /f | Out-Null <# Outputs only errors #>; }; Get-Content $streamOutFile; } finally {; Remove-Item $streamOutFile, $batchFile; }"
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---Hide the "Virus and threat protection" area (revert)---
:: ----------------------------------------------------------
echo --- Hide the "Virus and threat protection" area (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Virus and threat protection" /v "UILockdown" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----Hide the "Ransomware data recovery" area (revert)-----
:: ----------------------------------------------------------
echo --- Hide the "Ransomware data recovery" area (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Virus and threat protection" /v "HideRansomwareRecovery" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---------Hide the "Family options" area (revert)----------
:: ----------------------------------------------------------
echo --- Hide the "Family options" area (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Family options" /v "UILockdown" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: --Hide the "Device performance and health" area (revert)--
:: ----------------------------------------------------------
echo --- Hide the "Device performance and health" area (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device performance and health" /v "UILockdown" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -------Hide the "Account protection" area (revert)--------
:: ----------------------------------------------------------
echo --- Hide the "Account protection" area (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Account protection" /v "UILockdown" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---Hide the "App and browser protection" area (revert)----
:: ----------------------------------------------------------
echo --- Hide the "App and browser protection" area (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" /v "UILockdown" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----------Hide the Device security area (revert)----------
:: ----------------------------------------------------------
echo --- Hide the Device security area (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security" /v "UILockdown" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----------Disable the Clear TPM button (revert)-----------
:: ----------------------------------------------------------
echo --- Disable the Clear TPM button (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security" /v "DisableClearTpmButton" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -------Disable the Secure boot area button (revert)-------
:: ----------------------------------------------------------
echo --- Disable the Secure boot area button (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security" /v "HideSecureBoot" /f 2>nul
:: ----------------------------------------------------------


:: Hide the Security processor (TPM) troubleshooter page (revert)
echo --- Hide the Security processor (TPM) troubleshooter page (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security" /v "HideTPMTroubleshooting" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---Hide the TPM Firmware Update recommendation (revert)---
:: ----------------------------------------------------------
echo --- Hide the TPM Firmware Update recommendation (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security" /v "DisableTpmFirmwareUpdateWarning" /f 2>nul
:: ----------------------------------------------------------


:: Disable Windows Action Center security and maintenance notifications (revert)
echo --- Disable Windows Action Center security and maintenance notifications (revert)
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /f 2>nul
:: ----------------------------------------------------------


:: Disable all Windows Defender Antivirus notifications (revert)
echo --- Disable all Windows Defender Antivirus notifications (revert)
reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration" /v "Notification_Suppress" /f 2>nul
reg delete "HKCU\SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "Notification_Suppress" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ----------Suppress reboot notifications (revert)----------
:: ----------------------------------------------------------
echo --- Suppress reboot notifications (revert)
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\UX Configuration" /v "SuppressRebootNotification" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: -------------Hide all notifications (revert)--------------
:: ----------------------------------------------------------
echo --- Hide all notifications (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /v "DisableNotifications" /f 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableNotifications" /f 2>nul
:: ----------------------------------------------------------


:: ----------------------------------------------------------
:: ---------Hide non-critical notifications (revert)---------
:: ----------------------------------------------------------
echo --- Hide non-critical notifications (revert)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /v "DisableEnhancedNotifications" /f 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableEnhancedNotifications" /f 2>nul
reg delete "HKLM\Software\Policies\Microsoft\Windows Defender\Reporting" /v "DisableEnhancedNotifications" /f 2>nul
:: ----------------------------------------------------------


pause
exit /b 0