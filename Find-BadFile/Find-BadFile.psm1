function Find-BadFile{
    [CmdletBinding(SupportsShouldProcess)]
Param (
    [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType 'leaf'})]
        [string]$extensionpath
 )
    #requires -RunAsAdministrator

    $ErrorActionPreference = 'Stop'
    #Import CSV of file extensions to check for
    $ListExtensions = Import-CSV $extensionpath
}