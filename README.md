# OSTrace

> A lightweight PowerShell script that fingerprints your Windows installation and detects custom/modified OS builds — no external dependencies, no bloat.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)
![Platform](https://img.shields.io/badge/Platform-Windows-informational?logo=windows)
![Admin](https://img.shields.io/badge/Requires-Administrator-red)

---

## Preview

```
Boot Time:       03/05/2026 12:59:25
Windows Version: Windows 10 Pro (debloated)
```

```
Boot Time:       03/05/2026 12:59:25
Windows Version: Windows 10 Pro
```

---

## Features

- Displays system boot time in `dd/MM/yyyy HH:mm:ss` local time
- Detects Windows version and edition across all versions (7, 8, 10, 11, Server)
- Fingerprints modified/custom Windows builds using tiered heuristic detection
- Auto-relaunches as Administrator for deeper checks
- Early-exit logic — stops as soon as a conclusive signal is found
- Zero external dependencies, pure PowerShell

---

## Usage

```powershell
powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/iKorqo/OSTrace/refs/heads/main/OSTrace')"
```

---

## Requirements

- Windows 7 or later
- Windows PowerShell 5.1 or later
- Administrator privileges (auto-requested)

---

## FAQ

**Why does it need admin?**
Several checks — like reading the CBS log, querying Windows packages, and accessing protected registry keys — are gated behind elevation. Without admin, roughly half the detections are skipped.

**Is any data sent anywhere?**
No. Everything runs locally. Nothing is logged, transmitted, or stored.

**Why does it show `(debloated)` instead of the mod name?**
If the mod didn't leave any named branding (like a custom WMI description or registered organization), WinProbe falls back to describing what it detected behaviorally. Named mods like Atlas OS that brand themselves will show their name directly.
