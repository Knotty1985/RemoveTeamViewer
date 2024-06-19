################################################################################
#                                                                              #
#                 TeamViewer All Versions Removal Script                       #
#                        Written by Knotty1985                                 #
#                                                                              #
#               This script checks the registry for uninstall                  #
#               strings of TeamViewer and runs an MSI uninstall                #
#               if these don't exist it also tries to detect the               #
#               executable in normal paths and run the uninstall.              #
#               To ensure cleanup, it then checks for leftover                 #
#               registry keys and removes them.                                #
#                                                                              #
################################################################################

$Uninstall32 = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" > nul#32bit MSI uninstall strings
$uninstall64 = Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" > nul #64bit MSI uninstall strings
$TeamViewer32 = $Uninstall32 | Where-Object {$_.DisplayName -Like "TeamViewer*"} #Check for TeamViewer in 32bit location
$TeamViewer64 = $uninstall64 | Where-Object {$_.DisplayName -Like "TeamViewer*"} #Check for TeamViewer in 64bit location
$UserKeyPath = "HKU:\"
$SubKeys = Get-ChildItem -Path  $UserKeyPath
$TVKey = $Key.OpenSubKey("Software\TeamViewer")

if ($TeamViewer32) #Attempts to uninstall TeamViewer 32 bit using MSI string
{
    Write-Output "$TeamViewer32.DisplayName $TeamViewer32.DisplayVersion is now being uninstalled"

    $service = Get-Service -Name "TeamViewer" # Check if the service is running

    if ($service.Status -ne 'Stopped')
    {
        Net Stop TeamViewer 2> nul # Stop the service if it was running
    }

    Start-Sleep -Seconds 5
    
    $service = Get-Service -Name "TeamViewer" # Recheck the service has stopped

    if ($service.Status -eq 'Stopped') 
    {
        Write-Output "TeamViewer service stopped successfully."
    }   
    else 
    {
        Write-Output "TeamViewer service is still running."
        Exit(1) #Cancel if service is still running after attempting to stop it, uninstall will fail if it is running.
    }

    Start-Process -FilePath ($TeamViewer32.UninstallString) -ArgumentList "/S" -WindowStyle Hidden 2> nul # Run the uninstall command line

    Start-Sleep -Seconds 120 # Wait 2 minutes to ensure the removal has completed.

    if (Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe") # Test for removal of the file path post uninstall.
    {
        Write-Output "TeamViewer x86 still detected after MSI uninstall run, please remediate manually."
    }
    else 
    {
        Write-Output "TeamViewer is now uninstalled."
        # Clean up registry keys from 64bit, 32bit and user SID locations
        if (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer)
        {
            Remove-Item -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer -Recurse -Force 2> nul
            Write-Output "64bit key path removed."
        }
        else { Write-Output "64bit key not found" }

        if (Get-ItemProperty -Path HKLM:\SOFTWARE\TeamViewer)
        {
            Remove-Item -Path HKLM:\SOFTWARE\TeamViewer -Recurse -Force 2> nul
            Write-Output "32bit key path removed."
        }
        else { Write-Output "32bit key not found" }

        foreach ($Key in $SubKeys)
        {
            if ($TVKey)
            {
                Remove-Item -Path "$UserKeyPath\$($Key.Name)\Software\TeamViewer" -Recurse -Force 2> nul
                Write-Output "TeamViewer folder removed for $($key.Name)."
            }
            else { Write-Output "No TV registry keys found under user SID $($Key.Name)." }
        }
    }
}
elseif ($TeamViewer64) #Attempts to uninstall TeamViewer 64 bit using MSI string
{
    Write-Output "$TeamViewer64.DisplayName $TeamViewer64.DisplayVersion is now being uninstalled"

    $service = Get-Service -Name "TeamViewer" # Check if the service is running

    if ($service.Status -ne 'Stopped')
    {
        Net Stop TeamViewer 2> nul # Attempt to stop the service if running
    }

    Start-Sleep -Seconds 5
        
    $service = Get-Service -Name "TeamViewer" # Recheck the service has now stopped
    
    if ($service.Status -eq 'Stopped') 
    {
        Write-Output "TeamViewer service stopped successfully."
    }   
    else 
    {
        Write-Output "TeamViewer service is still running."
        Exit(1) #Cancel if service is still running after attempting to stop it, uninstall will fail if it is running.
    }

    Start-Process -FilePath ($TeamViewer64.UninstallString) -ArgumentList "/S" -WindowStyle Hidden 2> nul # Run the uninstall command line

    Start-Sleep -Seconds 120 # Wait 2 minutes for uninstall to complete

    if (Test-Path "C:\Program Files\TeamViewer\TeamViewer.exe") # Test for existence of the file path after uninstall
    {
        Write-Output "TeamViewer x64 still detected after MSI uninstall run, please remediate manually."
    }
    else 
    {
        Write-Output "TeamViewer is now uninstalled."
        # Clean up registry keys from 64bit, 32bit and user SID locations
        if (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer)
        {
            Remove-Item -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer -Recurse -Force 2> nul
            Write-Output "64bit key path removed."
        }
        else { Write-Output "64bit key not found" }

        if (Get-ItemProperty -Path HKLM:\SOFTWARE\TeamViewer)
        {
            Remove-Item -Path HKLM:\SOFTWARE\TeamViewer -Recurse -Force 2> nul
            Write-Output "32bit key path removed."
        }
        else { Write-Output "32bit key not found" }

        foreach ($Key in $SubKeys)
        {
            if ($TVKey)
            {
                Remove-Item -Path "$UserKeyPath\$($Key.Name)\Software\TeamViewer" -Recurse -Force 2> nul
                Write-Output "TeamViewer folder removed for $($key.Name)."
            }
            else { Write-Output "No TV registry keys found under user SID $($Key.Name)." }
        }
    }
}
else #Attempts to remove TeamViewer using file path based uninstalls assuming MSI options aren't available
{
    Write-Output "TeamViewer not found in registry, checking file paths"

    if (Test-Path "C:\Program Files\TeamViewer\TeamViewer.exe") # Test file path for existence in the 64bit location
    {
        Write-Output "TeamViewer.exe found in Program Files, running silent uninstall"

        $service = Get-Service -Name "TeamViewer" # Check if the service is running

        if ($service.Status -ne 'Stopped')
        {
            Net Stop TeamViewer 2> nul # Attempt to stop the service if running
        }

        Start-Sleep -Seconds 5
            
        $service = Get-Service -Name "TeamViewer" # Recheck the service has stopped
    
        if ($service.Status -eq 'Stopped') 
        {
            Write-Output "TeamViewer service stopped successfully."
        }   
        else 
        {
            Write-Output "TeamViewer service is still running."
            Exit(1) #Cancel if service is still running after attempting to stop it, uninstall will fail if it is running.
        }

        Start-Process -FilePath "C:\Program Files\TeamViewer\uninstall.exe" -ArgumentList "/S" -PassThru 2> nul # Run the local file uninstall command
    }
    elseif (Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe") # check the file path exist in 32 bit if not found in 64 bit location
    {
        Write-Output "TeamViewer.exe found in Program Files (x86), running silent uninstall"

        $service = Get-Service -Name "TeamViewer" # Check if the service is running

        if ($service.Status -ne 'Stopped')
        {
            Net Stop TeamViewer 2> nul # Attempt to stop the service
        }

        Start-Sleep -Seconds 5
            
        $service = Get-Service -Name "TeamViewer" # Recheck the service has stopped
    
        if ($service.Status -eq 'Stopped') 
        {
            Write-Output "TeamViewer service stopped successfully."
        }   
        else 
        {
            Write-Output "TeamViewer service is still running."
            Exit(1) #Cancel if service is still running after attempting to stop it, uninstall will fail if it is running.
        }

        Start-Process -FilePath "C:\Program Files (x86)\TeamViewer\uninstall.exe" -ArgumentList "/S" -PassThru 2> nul # Run the local file uninstall command
        # Remove any leftover registry keys from the 64bit, 32bit and user SID locations
        if (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer)
        {
            Remove-Item -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer -Recurse -Force 2> nul
            Write-Output "64bit key path removed."
        }
        else { Write-Output "64bit key not found" }

        if (Get-ItemProperty -Path HKLM:\SOFTWARE\TeamViewer)
        {
            Remove-Item -Path HKLM:\SOFTWARE\TeamViewer -Recurse -Force 2> nul
            Write-Output "32bit key path removed."
        }
        else { Write-Output "32bit key not found" }

        foreach ($Key in $SubKeys)
        {
            if ($TVKey)
            {
                Remove-Item -Path "$UserKeyPath\$($Key.Name)\Software\TeamViewer" -Recurse -Force 2> nul
                Write-Output "TeamViewer folder removed for $($key.Name)."
            }
            else { Write-Output "No TV registry keys found under user SID $($Key.Name)." }
        }
    }
    else 
    {
        Write-Output "TeamViewer is not installed in program files."
        # Remove any leftover registry keys from the 64bit, 32bit and user SID locations
        if (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer)
        {
            Remove-Item -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer -Recurse -Force 2> nul
            Write-Output "64bit key path removed."
        }
        else { Write-Output "64bit key not found" }

        if (Get-ItemProperty -Path HKLM:\SOFTWARE\TeamViewer)
        {
            Remove-Item -Path HKLM:\SOFTWARE\TeamViewer -Recurse -Force 2> nul
            Write-Output "32bit key path removed."
        }
        else { Write-Output "32bit key not found" }

        foreach ($Key in $SubKeys)
        {
            if ($TVKey)
            {
                Remove-Item -Path "$UserKeyPath\$($Key.Name)\Software\TeamViewer" -Recurse -Force 2> nul
                Write-Output "TeamViewer folder removed for $($key.Name)."
            }
            else { Write-Output "No TV registry keys found under user SID $($Key.Name)." }
        }
    }

    Start-Sleep -Seconds 120
    # Retest for continued existence of the file paths post removal attempts
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
        # Remove any leftover registry keys from 64bit, 32bit and user SID locations
        if (Test-Path -Path HKLM:\SOFTWARE\Wow6432Node\TeamViewer)
        {
            Write-Output "64bit key path still exists."
        }

        if (Test-Path -Path HKLM:\SOFTWARE\TeamViewer)
        {
            Write-Output "32bit key path still exists."
        }

        foreach ($Key in $SubKeys)
        {
            if ($TVKey)
            {
                Write-Output "TeamViewer key still exists under user SID $($key.Name)."
            }
        }
    }
}
