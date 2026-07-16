# PowerShell script to download Microsoft ISO files
# Requires PowerShell 5.1 or higher

# Define download URLs and filenames
$downloads = @(
    @{
        Url = "https://cdimage.kali.org/kali-2026.1/kali-linux-2026.1-installer-amd64.iso"
        FileName = "kali-linux-2026.1-installer-amd64.iso"
    }
)

# Set download directory (change this to your preferred location)
$downloadPath = ".\isos"

# Create download directory if it doesn't exist
if (-not (Test-Path -Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath -Force | Out-Null
    Write-Host "Created download directory: $downloadPath" -ForegroundColor Green
}

Write-Host "`nStarting downloads..." -ForegroundColor Cyan
Write-Host "Download location: $downloadPath`n" -ForegroundColor Yellow

# Download each file
$downloadCount = 0
foreach ($item in $downloads) {
    $downloadCount++
    $destination = Join-Path -Path $downloadPath -ChildPath $item.FileName
    
    Write-Host "[$downloadCount/$($downloads.Count)] Downloading: $($item.FileName)" -ForegroundColor Cyan
    
    # Check if file already exists
    if (Test-Path -Path $destination) {
        Write-Host "  File already exists. Skipping..." -ForegroundColor Yellow
        continue
    }
    
    try {
        # Download with progress
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $item.Url -OutFile $destination -UseBasicParsing
        $ProgressPreference = 'Continue'
        
        # Get file size
        $fileSize = (Get-Item $destination).Length / 1GB
        Write-Host "  Download complete! Size: $([math]::Round($fileSize, 2)) GB" -ForegroundColor Green
    }
    catch {
        Write-Host "  Error downloading file: $($_.Exception.Message)" -ForegroundColor Red
        # Remove partial download if it exists
        if (Test-Path -Path $destination) {
            Remove-Item -Path $destination -Force
        }
    }
    
    Write-Host ""
}

Write-Host "All downloads completed!" -ForegroundColor Green
Write-Host "Files saved to: $downloadPath" -ForegroundColor Yellow
