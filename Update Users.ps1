function Update-Users([string]$action) {
    #requires -version 4.0
    #requires -RunAsAdministrator
    #todo fix this so it does not pull from current directory
	$ListUsers = Get-Content .\normalusers.txt
    Write-Debug "List users: $listusers"
    $ListAdmins = Get-Content .\adminusers.txt
    Write-Debug "List admins: $ListAdmins"
    $AllowedUsers = $ListUsers -split " "
    Write-Debug "Allowed users: $AllowedUsers"
    $AllowedAdmins = $ListAdmins -split " "
    Write-Debug "Allowed admins: $AllowedAdmins"
    $AllMachineUsers = Get-LocalUser | Format-Table -HideTableHeader -property Name
    $AllAllowedUsers = $AllowedUsers + $AllowedAdmins

    Write-Verbose "Running action $action"
    if ($action -eq "user" -Or $action -eq "all")
    {
        foreach ($user in $AllAllowedUsers)
        {
            Get-LocalUser $user
            # if command does not succeed
            if(!($?)) 
            {
                Write-Verbose "Creating user $user"
                New-LocalUser $user
                Write-Verbose "Created user $user"
            }
        }
        foreach ($user in $AllMachineUsers)
        {
            # if user is not in all allowed users
            if(!($AllAllowedUsers.Contains($user)))
            {
                Write-Verbose "Removing user $user"
                Remove-LocalUser $user
                Write-Verbose "Removed user $user"
            }
        }
    
    }
	
	if ($action -eq "password" -or $action -eq "all")
	{
		# need a better way to do this but not sure and it doesn't really matter does it?
		$password = ConvertTo-SecureString "qwerty123QWERTY123$$$" -AsPlainText -Force
		foreach ($user in $AllMachineUsers)
		{
			Write-Verbose "Setting password for $user"
			Set-LocalUser -Name "$user" -Password $password -PasswordNeverExpires false
			Write-Verbose "Set password for $user"
		}
	}
	
	if ($action -eq "admin" -or $action -eq "all")
	{
		foreach ($user in $AllMachineUsers)
		{
			Write-Verbose "Checking if $user is admin"
			if ($user -in $AllowedAdmins)
			{
				#todo
			}
		}
		
    }
}