#requires -version 4.0
#requires -RunAsAdministrator
$normalusers = Get-Content .\normalusers.txt
$adminusers = Get-Content .\adminusers.txt
foreach ($user in $normalusers){
    Write-Host $user
}