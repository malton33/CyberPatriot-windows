function Update-User{
    [CmdletBinding(SupportsShouldProcess)]
Param (
    [Parameter(Mandatory=$true)]
        [ValidateSet('all', 'user', 'admin', 'password', 'disable')]
        [string]$action,
    [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType 'leaf'})]
        [string]$allowedpath,
    [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType 'leaf'})]
        [string]$allowedadminpath
 )
    #requires -RunAsAdministrator

    $ErrorActionPreference = 'Stop'
<#
    $password = Preset password
    $ListUsers = Allowed (readme) users. Created by user and inputted as -allowedpath
    $ListAdmins = Allowed (readme) administrators. Created by user and inputted as -allowedadminpath
    $AllowedUsers = Converted list of allowed users
    $AllowedAdmins = Converted list of allowed administrators
    $MachineUsers = List of users on machine
    $AllMachineUsers = Converted list of users on machine
    $AllAllowedUsers = Combined list of allowed users and administrators
    $ExcludedUsers = Known default users that are allowed, and local user
    $ValidActions = List of valid actions that can be taken (selected via the function)
#>
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
    Write-Output "Running action $action"

        #Audit Users Action
    if ($action -eq "user" -Or $action -eq "all")
    {
        Write-Output "Creating new users"
        foreach ($user in $AllAllowedUsers)
        {
            if ($user -notin $ExcludedUsers)
            {
                Try
                {
                    Write-Verbose "Checking if $user exists"
                    Get-LocalUser $user
                    Write-Verbose "$user exists"
                }
                Catch [Microsoft.PowerShell.Commands.UserNotFoundException]
                {
                    Write-Verbose "$user does not exist"
                    if ($PSCmdlet.ShouldProcess($user,'Create user'))
                    {
                        New-LocalUser -Name $user -Password $password -Description "Created by $env:username"
                        Add-LocalGroupMember -Group "Users" -Member $user
                        Write-Output "Created user $user"
                    }
                }
                Catch
                {
                    Write-Error "An unexpected error occured while adding or checking status of user $user"
                    exit
                }
            }
            elseif ($user -in $ExcludedUsers)
            {
                Write-Verbose "Skipping creation for excluded user $user"
            }
            else
            {
                Write-Warning "Skipping creation for user $user because an error occured"
            }
        }
        Write-Output "Created new users"
        Write-Output "Removing disallowed users"
        foreach ($user in $AllMachineUsers)
        {
            if ($user -notin $ExcludedUsers)
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
                Catch #EXCEPTION
                {
                    Write-Verbose "$user already exists or is invalid"
                }
                Catch
                {
                    Write-Error "An unexpected error occurred while removing user $user"
                    exit
                }
            }
            elseif ($user -in $ExcludedUsers)
            {
                Write-Verbose "Skipping removal for excluded user $user"
            }
            else
            {
                Write-Warning "Skipping removal for user $user because an error occurred"
            }
        }
        $MachineUsers = get-ciminstance Win32_UserAccount -filter 'LocalAccount=TRUE' | select-object -expandproperty Name
        $AllMachineUsers = $MachineUsers -join " " -split " " | Where-Object {$_}
        Write-Output "Removed disallowed users"
    }
        #Audit Admins Action
	if ($action -eq "admin" -or $action -eq "all")
	{
		foreach ($user in $AllMachineUsers)
		{
            if ($user -notin $ExcludedUsers) {
                Write-Verbose "Checking if $user is admin"
                if ($user -in $AllowedAdmins)
                {
                    Try
                    {
                        if ($PSCmdlet.ShouldProcess($user,'Add user to admin group'))
                        {
                            Add-LocalGroupMember -Group "Administrators" -Member $user
                            Write-Output "Added $user to Administrators"
                        }
                    }
                    Catch #EXCEPTION
                    {
                        Write-Verbose "$user is already an admin"
                    }
                    Catch
                    {
                        Write-Error "An unexpected error occurred while adding user $user to the Administrators group"
                        exit
                    }
                }
                elseif ($user -notin $AllowedAdmins)
                {
                    Try
                    {
                        if ($PSCmdlet.ShouldProcess($user,'Remove user from admin group'))
                        {
                            Remove-LocalGroupMember -Group "Administrators" -Member $user
                            Write-Output "Removed $user from Administrators"
                        }
                    }
                    Catch #EXCEPTION
                    {
                        Write-Verbose "$user is not an admin or is excluded"
                    }
                    Catch
                    {
                        Write-Error "An unexpected error occurred while removing user $user from the Administrators group"
                        exit
                    }
                }
                else
                {
                    Write-Verbose "Skipping admin for user $user because an error occured"
                }
            }
            elseif ($user -in $ExcludedUsers)
            {
                Write-Verbose "Skipping admin for excluded user $user"
            }
            else
            {
                Write-Warning "Skipping admin for user $user because an error occurred"
            }
		}
        Write-Output "Set admin permissions"
	}
    if ($action -eq "disable" -or $action -eq "all")
    {
        #Disable Guest and Administrator accounts
        Write-Output "Disabling Guest and Administrator accounts"
            if ($PSCmdlet.ShouldProcess('Administrator','Disable Administrator'))
            {
                Disable-LocalUser -Name Administrator
                Write-Output "Disabled Administrator account"
            }
            if ($PSCmdlet.ShouldProcess('Guest','Disable Guest'))
            {
                Disable-LocalUser -Name Guest
                Write-Output "Disabled Guest account"
            }
        Write-Output "Disabled Guest and Administrator accounts"
    }
    #Set Password Action
	if ($action -eq "password" -or $action -eq "all")
    {
        Write-Output "Setting user passwords"

        $MachineUsers = get-ciminstance Win32_UserAccount -filter 'LocalAccount=TRUE' | select-object -expandproperty Name
        $AllMachineUsers = $MachineUsers -join " " -split " " | Where-Object {$_}

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
                Catch #EXCEPTION
                {
                    Write-Verbose "$user is invalid, skipping password..."
                }
                Catch
                {
                    Write-Error "An unexpected error occurred while setting password of user $user"
                    exit
                }
            }
            elseif ($user -in $ExcludedUsers)
            {
                Write-Verbose "Skipping password for excluded user $user"
            }
            else
            {
                Write-Warning "Skipping password for user $user because an error occurred"
            }
        }
        Write-Output "Set user passwords"
	}

}