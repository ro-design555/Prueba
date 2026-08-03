$sigPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Unmanaged"
$profPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles"

function Convert-BinaryDate($bytes) {
    if ($null -eq $bytes -or $bytes.Length -lt 16) { return "N/A" }
    try {
        $year   = [BitConverter]::ToInt16($bytes, 0)
        $month  = [BitConverter]::ToInt16($bytes, 2)
        $day    = [BitConverter]::ToInt16($bytes, 6)
        $hour   = [BitConverter]::ToInt16($bytes, 8)
        $minute = [BitConverter]::ToInt16($bytes, 10)
        $second = [BitConverter]::ToInt16($bytes, 12)
        Get-Date -Year $year -Month $month -Day $day -Hour $hour -Minute $minute -Second $second
    } catch { "N/A" }
}

Get-ChildItem $sigPath | ForEach-Object {
    $sig = Get-ItemProperty -Path $_.PSPath

    # MAC del gateway
    $mac = if ($sig.DefaultGatewayMac) {
        ($sig.DefaultGatewayMac | ForEach-Object { "{0:X2}" -f $_ }) -join ':'
    } else { "N/A" }

    # Buscar el perfil correspondiente usando el GUID
    $guid = $sig.ProfileGuid
    $ssid = "N/A"; $fechaCreacion = "N/A"; $ultimaConexion = "N/A"

    if ($guid) {
        $profKey = Join-Path $profPath $guid
        if (Test-Path $profKey) {
            $prof = Get-ItemProperty -Path $profKey
            $ssid = $prof.ProfileName
            $fechaCreacion = Convert-BinaryDate $prof.DateCreated
            $ultimaConexion = Convert-BinaryDate $prof.DateLastConnected
        }
    }

    [PSCustomObject]@{
        SSID           = $ssid
        MAC_Gateway    = $mac
        FechaCreacion  = $fechaCreacion
        UltimaConexion = $ultimaConexion
    }
} | Format-Table -AutoSize >> %temp%\Wi-Fi-PASS.txt
