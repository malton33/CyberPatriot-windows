@echo off
echo Select the script to run:
echo.
echo 1. User Auditing
echo.
set /p script="Select script: "
IF /I %script% == 1 call useraudit.cmd
