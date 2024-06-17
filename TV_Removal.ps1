################################################################################
#                                                                              #
#                 TeamViewer All Versions Removal Script                       #
#                        Written by Knotty1985                                 #
#                                                                              #
#               This script checks the registry for uninstall                  #
#               strings of TeamViewer and runs an MSI uninstall                #
#               if these don't exist it also tries to detect the               #
#               executable in normal paths and run the uninstall.              #
#                                                                              #
################################################################################

$Uninstall32 = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" #32bit MSI uninstall strings
$uninstall64 = Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" #64bit MSI uninstall strings
$TeamViewer32 = $Uninstall32 | Where-Object {$_.DisplayName -Like "TeamViewer*"} #Check for TeamViewer in 32bit location
$TeamViewer64 = $uninstall64 | Where-Object {$_.DisplayName -Like "TeamViewer*"} #Check for TeamViewer in 64bit location

If ($TeamViewer32) #Attempts to uninstall TeamViewer 32 bit using MSI string
{
    Write-Output "$TeamViewer32.DisplayName $TeamViewer32.DisplayVersion is now being uninstalled"

    Net Stop TeamViewer #Stop the service and then test for it stopping

    Start-Sleep -Seconds 5
    $service = Get-Service -Name "TeamViewer"
    if ($service.Status -eq 'Stopped') {
        Write-Output "TeamViewer service stopped successfully."
    }   
    else 
    {
        Write-Output "TeamViewer service is still running."
        Exit(1)
    }

    Start-Process -FilePath ($TeamViewer32.UninstallString) -ArgumentList "/S" -WindowStyle Hidden
    Start-Sleep -Seconds 120

    if (Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe")
    {
        Write-Output "TeamViewer x86 still detected after MSI uninstall run, please remediate manually."
    }
    else 
    {
        Write-Output "TeamViewer is now uninstalled."
    }
}
elseif ($TeamViewer64) #Attempts to uninstall TeamViewer 64 bit using MSI string
{
    Write-Output "$TeamViewer64.DisplayName $TeamViewer64.DisplayVersion is now being uninstalled"

    Net Stop TeamViewer #Stop the service and then test for it stopping

    Start-Sleep -Seconds 5 
    $service = Get-Service -Name "TeamViewer"
    if ($service.Status -eq 'Stopped') {
        Write-Output "TeamViewer service stopped successfully."
    }   
    else 
    {
        Write-Output "TeamViewer service is still running."
        Exit(1)
    }

    Start-Process -FilePath ($TeamViewer64.UninstallString) -ArgumentList "/S" -WindowStyle Hidden
    Start-Sleep -Seconds 120

    if (Test-Path "C:\Program Files\TeamViewer\TeamViewer.exe")
    {
        Write-Output "TeamViewer x64 still detected after MSI uninstall run, please remediate manually."
    }
    else 
    {
        Write-Output "TeamViewer is now uninstalled."
    }
}
else #Attempts to remove TeamViewer using file path based uninstalls
{
    Write-Output "TeamViewer not found in registry, checking file paths"

    if (Test-Path "C:\Program Files\TeamViewer\TeamViewer.exe")
    {
        Write-Output "TeamViewer.exe found in Program Files, running silent uninstall"

        Net Stop TeamViewer #Stop the service and then test for it stopping

        Start-Sleep -Seconds 5
        $service = Get-Service -Name "TeamViewer"
        if ($service.Status -eq 'Stopped') {
            Write-Output "TeamViewer service stopped successfully."
        }   
        else 
        {
            Write-Output "TeamViewer service is still running."
            Exit(1)
        }

        Start-Process -FilePath "C:\Program Files\TeamViewer\uninstall.exe" -ArgumentList "/S" -PassThru
    }
    elseif (Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe")
    {
        Write-Output "TeamViewer.exe found in Program Files (x86), running silent uninstall"

        Net Stop TeamViewer

        Start-Sleep -Seconds 5
        $service = Get-Service -Name "TeamViewer"
        if ($service.Status -eq 'Stopped') {
            Write-Output "TeamViewer service stopped successfully."
        }   
        else 
        {
            Write-Output "TeamViewer service is still running."
            Exit(1)
        }

        Start-Process -FilePath "C:\Program Files (x86)\TeamViewer\uninstall.exe" -ArgumentList "/S" -PassThru
    }
    else 
    {
        Write-Output "TeamViewer is not installed in program files."    
    }

    Start-Sleep -Seconds 120

        if (Test-Path "C:\Program Files\TeamViewer\TeamViewer.exe")
    {
        Write-Output "TeamViewer.exe still found in Program Files, please remediate manually."
    }
    elseif (Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe")
    {
        Write-Output "TeamViewer.exe still found in Program Files (x86), please remediate manually"
    }
    else 
    {
        Write-Output "TeamViewer is now uninstalled."    
    }
}
