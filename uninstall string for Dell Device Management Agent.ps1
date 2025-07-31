
#  Find the uninstall string for Dell Device Management Agent


$keys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

foreach ($key in $keys) {
    Get-ChildItem $key | ForEach-Object {
        $app = Get-ItemProperty $_.PSPath
        if ($app.DisplayName -like "*Dell Device Management Agent*") {
            [PSCustomObject]@{
                DisplayName      = $app.DisplayName
                UninstallGUID    = $_.PSChildName
                Publisher        = $app.Publisher
                InstallLocation  = $app.InstallLocation
            }
        }
    }
}

