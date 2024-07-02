$Uninstall32 = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" > nul #32bit MSI uninstall strings
$uninstall64 = Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" > nul #64bit MSI uninstall strings
$TeamViewer32 = $Uninstall32 | Where-Object {$_.DisplayName -Like "TeamViewer*"} #Check for TeamViewer in 32bit location
$TeamViewer64 = $uninstall64 | Where-Object {$_.DisplayName -Like "TeamViewer*"} #Check for TeamViewer in 64bit location
$UserKeyPath = "HKU:\"
$SubKeys = Get-ChildItem -Path  $UserKeyPath
$TVKey = $Key.OpenSubKey("Software\TeamViewer")

Net Stop TeamViewer >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
Stop-Service TeamViewer -Force  >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
Stop-Process -Name TeamViewer -Force  >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
Stop-Process -Name TeamViewer_Service -Force  >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log

Start-Sleep -Seconds 5

if ($TeamViewer32)
{
    Start-Process -FilePath ($TeamViewer32.UninstallString) -ArgumentList "/S" -WindowStyle Hidden  >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log # Run the uninstall command line

    Start-Sleep -Seconds 120
}

if ($TeamViewer64) 
{
    Start-Process -FilePath ($TeamViewer64.UninstallString) -ArgumentList "/S" -WindowStyle Hidden >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log # Run the uninstall command line

    Start-Sleep -Seconds 120
}

foreach ($Key in $SubKeys)
{
    if ($TVKey)
    {
        Stop-Service TeamViewer -Force  >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
        Stop-Process -Name TeamViewer -Force  >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
        Stop-Process -Name TeamViewer_Service -Force  >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log

        Remove-Item -Path "$UserKeyPath\$($Key.Name)\Software\TeamViewer" -Recurse -Force  >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
        Write-Output "TeamViewer folder removed for $($key.Name)."  >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
    }
}

if (Test-Path "C:\Program Files\TeamViewer\TeamViewer.exe") 
{
    Start-Process -FilePath "C:\Program Files\TeamViewer\uninstall.exe" -ArgumentList "/S" -PassThru  >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log# Run the local file uninstall command
}

if (Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe")
{
    Start-Process -FilePath "C:\Program Files (x86)\TeamViewer\uninstall.exe" -ArgumentList "/S" -PassThru >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log # Run the local file uninstall command
}

if (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer)
{
    Remove-Item -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer -Recurse -Force >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
}

if (Get-ItemProperty -Path HKLM:\SOFTWARE\TeamViewer)
{
    Remove-Item -Path HKLM:\SOFTWARE\TeamViewer -Recurse -Force >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
}

if (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer)
{
    Remove-Item -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer -Recurse -Force >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
}

if (Get-ItemProperty -Path HKLM:\SOFTWARE\TeamViewer)
{
    Remove-Item -Path HKLM:\SOFTWARE\TeamViewer -Recurse -Force >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
}

Start-Sleep -Seconds 120

Remove-Item 'C:\Program Files (x86)\TeamViewer' -Recurse -Force >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
Remove-Item $TeamViewer32 -Recurse -Force >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
Remove-Item 'C:\Program Files\TeamViewer' -Recurse -Force >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log
Remove-Item $TeamViewer64 -Recurse -Force >> \\SDS-EIS-SCCM01.eis.local\Reports$\TeamViewer Reports\$env:COMPUTERNAME_TVUninstall.log


