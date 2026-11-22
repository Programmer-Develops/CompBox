<#
.SYNOPSIS
    One-click launcher for the official Nand2Tetris GUI tools (HardwareSimulator & CPUEmulator)
    pre-staged with Shantanu Pandya's Capstone files (Roll No. 2501730014, K = 14).

.USAGE
    .\open_official_gui.ps1 -Tool hw     # Opens HardwareSimulator with Part A HDL + official .tst files ready in gui_stage/
    .\open_official_gui.ps1 -Tool cpu    # Opens CPUEmulator so you can load capstone\Box.hack directly
#>

param(
    [ValidateSet("hw", "cpu")]
    [string]$Tool = "cpu"
)

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$SuiteTools = Join-Path $Root "nand2tetris_suite\nand2tetris\tools"
$Proj5 = Join-Path $Root "nand2tetris_suite\nand2tetris\projects\5"
$Capstone = Join-Path $Root "capstone"

if ($Tool -eq "hw") {
    $Stage = Join-Path $Root "tests\gui_stage"
    New-Item -ItemType Directory -Force -Path $Stage | Out-Null
    Copy-Item "$Proj5\*" $Stage -Force
    Copy-Item "$Capstone\CPU.hdl","$Capstone\Memory.hdl","$Capstone\Computer.hdl" $Stage -Force

    Write-Host "Staged Part A HDL files alongside official Project 5 test scripts in:" -ForegroundColor Cyan
    Write-Host "  $Stage" -ForegroundColor Yellow
    Write-Host "In HardwareSimulator, load each .tst from that folder:" -ForegroundColor Green
    Write-Host "  1. CPU.tst"
    Write-Host "  2. Memory.tst  (Select View -> Screen; hold uppercase 'K' then 'Y' when prompted)"
    Write-Host "  3. ComputerAdd.tst"
    Write-Host "  4. ComputerMax.tst"
    Write-Host "  5. ComputerRect.tst (Select View -> Screen)"

    Start-Process -FilePath (Join-Path $SuiteTools "HardwareSimulator.bat") -WorkingDirectory $Stage
}
else {
    Write-Host "Launching Official CPU Emulator..." -ForegroundColor Cyan
    Write-Host "Load: $Capstone\Box.hack" -ForegroundColor Yellow
    Write-Host "Steps for screenshot:" -ForegroundColor Green
    Write-Host "  1. File -> Load Program -> select capstone\Box.hack"
    Write-Host "  2. Set Animate -> 'No animation' and Speed slider -> Fast"
    Write-Host "  3. Click the Run (>>) button"
    Write-Host "  4. Click the Keyboard icon (bottom right of Screen) and press/hold any key!"
    Write-Host "  5. Capture screenshot showing the 48x20 black box at row 14 (left edge)."

    Start-Process -FilePath (Join-Path $SuiteTools "CPUEmulator.bat") -WorkingDirectory $Capstone
}
