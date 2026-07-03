# ================= USER SETTINGS =================
$SOURCE_FOLDER = "D:\Source-folder"
$DEST_FOLDER   = "F:\Desg-folder"

$WEBHOOK_URL   = "G_space_Webhook_URL"
$TOPIC         = "Set the Topic"
# =================================================

$StartTime = Get-Date
$TempLog = "$env:TEMP\filesync_robocopy.log"

# Get files that will be copied/updated before sync
$SourceFiles = Get-ChildItem $SOURCE_FOLDER -Recurse -File
$DestFilesMap = @{}

if (Test-Path $DEST_FOLDER) {
    Get-ChildItem $DEST_FOLDER -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($DEST_FOLDER.Length).TrimStart('\')
        $DestFilesMap[$rel] = $_
    }
}

$CopiedList = @()

foreach ($file in $SourceFiles) {
    $rel = $file.FullName.Substring($SOURCE_FOLDER.Length).TrimStart('\')

    if (-not $DestFilesMap.ContainsKey($rel)) {
        $CopiedList += $rel
    }
    else {
        $destFile = $DestFilesMap[$rel]
        if ($file.LastWriteTime -gt $destFile.LastWriteTime -or $file.Length -ne $destFile.Length) {
            $CopiedList += $rel
        }
    }
}

# Fast mirror copy
robocopy $SOURCE_FOLDER $DEST_FOLDER /MIR /MT:32 /R:2 /W:2 /FFT /Z /NP /TEE /LOG:$TempLog

$ExitCode = $LASTEXITCODE
$EndTime  = Get-Date

if ($ExitCode -le 7) {
    $Status      = "SUCCESS"
    $StatusLabel = "[SUCCESS]"
} else {
    $Status      = "FAILED"
    $StatusLabel = "[FAILED]"
}

$CopiedCount = $CopiedList.Count

$FileNamesText = if ($CopiedCount -eq 0) {
    "No new or updated files."
} elseif ($CopiedCount -le 20) {
    ($CopiedList | ForEach-Object { "- $_" }) -join "`n"
} else {
    (($CopiedList | Select-Object -First 20 | ForEach-Object { "- $_" }) -join "`n") + "`n...and $($CopiedCount - 20) more files"
}

# -- Card v2 payload ----------------------------------------------------------
$Payload = @{
    cardsV2 = @(
        @{
            cardId = "backup_report"
            card   = @{
                header   = @{
                    title = "$StatusLabel $TOPIC"
                }
                sections = @(
                    @{
                        header  = "Summary"
                        widgets = @(
                            @{ decoratedText = @{ topLabel = "Status";                 text = "<b>$Status</b>" } },
                            @{ decoratedText = @{ topLabel = "Source";                 text = $SOURCE_FOLDER } },
                            @{ decoratedText = @{ topLabel = "Destination";            text = $DEST_FOLDER } },
                            @{ decoratedText = @{ topLabel = "Files Copied / Updated"; text = "<b>$CopiedCount</b>" } }
                        )
                    },
                    @{
                        header  = "Copied Files"
                        widgets = @(
                            @{ textParagraph = @{ text = $FileNamesText } }
                        )
                    },
                    @{
                        header  = "Timing"
                        widgets = @(
                            @{ decoratedText = @{ topLabel = "Started At";   text = $StartTime.ToString("yyyy-MM-dd HH:mm:ss") } },
                            @{ decoratedText = @{ topLabel = "Completed At"; text = $EndTime.ToString("yyyy-MM-dd HH:mm:ss") } },
                            @{ decoratedText = @{ topLabel = "Duration";     text = "$([math]::Round(($EndTime - $StartTime).TotalSeconds)) seconds" } }
                        )
                    },
                    @{
                        widgets = @(
                            @{ textParagraph = @{ text = "<i>Regards, IT Team</i>" } }
                        )
                    }
                )
            }
        }
    )
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri $WEBHOOK_URL -Method Post -ContentType "application/json" -Body $Payload

exit $ExitCode
