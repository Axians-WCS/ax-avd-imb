<#Author       : Luuk Ros
# Usage        : Perform a Full System Scan using Windows Defender
#>

#################################################################
#                 Perform Full System Scan                      #
#################################################################

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AVD AIB CUSTOMIZER PHASE: Full System Scan using Windows Defender ***"

# Check if Windows Defender is installed and enabled
Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Checking if Windows Defender is installed and enabled ***"

try {
    $defenderStatus = Get-MpComputerStatus
    if ($null -eq $defenderStatus) {
        Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Windows Defender is not installed or enabled. Exiting. ***"
        exit 1
    }
    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Windows Defender is installed and enabled. ***"
}
catch {
    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Error checking Windows Defender status: [$($_.Exception.Message)] ***"
    exit 1
}

# Run a Full System Scan
Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Running a full scan using Windows Defender ***"
try {
    Start-MpScan -ScanType FullScan
    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Full scan initiated. Monitoring progress... ***"
}
catch {
    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Error initiating full scan: [$($_.Exception.Message)] ***"
    exit 1
}

# Monitor scan progress using ScanInProgress property
try {
    do {
        Start-Sleep -Seconds 30
        $scanStatus = Get-MpComputerStatus
        if (-not $scanStatus.ScanInProgress) {
            Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Full scan completed successfully. ***"
            break
        }
        Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Scan in progress... ***"
    } while ($true)
}
catch {
    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Error monitoring scan progress: [$($_.Exception.Message)] ***"
    exit 1
}

# Check for scan results
Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Checking for threats detected during the scan ***"
try {
    $threats = Get-MpThreatDetection
    if ($threats.Count -gt 0) {
        Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Threats detected during the scan: ***"
        $threats | Format-Table -AutoSize
    } else {
        Write-Host "*** AVD AIB CUSTOMIZER PHASE *** No threats detected during the scan. ***"
    }
}
catch {
    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Error retrieving scan results: [$($_.Exception.Message)] ***"
}

# Finalize the script
$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AVD AIB CUSTOMIZER PHASE : Full System Scan - Exit Code: $LASTEXITCODE ***"
Write-Host "*** Ending AVD AIB CUSTOMIZER PHASE: Full System Scan - Time taken: $elapsedTime ***"

#############
#    END    #
#############