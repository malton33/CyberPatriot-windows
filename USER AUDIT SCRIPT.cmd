@echo off
echo 1. Make sure the script was run as admnistrator
echo 2. Incorrect input may cause the program to crash
echo 3. Import the GPO.inf file before running this script (instructions in readme.txt)
pause
cls
:main
@echo off
color 07
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
IF /I %deleteuser% == NONE goto adduser
net user %deleteuser% /delete
goto removeuser
:adduser
cls
echo The next step will add all users from the text file, which should be copied directly from Cyberpatriot
echo Seeing message spam is normal at this stage, errors are normal due to the way the script works
pause
FOR /F %%G IN (%userprofile%\desktop\normalusers.txt) DO ( net user %%G /add)
FOR /F %%G IN (%userprofile%\desktop\adminusers.txt) DO ( net user %%G /add)
pause
cls
:password
cls
echo The next step will change all passwords into qwerty123QWERTY123$$$ and enable password expiring
pause
FOR /F %%G IN (%~dpnx0) DO ( net user %%G qwerty123QWERTY123$$$)
FOR /F %%G IN (%~dpnx0) DO ( net user %%G qwerty123QWERTY123$$$)
FOR /F %%G IN (%~dpnx0) DO ( WMIC USERACCOUNT WHERE "Name='%%G'" SET PasswordExpires=TRUE)
FOR /F %%G IN (%~dpnx0) DO ( WMIC USERACCOUNT WHERE "Name='%%G'" SET PasswordExpires=TRUE)
pause
cls
echo The next step will ensure all users are administrators or not, based on the text file 
pause
FOR /F %%G IN (%~dpnx0) DO ( net localgroup administrators %%G /delete )
FOR /F %%G IN (%~dpnx0) DO ( net localgroup administrators %%G /add )
echo Basic user auditing and user group policy is complete
pause