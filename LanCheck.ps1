# Configuration
$devices = @(
    @{ IP = "<DEVICE_IP_1>"; Name = "Device 1" },
    @{ IP = "<DEVICE_IP_2>"; Name = "Device 2" },
    @{ IP = "<DEVICE_IP_3>"; Name = "Device 3" }
    # Add more devices as needed
)

# Gotify configuration
$gotifyUrl = "<GOTIFY_URL>" # Example: "http://example.com"
$gotifyToken = "<GOTIFY_TOKEN>"
$gotifyPort = "<GOTIFY_PORT>" # Example: "8080"

# Compose full Gotify URL
$gotifyFullUrl = "${gotifyUrl}:${gotifyPort}/message"

# Log file path
$logFilePath = "C:\LanLogs\DeviceStatus.log"

# Function to check Gotify availability with limited retries
function Wait-ForGotify {
    $gotifyHost = $gotifyUrl -replace "http://", "" -replace "https://", ""
    $attempts = 0
    $maxAttempts = 5

    while ($attempts -lt $maxAttempts -and -not (Test-Connection -ComputerName $gotifyHost -Count 3 -Quiet)) {
        $attempts++
        Write-Host "$gotifyUrl not reachable. Attempt $attempts of $maxAttempts..."
        Start-Sleep -Seconds 10
    }

    if ($attempts -ge $maxAttempts) {
        Write-Host "Gotify is not reachable after $maxAttempts attempts. Continuing without notifications."
        return $false
    }

    return $true
}

# Check Gotify availability once
$gotifyAvailable = Wait-ForGotify

# List to track already notified devices
$notifiedDevices = @{}

# Device status check
foreach ($device in $devices) {
    $ping = Test-Connection -ComputerName $device.IP -Count 3 -Quiet

    if (-not $ping -and -not $notifiedDevices.ContainsKey($device.IP)) {
        # If the device is unreachable and has not been notified yet
        $timestamp = (Get-Date).ToString("dd-MM-yyyy HH:mm:ss")
        $message = "$timestamp, $($device.Name) is unreachable: IP=$($device.IP)"

        # Write to log file
        Add-Content -Path $logFilePath -Value $message

        # Send notification to Gotify if available
        if ($gotifyAvailable) {
            $gotifyPayload = @{
                title = "$($device.Name) is unreachable"
                message = $message
                priority = 5
            } | ConvertTo-Json -Depth 3

            try {
                Invoke-RestMethod -Uri $gotifyFullUrl -Method POST -Body $gotifyPayload -ContentType "application/json" -Headers @{ "X-Gotify-Key" = $gotifyToken }
                Write-Host "Notification sent for $($device.Name)."
            } catch {
                Write-Host "Error sending notification to Gotify for $($device.Name)."
                $gotifyAvailable = $false
            }
        } else {
            Write-Host "Gotify not available. Notification not sent for $($device.Name)."
        }

        # Add the device to the notified list
        $notifiedDevices[$device.IP] = $true
    }
}

# Script ends if all devices are reachable
exit 0
