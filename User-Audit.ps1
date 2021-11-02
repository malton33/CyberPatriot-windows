function Audit-User([string]$action) {
    #requires -version 4.0
    #requires -RunAsAdministrator
    Write-Verbose "Running action " + $action
    if ($action = "users") -or ($action = "all") 
    {
        $ListUsers = Get-Content .\normalusers.txt
        $ListAdmins = Get-Content .\adminusers.txt
        $AllowedUsers = $ListUsers -split " "
        $AllowedAdmins = $ListAdmins -split " "
        $AllMachineUsers = Get-LocalUser | Format-Table -HideTableHeader -property Name
        $AllAllowedUsers = $AllowedUsers + $AllowedAdmins
        foreach ($user in $AllAllowedUsers)
        {
            Get-LocalUser $user
            # if command does not succeed
            if(!($?)) 
            {
                Write-Verbose "Creating user " + $user
                New-LocalUser $user
                Write-Verbose "Created user " + $user
            }
        }
        foreach ($user in $AllMachineUsers)
        {
            #if user is not in all allowed users
            if(!($AllAllowedUsers.Contains($user)))
            {
                Write-Verbose "Removing user " + $user
                Remove-LocalUser $user
                Write-Verbose "Removed user " + $user
            }
        }
    
    }
    
}