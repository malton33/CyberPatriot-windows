@echo off
echo Copying module files 
xcopy /i .\Update-User %USERPROFILE%\Documents\WindowsPowershell\Modules\Update-User
xcopy /i .\Find-BadFile %USERPROFILE%\Documents\WindowsPowershell\Modules\Find-BadFile
pause
