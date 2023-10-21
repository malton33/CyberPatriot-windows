function Find-BadFile{
    [CmdletBinding(SupportsShouldProcess)]
Param (
    [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType 'leaf'})]
        [string]$extensionpath,
    [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType 'container'})]
        [string]$searchin
    )
    #requires -RunAsAdministrator

    $ErrorActionPreference = 'Stop'
    #Import CSV of file extensions to check for
    $ListExtensions = Import-CSV $extensionpath

    foreach ($ext in $ListExtensions)
    {
        Write-Output "Checking for files ending in .$ext"
        Try
        {
            Get-ChildItem -Path $searchin\*.$ext -Recurse -Force
        }
        Catch [System.UnauthorizedAccessException]
        {
            Write-Verbose "Access denied to $searchin\*.$ext"
        }
        Catch
        {
            Write-Warning "Could not check for files in $searchin\*.$ext due to an error"
        }
    }
}