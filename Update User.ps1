function Update-User{
    [CmdletBinding(SupportsShouldProcess)]
Param (
    [Parameter(Mandatory=$true)]
        [string]$action,
    [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType 'leaf'})]
        [string]$allowedpath,
    [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType 'leaf'})]
        [string]$allowedadminpath
 )
    #requires -version 4.0
    #requires -RunAsAdministrator

    $ErrorActionPreference = 'Stop'

    # $password = Preset password
    # $ListUsers = Allowed (readme) users
    # $ListAdmins = Allowed (readme) administrators
    # $AllowedUsers = Converted list of allowed users
    # $AllowedAdmins = Converted list of allowed administrators
    # $MachineUsers = List of users on machine
    # $AllMachineUsers = Converted list of users on machine   <-- Change name TBD?
    # $AllAllowedUsers = Combined list of allowed users and administrators
    # $ExcludedUsers = Known default users that are allowed
    # $ValidActions = List of valid actions that can be taken (selected via the function)

    # need a better way to do this but not sure and it doesn't really matter does it?
	$password = ConvertTo-SecureString "qwerty123QWERTY123!!!" -AsPlainText -Force

	$ListUsers = Get-Content $allowedpath
    $ListAdmins = Get-Content $allowedadminpath

    $AllowedUsers = $ListUsers -split " "
    Write-Verbose "Specified allowed users: $AllowedUsers"

    $AllowedAdmins = $ListAdmins -split " "
    Write-Verbose "Specified allowed admins: $AllowedAdmins"

   # I stole this but it works and idk why
    $MachineUsers = get-ciminstance Win32_UserAccount -filter 'LocalAccount=TRUE' | select-object -expandproperty Name
    $AllMachineUsers = $MachineUsers -join " " -split " " | Where-Object {$_}
    Write-Verbose "All users on machine: $AllMachineUsers"

    $AllAllowedUsers = $AllowedUsers + $AllowedAdmins
    Write-Verbose "All allowed users: $AllAllowedUsers"

    $ExcludedUsers = @('Administrator', 'DefaultAccount', 'Guest', 'WDAGUtilityAccount', $env:username)
    Write-Verbose "All excluded users: $ExcludedUsers"

    $ValidActions = @('all', 'user', 'admin', 'password')
    Write-Output "Running action $action"
    if ($ValidActions -notcontains $action) { Write-Warning "Invalid action specified." }

        #Audit Users Action
    if ($action -eq "user" -Or $action -eq "all")
    {
        Write-Output "Creating new users"
        foreach ($user in $AllAllowedUsers)
        {
            Try
            {
                if ($ExcludedUsers -notcontains $user)
                {
                    Write-Verbose "Checking if $user exists"
                    Get-LocalUser $user
                    Write-Verbose "$user exists"
                }
            }
            Catch
            {
                if ($PSCmdlet.ShouldProcess($user,'Create user'))
                {
                    Write-Verbose "$user does not exist"
                    New-LocalUser -Name $user -Password $password -Description "Created by $env:username"
                    Add-LocalGroupMember -Group "Users" -Member $user
                    Write-Output "Created user $user"
                }
            }

        }
        Write-Output "Created new users"
        Write-Output "Removing disallowed users"
        foreach ($user in $AllMachineUsers)
        {
            if ($ExcludedUsers -notcontains $user)
            {
                Try
                {
                    if ($PSCmdlet.ShouldProcess($user,'Remove user'))
                    {
                        # if user is not in all allowed users
                        if ($AllAllowedUsers -notcontains $user)
                        {
                            Remove-LocalUser -Name $user
                            Write-Output "Removed user $user"
                        }
                    }
                }
                Catch
                {
                    Write-Verbose "$user already exists or is invalid"
                }
            }
            else
            {
                Write-Verbose "User $user is manually excluded"
            }
        }
        Write-Output "Removed disallowed users"
    }

        #Set Password Action
	if ($action -eq "password" -or $action -eq "all")
    {
        foreach ($user in $AllMachineUsers)
        {
            if ($user -notin $ExcludedUsers) {
                Try
                {
                    if ($PSCmdlet.ShouldProcess($user,'Set password'))
                    {
                        Set-LocalUser -Name $user -Password $password -PasswordNeverExpires 0
                        Write-Output "Set password for $user"
                    }
                }
                Catch
                {
                    Write-Verbose "$user is invalid, skipping password..."
                }
            }

        }
        Write-Output "Set user passwords"
	}
        #Audit Admins Action
	if ($action -eq "admin" -or $action -eq "all")
	{
		foreach ($user in $AllMachineUsers)
		{
			#Write-Verbose "Checking if $user is admin"
			if ($user -in $AllowedAdmins -and $user -notin $ExcludedUsers)
			{
				Try
				{
                    if ($PSCmdlet.ShouldProcess($user,'Add user to admin group'))
                    {
                        Add-LocalGroupMember -Group "Administrators" -Member $user
                        Write-Output "Added $user to Administrators"
                    }
				}
				Catch
				{
					Write-Verbose "$user is already an admin"
				}
			}
			else
			{
				Try
				{
                    if ($PSCmdlet.ShouldProcess($user,'Remove user from admin group'))
                    {
                        Remove-LocalGroupMember -Group "Administrators" -Member $user
                        Write-Output "Removed $user from Administrators"
                    }
				}
				Catch
				{
					Write-Verbose "$user is not an admin or is excluded"
				}
			}
		}
        Write-Output "Set admin permissions"
	}


}