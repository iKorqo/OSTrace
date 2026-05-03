# WinProbe

A lightweight PowerShell script that fingerprints your Windows installation and detects custom/modified OS builds — no external dependencies, no bloat.

---

## Output

```
Boot Time:       03/05/2026 12:59:25
Windows Version: Windows 10 Pro (debloated)
```

On a stock machine:
```
Boot Time:       03/05/2026 12:59:25
Windows Version: Windows 10 Pro
```

---

## Features

- Displays system boot time in `dd/MM/yyyy HH:mm:ss` format
- Detects the Windows version and edition cleanly across all versions (7, 8, 10, 11, Server)
- Fingerprints modified/custom Windows builds using tiered heuristic detection
- Auto-relaunches as Administrator for deeper checks
- Early-exit logic — stops as soon as a conclusive signal is found
- Zero external dependencies, pure PowerShell

---

## Detection Tiers

WinProbe checks for custom OS indicators in order of reliability, stopping immediately when one is found.

**Tier 1 — Instant, conclusive**
- WMI OS description set by mod installer
- Non-standard registered organization
- Abnormal `ProductName` registry value

**Tier 2 — Fast registry reads**
- Windows Store forcibly removed via policy
- Antispyware disabled via policy
- UAC disabled
- Tamper Protection off
- UBR (Update Build Revision) missing or zero

**Tier 3 — Filesystem checks**
- Windows Defender folder absent
- Core system binary company name mismatch

**Tier 4 — Elevated checks (requires admin)**
- Multiple core services disabled
- Low total service count
- Abnormally low scheduled task count
- Low Windows package/component count
- Low driver count
- CBS log reporting component store issues
- Security event log inaccessible
- No language packs installed

---

## Usage

Run directly in PowerShell:

```powershell
.\winprobe.ps1
```

If not already elevated, the script will automatically relaunch itself as Administrator.

To allow execution if blocked by policy:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
```

---

## Requirements

- Windows 7 or later
- Windows PowerShell 5.1 or later
- Administrator privileges (auto-requested)

---

## Notes

- No data is sent anywhere — everything runs locally
- Detection is heuristic-based; a flagged system is likely modified but not guaranteed
- A clean result does not guarantee an unmodified OS — some mods leave few traces
