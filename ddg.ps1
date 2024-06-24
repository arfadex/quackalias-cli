param (
    [string]$action
)

$apiKey = "YOUR_API_KEY_HERE"
$historyPath = "$env:USERPROFILE\.config\ddg" # Change this to a directory of your choice
$logFile = "$historyPath\aliases_history.txt" # Change this to a file of your choice

# Ensure the history directory exists
if (-not (Test-Path -Path $historyPath)) {
    New-Item -ItemType Directory -Path $historyPath -Force
}

function Generate-Alias {
    $url = "https://quack.duckduckgo.com/api/email/addresses"
    $headers = @{
        'Authorization' = "Bearer $apiKey"
        'Content-Type' = 'application/json'
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body "{}"
        if ($response -and $response.address) {
            $alias = "$($response.address)@duck.com"
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $entry = "$timestamp - $alias"
            Add-Content -Path $logFile -Value $entry
            Write-Output "Email alias generated: $alias"
        } else {
            Write-Output "Failed to generate alias. Response: $($response | ConvertTo-Json)"
        }
    } catch {
        Write-Output "Error generating alias: $_"
    }
}

function Show-History {
    if (Test-Path $logFile) {
        Get-Content $logFile | ForEach-Object { Write-Output $_ }
    } else {
        Write-Output "No aliases history found."
    }
}

function Show-Menu {
    Write-Output "Please choose an option:"
    Write-Output "1 - Generate email alias"
    Write-Output "2 - Show aliases history"

    $choice = Read-Host "Enter your choice (1 or 2)"
    switch ($choice) {
        "1" { Generate-Alias }
        "2" { Show-History }
        default { Write-Output "Invalid choice. Please run the script again and select a valid option." }
    }
}

if ($action) {
    switch ($action) {
        "generate" { Generate-Alias }
        "history" { Show-History }
        default { Write-Output "Usage: ddg.ps1 -action [generate|history]" }
    }
} else {
    Show-Menu
}