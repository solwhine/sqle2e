# Simulated Deployment Script for Release 2.0

# 1. Target Server and DB
$serverName = "localhost"
$databaseName = "PreProd"

# 2. Script Paths
$preDeployScript   = "..\Releases\Release 2.0\Release2.0_PreDeploy.sql"
$mainDeployScript  = "..\Releases\Release 2.0\Release2.0_Deploy.sql"
$postDeployScript  = "..\Releases\Release 2.0\Release2.0_PostDeploy.sql"

# 3. Execute Scripts in Order
Write-Host "🔧 Running Pre-deployment script..."
sqlcmd -S $serverName -d $databaseName -i $preDeployScript

Write-Host "🚀 Running Main deployment script..."
sqlcmd -S $serverName -d $databaseName -i $mainDeployScript

Write-Host "📦 Running Post-deployment script..."
sqlcmd -S $serverName -d $databaseName -i $postDeployScript

# 4. Done Message
Write-Host "`n✅ Release 2.0 Deployment Completed Successfully!"