@echo off
echo Copying module files to %userprofile%\Documents\WindowsPowershell\Modules
pause
xcopy /i .\Update-User\ %USERPROFILE%\Documents\WindowsPowershell\Modules
