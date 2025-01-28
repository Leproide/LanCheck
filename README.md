# Device Status Monitoring Script

This script is designed to monitor the reachability of network devices and send notifications using Gotify when any device becomes unreachable. The script also logs all events to a file for auditing purposes.

## Features

- Pings a list of specified devices and checks their availability.
- Logs the status of devices to a specified log file.
- Sends notifications to a Gotify server if a device is unreachable.
- Retries connecting to Gotify a limited number of times if the server is temporarily unavailable.
- Prevents duplicate notifications for the same device.

## Requirements

- PowerShell 5.0 or higher
- Access to a Gotify server

## Configuration

### 1. Define Devices
In the `Configuration` section, specify the devices to be monitored:
```powershell
$devices = @(
    @{ IP = "<DEVICE_IP_1>"; Name = "Device 1" },
    @{ IP = "<DEVICE_IP_2>"; Name = "Device 2" },
    @{ IP = "<DEVICE_IP_3>"; Name = "Device 3" }
    # Add more devices as needed
)
```
Replace `<DEVICE_IP_X>` with the IP addresses of the devices you want to monitor and provide a descriptive name for each device.

### 2. Gotify Server Configuration
Specify your Gotify server details:
```powershell
$gotifyUrl = "<GOTIFY_URL>" # Example: "http://example.com"
$gotifyToken = "<GOTIFY_TOKEN>"
$gotifyPort = "<GOTIFY_PORT>" # Example: "8080"
```
- `<GOTIFY_URL>`: URL of your Gotify server
- `<GOTIFY_TOKEN>`: API token for authentication
- `<GOTIFY_PORT>`: Port on which Gotify is running

### 3. Log File Path
Set the path for the log file:
```powershell
$logFilePath = "C:\LanLogs\DeviceStatus.log"
```
Ensure that the specified directory exists, or update the path as needed.

## How It Works

1. **Gotify Availability Check**:
   - The script checks if the Gotify server is reachable using the `Wait-ForGotify` function.
   - It retries up to 5 times with a 10-second interval between attempts.

2. **Device Status Check**:
   - Each device in the `$devices` list is pinged using `Test-Connection` with 3 attempts (`-Count 3`).
   - If a device is unreachable, the script:
     - Logs the event to the specified log file.
     - Sends a notification to the Gotify server (if reachable).

3. **Duplicate Notification Prevention**:
   - The script tracks already-notified devices in a hash table to avoid sending multiple notifications for the same device.

4. **Error Handling**:
   - If Gotify is unavailable, the script logs the issue and continues running without sending notifications.

## Example Output

### Log File Entry
```plaintext
17-01-2025 13:45:32, Device 1 is unreachable: IP=192.168.1.10
```

### Gotify Notification
- Title: `Device 1 is unreachable`
- Message: `17-01-2025 13:45:32, Device 1 is unreachable: IP=192.168.1.10`
- Priority: `5`

## Usage

### Task Scheduler Configuration

To run this script periodically using Windows Task Scheduler:

### 1. Create a New Task
1. Open Task Scheduler (`taskschd.msc`).
2. Select **Create Task**.
3. Provide a name (e.g., `Check LAN`).
4. Under **Security options**, select the user account under which the task should run.
5. Ensure **Run whether user is logged on or not** is selected.

### 2. Add a Trigger
1. Go to the **Triggers** tab.
2. Click **New...**.
3. Set the task to start at your desired time and configure it to repeat every 5 minutes.
4. Click **OK**.

### 3. Add an Action
1. Go to the **Actions** tab.
2. Click **New...**.
3. Set **Action** to **Start a program**.
4. In the **Program/script** field, enter:
   ```plaintext
   powershell.exe
   ```
5. In the **Add arguments** field, enter:
   ```plaintext
   -File "C:\Path\To\DeviceMonitor.ps1"
   ```
6. Click **OK**.

### 4. Configure Additional Settings
1. Go to the **Settings** tab.
2. Configure additional options as necessary.

### Example Task XML
```xml
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2025-01-17T00:11:45.5969562</Date>
    <Author>https://github.com/Leproide</Author>
    <URI>\Personal\Check LAN</URI>
  </RegistrationInfo>
  <Triggers>
    <CalendarTrigger>
      <Repetition>
        <Interval>PT5M</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
      <StartBoundary>2025-01-17T00:00:01</StartBoundary>
      <Enabled>true</Enabled>
      <RandomDelay>PT1M</RandomDelay>
      <ScheduleByDay>
        <DaysInterval>1</DaysInterval>
      </ScheduleByDay>
    </CalendarTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-21-2647040815-2360210210-2129855086-1001</UserId>
      <LogonType>Password</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>C:\Check_LAN.ps1</Arguments>
    </Exec>
  </Actions>
</Task>
```

## Troubleshooting

- **Log File Not Created**: Ensure the directory specified in `$logFilePath` exists and that the script has write permissions.
- **Notifications Not Sent**: Check that the Gotify server details are correct and reachable.
- **Script Does Not Run**: Ensure the script is being run with sufficient privileges (e.g., as an administrator).

## License
This script is open-source and can be used, modified, and distributed under the [GPL v2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html).

