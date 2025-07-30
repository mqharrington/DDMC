.InstallDDPMSoftware.ps1
this script will install Dell Display and Peripheral Manager.  This installer supports many install command line switches.  When using device.manage.dell.com DDPM is 
required on each target system to do the actual firmware installs.  


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



I didn't want to hard code certain install switches into the InstallDDPMSoftware.ps1 script since it will vary based on customer, location, user etc..
so I used the param commands in PowerShell that allow you to pass information directly into your .ps1 file.

example:    powershell.exe -ExecutionPolicy Bypass -File InstallDDPMSoftware.ps1 -Arg1 "/Silent" -Arg2 "/TelemetryConsent=true" -Arg3 "/HeadlessMode=false"


############################################################################################################################################################################


.InstallDMAAgent2.ps1
this will install Dell Device Management Agent.   This is required when using the device.manage.dell.com peripheral management web portal.  This is installed on each target
system and checks in with device.manage.dell.com.   Policies on that web portal are then sent down to the target system, read by DMA and then passed to Dell Display and Peripheral 
Manager which in turn uses its won CLI to then run the firmware update.  


When installing the DMA agent you need to specify a Group Token that is taken from a group you've created on device.manage.dell.com   
Since you may have any groups you may need to specify different group tokens.  again I use the param commands in PowerShell that allow you to pass command line arguments
to a child .ps1 script.

example:  powershell.exe -ExecutionPolicy Bypass -File "InstallDMAAgent2.ps1" -GroupToken "Yg56ZbxpdtUJxOyR+xL8W5c7C5gTovAJfZBAg1DrOe+zplmBk2IxHLDNRFc67JGGXGk3FA=="

