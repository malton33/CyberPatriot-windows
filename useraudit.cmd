cls
@echo off
echo User Auditing Script
echo Warning: Incorrect input may cause the program to crash
echo Import the GPO.inf file before running this script (instructions in readme.txt)
echo Message/error spam is normal when running automated actions
pause
:main
cls
echo Choose a section:
echo.
echo 1. Options, groups, and removal of users
echo 2. Add users, change passwords, administrators
echo 3. All
echo.
set /p script="Selection: "
IF /I %script% == 1 call :1 ELSE goto main
IF /I %script% == 2 call :2 ELSE goto main


:1
cls
net accounts
echo Ensure that all the above options are set properly, and then continue
pause
cls
net localgroup
echo Ensure thet all the above groups are valid and allowed
echo For a list of ensured valid groups, view groups.txt
pause
cls
net users
echo Double-check the list of approved users in the Cyberpatriot readme with the users above
echo Remove any disallowed users, and then enter NONE when complete
:removeuser
set /p deleteuser="Delete the following user: "
IF /I %deleteuser% == NONE goto :1e
net user %deleteuser% /delete
goto removeuser
:1e
IF /I %script% == 1 call :main


:2
cls
echo The next step will add all users from the text file, which should be copied directly from Cyberpatriot
pause
FOR /F %%G IN (%~dp0\normalusers.txt) DO ( net user %%G /add)
FOR /F %%G IN (%~dp0\adminusers.txt) DO ( net user %%G /add)
pause
cls
echo The next step will change all passwords into qwerty123QWERTY123$$$ and enable password expiring
pause
FOR /F %%G IN (%~dp0\normalusers.txt) DO ( net user %%G qwerty123QWERTY123$$$)
FOR /F %%G IN (%~dp0\adminusers.txt) DO ( net user %%G qwerty123QWERTY123$$$)
FOR /F %%G IN (%~dp0\normalusers.txt) DO ( WMIC USERACCOUNT WHERE "Name='%%G'" SET PasswordExpires=TRUE)
FOR /F %%G IN (%~dp0\adminusers.txt) DO ( WMIC USERACCOUNT WHERE "Name='%%G'" SET PasswordExpires=TRUE)
pause
cls
echo The next step will ensure all users are administrators or not, based on the text file 
pause
FOR /F %%G IN (%~dp0\normalusers.txt) DO ( net localgroup administrators %%G /delete )
FOR /F %%G IN (%~dp0\adminusers.txt) DO ( net localgroup administrators %%G /add )
echo Basic user auditing and user group policy is complete
pause
call START.cmd