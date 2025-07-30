
<#
.Author
        Matthew Harrington
        matt.harrington@dell.com

        .SYNOPSIS
        Install Dell Device Management Agent
         
        .DESCRIPTION
        This can be packaged into an Intunewin file along with the prebuilt DellDeviceManagementAgent.SubAgent_25.06.0.8.exe (or the version you are installing )
        installer and associated files.  You will call this file with Intune.  Or you can run this .ps1 with all associated files manually by calling PowerShell.exe  

        .PREREQUISITES
        You are installing this onto a Dell desktop or laptop  
        You are using Device.manage.dell.com to manage your Dell peripherials

        .NOTES
        This script is designed to be deployed as part of a Intunewin package or as a standalone installer that is called by PowerShell.exe  
        
        .RUNNING
        DHCP can be used but if a customer wants to create their own group and specify the group token this method will allow them to create a single Intunewin pakcage
        and pass that package the group token.  So if you have 5, 6 or more groups you would not have to create multiple Intunewin packages.  This script allows you to
        run PowerShell.exe and pass the group token to the child script.  Then you have 1 Intunewin package that can be run for each group token your environment has

        .EXAMPLE
        powershell.exe -ExecutionPolicy Bypass -File "InstallDMAAgent2.ps1" -GroupToken "Yg56ZbxpdtUJxOyR+xL8W5c7C5gTovAJfZBAg1DrOe+zplmBk2IxHLDNRFc67JGGXGk3FA=="

        #>

 #  Because powershell.exe will be calling this .PS1 script and passing it command line arguments the param section has to be listed first.
 #  PowerShell needs to bind those command-line arguments to your script’s parameters before any code in the script runs.
 #  $GroupToken will contain the group token taken from the device.manage.dell.com portal.  Each group there has its own unique token.
 

 param (
    [string]$GroupToken
)

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$LogType = "INFO",
        [string]$LogFilePath = "C:\Logs\DMAAgentInstall.log"
    )

    $logDirectory = [System.IO.Path]::GetDirectoryName($LogFilePath)
    if (!(Test-Path -Path $logDirectory)) {
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    }

    $timestamp = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    $logEntry = "$timestamp [$LogType] - $Message"
    Add-Content -Path $LogFilePath -Value $logEntry
}

# Installer setup
$InstallerFile = "DellDeviceManagementAgent.SubAgent_25.06.0.8.exe"
$InstallerLog = "c:\logs\DMAAgent_250608.log"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallerPath = Join-Path $ScriptDir $InstallerFile

# Final arguments – exactly like the working CMD line
$InstallerArgs = '/s /v"/qn GROUPTOKEN=' + "`"$GroupToken`"" + ' URL=https://beta-device.manage.dell.com:443 /lv* ' + $InstallerLog + '"'

Write-Log -Message "Running: $InstallerPath $InstallerArgs"

$process = Start-Process -FilePath $InstallerPath -ArgumentList $InstallerArgs -Wait -NoNewWindow -PassThru
$exitCode = $process.ExitCode
Write-Log -Message "Installer exited with code $exitCode"

if ($exitCode -eq 0) {
    Write-Log -Message "Installation completed successfully."
    exit 0
}
elseif ($exitCode -eq 3010) {
    Write-Log -Message "Installation completed successfully. Reboot required."
    exit 3010
}
else {
    Write-Log -LogType ERROR -Message "Installer failed with exit code $exitCode"
    exit $exitCode
}
