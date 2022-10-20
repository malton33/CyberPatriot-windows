function Initialize-MachineUser {
    $MachineUsers = get-ciminstance Win32_UserAccount -filter 'LocalAccount=TRUE' | select-object -expandproperty Name
    $AllMachineUsers = $MachineUsers -join " " -split " " | Where-Object {$_}
}