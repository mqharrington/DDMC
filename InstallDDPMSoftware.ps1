

<#
        .Author
        Matthew Harrington
        matt.harrington@dell.com


        .SYNOPSIS
        Install Dell Display and Peripheral Manager with any install command line switches you choose.   
         

        .DESCRIPTION
        This can be packaged into an Intunewin file along with the prebuilt ddm-setup_2.1.0.24.exe installer and associated files.  
        You will call this file with Intune.  Or you can run this .ps1 with all associated files manually bay calling PowerShell.exe  
           

        .PREREQUISITES
        You are installing this onto a Dell desktop or laptop  
      

        .NOTES
        This script is designed to be deployed as part of a Intunewin package or as a standalone installer.  
        From within Intune on the package properites you can run it like this:

        .RUNNING
        The following would be the command line you'd spedify on your Intune package that calls your Intunewin package
        powershell.exe -ExecutionPolicy Bypass -File InstallDDPMSoftware.ps1 -Arg1 "/Silent" -Arg2 "/TelemetryConsent=true" -Arg3 "/HeadlessMode=false"
        where -Arg1 -Arg2 etc would be the support install switches for ddm-setup_2.1.0.24.exe
        see install switches below

     
    
    .SUPPORTED INSTALL SWITCHES FOR DELL DISPLAY AND PERIPHERAL MANAGER (tyaken from version 2.1.0.24)

    /Silent
    /HeadlessMode=[true|false]
    /InAppUpdateLock
    /TelemetryConsent=[true|false|disable]
    /TurnOffCA
    /IncludeFeature=NetworkKVM
    /NetworkKVM=[on|off|disable]
    /NetworkKVMOutgoingPort=(default:5566)
    /NetworkKVMIncomingPort=(default:5567)
    /NetworkKVMContentTransferPort=(default:5568)
    /NetworkKVMAutoConnect=[on|off|disabled]
    /NetworkKVMContentTransfer=[on|off|disabled]
    /CreateDebugLog="PathFileName" or /l="PathFileName"
    /uninst or /X
    /h or /?


    .OTHER NOTES

    The following section of code must be listed first

    param (
        [string]$Arg1,
        [string]$Arg2,
        [string]$Arg3,
        [string]$Arg4,
        [string]$Arg5,
        [string]$Arg6,
        [string]$Arg7,
        [string]$Arg8
    )

    Because powershell.exe will be calling this .PS1 script and passing it command line arguments the param section has to be listed first.
    PowerShell needs to bind those command-line arguments to your script’s parameters before any code in the script runs.

#>



param (
    [string]$Arg1,
    [string]$Arg2,
    [string]$Arg3,
    [string]$Arg4,
    [string]$Arg5,
    [string]$Arg6,
    [string]$Arg7,
    [string]$Arg8
)


function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$LogType = "INFO",
        [string]$LogFilePath = "C:\Logs\DDPMInstallation.log"
    )

    # Ensure the log directory exists
    $logDirectory = [System.IO.Path]::GetDirectoryName($LogFilePath)
    if (!(Test-Path -Path $logDirectory)) {
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    }

    $timestamp = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    $logEntry = "$timestamp [$LogType] - $Message"
    Add-Content -Path $LogFilePath -Value $logEntry
}



# Define installer filename.  You can change the name to reflect the version you are deploying
$InstallerFile = "DDPM-Setup_2.1.0.24.exe"
Write-Log -LogType INFO -Message "Installing $InstallerFile"

# Get script location and installer path
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallerPath = Join-Path $ScriptDir $InstallerFile
write-log -LogType INFO -Message "Install path is: $InstallerPath"

# Verify installer exists
if (-not (Test-Path $InstallerPath)) {
    Write-Log -LogType ERROR -Message "Installer not found: $InstallerPath"
    exit 1
}

# Define the aruments.  each will contain a supported installer command line switch. 
# Example:  powershell.exe -ExecutionPolicy Bypass -File InstallDDPMSoftware.ps1 -Arg1 "/Silent" -Arg2 "/TelemetryConsent=true" -Arg3 "/HeadlessMode=false"

$arguments = @()
foreach ($arg in @($Arg1, $Arg2, $Arg3, $Arg4, $Arg5, $Arg6, $Arg7, $Arg8 )) {
    if ($arg) { $arguments += $arg }
}
$argumentString = $arguments -join " "


# Run installer silently
Write-Log -LogType INFO -Message "Installing Dell Display and Peripheral Manager..."
Write-Log -LogType INFO -Message "Command: $InstallerPath $argumentString"



# Run the installer and capture the exit code
$process = Start-Process -FilePath $InstallerPath -ArgumentList $argumentString -Wait -NoNewWindow -PassThru
$exitCode = $process.ExitCode
Write-Log -LogType INFO -Message "DDPM now installing..."



if ($exitCode -eq "" -or $exitCode -eq 0 -or $exitCode -eq 3010) {
    Write-Log -LogType INFO -Message "Installation completed successfully. Exit code: $exitCode"

    # Now create a reg key so you don't see the consent page when you first start DDPM
    $regPath = "HKLM:\SOFTWARE\DELL\Dell Display and Peripheral Manager\UserSettings\Local"
    $name = "IsFirstTimeWalkThroughDone_com.dell.DPM.Plugin.LogicalDevice.CONSENT_PAGE"
    $value = "True"

    # Create the registry path if it doesn't exist
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
        Write-Log -LogType INFO -Message "$regPath was created"
    }

    # Set the registry value
    New-ItemProperty -Path $regPath -Name $name -Value $value -PropertyType String -Force | Out-Null
    Write-Log -LogType INFO -Message "Disable consent in registry was set"
}
else {
    Write-Log -LogType ERROR -Message "Installer exited with code $exitCode"
    exit $exitCode
}
