function Initialize-MachineUser {
    $MachineUsers = get-ciminstance Win32_UserAccount -filter 'LocalAccount=TRUE' | select-object -expandproperty Name
    $AllMachineUsers = $MachineUsers -join " " -split " " | Where-Object {$_}
    Write-Verbose "All users on machine: $AllMachineUsers"
}