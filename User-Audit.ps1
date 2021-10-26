function Audit {
    #requires -version 4.0
    #requires -RunAsAdministrator
    
    $ListUsers = Get-Content .\normalusers.txt
    $ListAdmins = Get-Content .\adminusers.txt
    $AllowedUsers = $ListUsers -split " "
    $AllowedAdmins = $ListAdmins -split " "
    $AllMachineUsers = Get-LocalUser | Format-Table -HideTableHeader -property Name
    $AllAllowedUsers = $AllowedUsers + $AllowedAdmins
    foreach ($user in $AllAllowedUsers){
        Get-LocalUser $user
        if(!($?)) {
            New-LocalUser $user
        }
    }
    foreach ($user in $AllMachineUsers){
        if(!($AllAllowedUsers.Contains($user))){
            Remove-LocalUser $user
        }
    }
    }