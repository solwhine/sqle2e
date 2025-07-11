# Simulated Deployment Script for Release 1.0

# 1. Target server and DB name
$serverName = "localhost"
$databaseName = "PreProd"

# 2. Path to your .sql script
$scriptPath = "..\Releases\Release1.0\Release1.0_predeploy.sql"

# 3. Run the script using sqlcmd (a SQL Server tool)
sqlcmd -S $serverName -d $databaseName -i $scriptPath

# 4. Done message
Write-Host "✅ Deployment complete!"