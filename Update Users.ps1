function Update-Users{
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
 
    [CmdletBinding()]
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
	$password = ConvertTo-SecureString "qwerty123QWERTY123$$$" -AsPlainText -Force

    #  possibly convert to full function? within function?

    # THESE TEXT FILES MUST BE MANUALLY CREATED FROM THE LISTS GIVEN IN THE README
	$ListUsers = Get-Content .\normalusers.txt
    $ListAdmins = Get-Content .\adminusers.txt

    $AllowedUsers = $ListUsers -split " "
    Write-Verbose "Specified allowed users: $AllowedUsers"

    $AllowedAdmins = $ListAdmins -split " "
    Write-Verbose "Specified allowed admins: $AllowedAdmins"

   # $MachineUsers = Get-LocalUser | Format-Table -HideTableHeader -property Name | Out-String
   # $MachineUsers = Get-LocalUser | Select-Object Name | Out-String 
   # I stole this but it works and idk why
    $MachineUsers = get-wmiobject Win32_UserAccount -filter 'LocalAccount=TRUE' | select-object -expandproperty Name
    $AllMachineUsers = $MachineUsers -join " " -split " " | Where-Object {$_} 
    Write-Verbose "All users on machine: $AllMachineUsers"

    $AllAllowedUsers = $AllowedUsers + $AllowedAdmins
   # $AllAllowedUsers = $ListAllAllowedUsers -split " "
    Write-Verbose "All allowed users: $AllAllowedUsers"

    $ExcludedUsers = @('Administrator', 'DefaultAccount', 'Guest', 'WDAGUtilityAccount')

    $ValidActions = @('all', 'user', 'admin', 'password')
    Write-Host "Running action $action" -BackgroundColor Black
    if ($ValidActions -notcontains $action) { Write-Warning "Invalid action specified." }

        #Audit Users Action
    if ($action -eq "user" -Or $action -eq "all")
    {
        Write-Host "Creating new users"
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
                New-LocalUser $user -Password $password
                Add-LocalGroupMember -Group "Users" -Member $user
                Write-Verbose "Created user $user"
            }

        }
        Write-Host "Created new users"
        Write-Host "Removing disallowed users"
        foreach ($user in $AllMachineUsers)
        {
            if ($ExcludedUsers -notcontains $user)
            {
                Try
                {
                    # if user is not in all allowed users
                    if($AllAllowedUsers -notcontains $user)
                    {
                        Remove-LocalUser $user
                        Write-Verbose "Removed user $user"
                    }
                }
                Catch 
                {
                    Write-Verbose "$user already exists or is invalid"
                }
            }
            else
            {
                Write-Warning "User $user is manually excluded"
            }
        }
        Write-Host "Removed disallowed users"
    }

        #Set Password Action
	if ($action -eq "password" -or $action -eq "all") 
    {
        foreach ($user in $AllMachineUsers)
        {
            Try
            {
                Set-LocalUser -Name "$user" -Password $password -PasswordNeverExpires false
                Write-Verbose "Set password for $user"
            }    
            Catch 
            {
                Write-Verbose "$user is invalid, skipping password..."
            }
        }
        Write-Host "Set user passwords"    
	}
        #Audit Admins Action
	if ($action -eq "admin" -or $action -eq "all")
	{
		foreach ($user in $AllMachineUsers)
		{
			#Write-Verbose "Checking if $user is admin"
			if ($user -in $AllowedAdmins)
			{
				#todo
			}
		}
		
    }
}