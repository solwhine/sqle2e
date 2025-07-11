# Run_PostDeploy_Release1.0.ps1

Write-Host "=== Running Post-Deployment Script for Release 1.0 ==="

$server = "localhost"
$database = "PreProd"
$script = "..\Releases\Release1.0\Release1.0_postdeploy.sql"

if (-Not (Test-Path $script)) {
    Write-Error "Script not found: $script"
    exit 1
}

# Run post-deploy
sqlcmd -S $server -d $database -i $script

Write-Host "✅ Post-deployment script executed successfully."