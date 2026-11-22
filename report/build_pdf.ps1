<#
.SYNOPSIS
    Converts report/report.html into a print-ready 4-page PDF for ZOSIMA submission:
    report/Capstone_Report_2501730014_Shantanu_Pandya.pdf
#>

$ReportDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HtmlFile  = Join-Path $ReportDir "report.html"
$PdfFile   = Join-Path $ReportDir "Capstone_Report_2501730014_Shantanu_Pandya.pdf"

$Browser = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $Browser) {
    Write-Error "Neither Chrome nor Edge found. Open report.html in a browser and press Ctrl+P -> Save as PDF."
    exit 1
}

$FileUri = ([System.Uri]$HtmlFile).AbsoluteUri
$TempProfile = Join-Path $env:TEMP ("n2t_pdf_profile_" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $TempProfile | Out-Null

try {
    Write-Host "Generating PDF using: $Browser" -ForegroundColor Cyan
    $proc = Start-Process -FilePath $Browser -ArgumentList @(
        "--headless=new",
        "--disable-gpu",
        "--no-first-run",
        "--no-default-browser-check",
        "--user-data-dir=`"$TempProfile`"",
        "--print-to-pdf-no-header",
        "--no-pdf-header-footer",
        "--print-to-pdf=`"$PdfFile`"",
        "`"$FileUri`""
    ) -Wait -PassThru -WindowStyle Hidden

    if (Test-Path $PdfFile) {
        $sizeKB = [Math]::Round((Get-Item $PdfFile).Length / 1KB, 1)
        Write-Host "SUCCESS: Created $PdfFile ($sizeKB KB)" -ForegroundColor Green
    } else {
        Write-Error "PDF generation failed (exit code $($proc.ExitCode))."
        exit 1
    }
}
finally {
    Remove-Item -Recurse -Force $TempProfile -ErrorAction SilentlyContinue
}
