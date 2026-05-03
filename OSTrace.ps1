Clear-Host

$os      = Get-CimInstance -ClassName Win32_OperatingSystem -Namespace root\cimv2 -ErrorAction SilentlyContinue
$bootStr = if ($os -and $os.LastBootUpTime) { $os.LastBootUpTime.ToLocalTime().ToString("dd/MM/yyyy HH:mm:ss") } else { "N/A" }

$caption = $os.Caption
$buildNum = [System.Environment]::OSVersion.Version.Build
$baseVer = if ($caption -match "Windows 11" -or $buildNum -ge 22000) { "Windows 11" }
           elseif ($caption -match "Windows 10") { "Windows 10" }
           elseif ($caption -match "Server (\d+)") { "Windows Server $($Matches[1])" }
           elseif ($caption -match "Windows 8\.1") { "Windows 8.1" }
           elseif ($caption -match "Windows 8") { "Windows 8" }
           elseif ($caption -match "Windows 7") { "Windows 7" }
           else { "N/A" }

$mod = $null

# Tier 1 — dead giveaways, instantaneous registry reads, exit immediately if found
$cv   = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction SilentlyContinue
$desc = if ($os.Description) { $os.Description.Trim() } else { "" }
if ($desc -and $desc -notmatch "^\s*$") { $mod = $desc }



if (-not $mod -and $cv.ProductName -notmatch "Windows (10|11|7|8)") { $mod = $cv.ProductName }

# Tier 2 — fast single-value registry reads, still nearly instant
if (-not $mod) {
    $polPaths = @(
        @("HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore",    "RemoveWindowsStore",  1)
        @("HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender","DisableAntiSpyware",  1)
        @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","EnableLUA",0)
        @("HKLM:\SOFTWARE\Microsoft\Windows Defender\Features","TamperProtection",    4)
    )
    foreach ($p in $polPaths) {
        try {
            if ((Get-ItemProperty $p[0] -ErrorAction Stop).($p[1]) -eq $p[2]) { $mod = "custom-windows"; break }
        } catch {}
    }
}

if (-not $mod -and (-not $cv.UBR -or $cv.UBR -eq 0)) { $mod = "stripped" }


# Tier 3 — fast filesystem existence checks, only if still not found
if (-not $mod -and -not (Test-Path "$env:ProgramFiles\Windows Defender")) { $mod = "no-defender" }

if (-not $mod) {
    try {
        if ((Get-Item "$env:SystemRoot\System32\smss.exe" -EA Stop).VersionInfo.CompanyName -notmatch "Microsoft") { $mod = "modified-binary" }
    } catch {}
}

# Tier 4 — slightly heavier checks, only reached if everything above passed
if (-not $mod) {
    $org = $cv.RegisteredOrganization
    if ($org -and $org.Trim()) { $mod = $org }
}

if (-not $mod) {
    $svcs     = Get-Service -ErrorAction SilentlyContinue
    $svcMap   = @{}; $svcs | ForEach-Object { $svcMap[$_.Name] = $_ }
    $core     = "WinDefend","SysMain","wuauserv","BITS","wscsvc","SecurityHealthService","Sense","MpsSvc","EventLog"
    $disCount = ($core | Where-Object { $s = $svcMap[$_]; $s -and $s.StartType -eq "Disabled" }).Count
    if ($disCount -ge 2)        { $mod = "debloated" }
    elseif ($svcs.Count -lt 80) { $mod = "debloated" }
}

if (-not $mod) {
    try {
        $tasks = @(Get-ScheduledTask -EA Stop).Count
        if ($tasks -lt 50) { $mod = "debloated" }
    } catch {}
}

$winVerStr = if ($mod -and $baseVer -ne "N/A") { "$baseVer ($mod)" }
             elseif ($baseVer -ne "N/A")        { $baseVer }
             else                               { "N/A" }

Write-Host "Boot Time:       $bootStr" -ForegroundColor Green
Write-Host "Windows Version: $winVerStr" -ForegroundColor Green
