# READ-ONLY. Run in Windows PowerShell, on the Oracle database host.
Write-Host 'Oracle services:'
Get-Service | Where-Object { $_.Name -match 'Oracle|TNS' } | Select-Object Name,Status,DisplayName
Write-Host 'Listener TCP reachability (change to actual host/port):'
Test-NetConnection 127.0.0.1 -Port 1521
Write-Host 'Oracle environment variables:'
Get-ChildItem Env:ORACLE_HOME,Env:ORACLE_SID -ErrorAction SilentlyContinue
Write-Host 'Local disks and free space:'
Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free
# Do not start or stop services from this script.
