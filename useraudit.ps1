#requires -version 4.0
#requires -RunAsAdministrator
$rawusers = Get-Content .\normalusers.txt
$rawadmins = Get-Content .\adminusers.txt
$normalusers = $rawusers -split " "
$adminusers = $rawadmins -split " "
$allusers = $normalusers + $adminusers
foreach ($user in $allusers){
    Write-Host $user
}