# File Synchronization with Google Chat Notification

A PowerShell script that synchronizes files between two folders using **Robocopy** and sends a **Google Chat** notification with the execution summary.

## Features

- Synchronizes source and destination folders using `Robocopy`
- Copies only new or modified files
- Mirrors deleted files (`/MIR`)
- Generates a Robocopy log
- Sends Google Chat notification with:
  - Job status
  - Source & destination paths
  - Number of copied files
  - Copied file names (up to 20)
  - Start time, end time, and duration

## Prerequisites

- Windows 10/11 or Windows Server
- PowerShell 5.1+
- Robocopy (built into Windows)
- Google Chat Incoming Webhook
- Read/Write access to source and destination folders

## Configuration

Update the following variables in the script:

```powershell
$SOURCE_FOLDER = "D:\sourcefolder"
$DEST_FOLDER   = "F:\des-folder"

$WEBHOOK_URL   = "YOUR_GOOGLE_CHAT_WEBHOOK_URL"
$TOPIC         = "File Backup"
```

## Robocopy Options

```text
/MIR   Mirror source to destination
/MT:32 Multi-threaded copy
/R:2   Retry failed copies twice
/W:2   Wait 2 seconds between retries
/FFT   FAT-compatible timestamps
/Z     Restartable mode
```

## Run the Script

```powershell
.\FileSync.ps1
```

Or schedule it using **Windows Task Scheduler**:

```text
Program:
powershell.exe

Arguments:
-ExecutionPolicy Bypass -File "C:\Scripts\FileSync.ps1"
```

## Exit Codes

| Code | Status |
|------|--------|
| 0–7 | Success |
| 8+ | Failed |

## Log File

```text
%TEMP%\transbackup_robocopy.log
```

## Notification Includes

- Success/Failure status
- Source & destination folders
- Files copied
- Copied file names
- Start time
- End time
- Total duration

## Benefits

- Automated folder synchronization
- Fast multi-threaded copying
- Google Chat alerts
- Execution logging
- Ideal for scheduled backups and file replication
