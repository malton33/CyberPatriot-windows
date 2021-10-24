#requires -version 4.0
#requires -RunAsAdministrator
$rawusers = Get-Content .\normalusers.txt
$rawadmins = Get-Content .\adminusers.txt
$normalusers = $rawusers -split " "
$adminusers = $rawadmins -split " "
foreach ($user in $normalusers){
    Write-Host $user
}
foreach ($user in $adminusers){
    Write-Host $user
}