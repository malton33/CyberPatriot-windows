function Update-Users([Parameter(Mandatory=$true)][string]$action) {
    [CmdletBinding()]
    #requires -version 4.0
    #requires -RunAsAdministrator
    # need a better way to do this but not sure and it doesn't really matter does it?
	$password = ConvertTo-SecureString "qwerty123QWERTY123$$$" -AsPlainText -Force

	$ListUsers = Get-Content .\normalusers.txt
    $ListAdmins = Get-Content .\adminusers.txt

    $AllowedUsers = $ListUsers -split " "
    Write-Debug "Allowed users: $AllowedUsers"

    $AllowedAdmins = $ListAdmins -split " "
    Write-Debug "Allowed admins: $AllowedAdmins"

    $MachineUsers = Get-LocalUser | Format-Table -HideTableHeader -property Name | Out-String
    $AllMachineUsers = $MachineUsers -split " " | Where-Object {$_}
    Write-Debug "All users on machine: $AllMachineUsers"

    $AllAllowedUsers = $AllowedUsers + $AllowedAdmins

    $ExcludedUsers = @('Administrator', 'DefaultAccount', 'Guest', 'WDAGUtilityAccount')

    $ValidActions = @('all', 'user', 'admin', 'password')
    Write-Verbose "Running action $action"
    if ($ValidActions -notcontains $action) { Write-Warning "Invalid action specified" }

    if ($action -eq "user" -Or $action -eq "all")
    {
        foreach ($user in $AllAllowedUsers)
        {
            Get-LocalUser $user
            # if command does not succeed
            if(!($?)) 
            {
                Write-Verbose "Creating user $user"
                New-LocalUser $user -Password $password
                Write-Verbose "Created user $user"
            }
        }
        foreach ($user in $AllMachineUsers)
        {
            # if user is not in all allowed users
            if($AllAllowedUsers -notcontains $user)
            {
                Write-Verbose "Removing user $user"
                Remove-LocalUser $user
                Write-Verbose "Removed user $user"
            }
        }
    
    }
	
	if ($action -eq "password" -or $action -eq "all")
	{
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