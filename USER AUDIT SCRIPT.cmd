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
IF /I %deleteuser% == NONE goto password 
net user %deleteuser% /delete
goto removeuser
:password
cls
echo SO IF /I YOU FOLLOWED THE INSTRUCTIONS YOURS USERS.TXT FILE SHOULD HAVE EACH USER IN THE SYSTEM ON A SEPERATE LINE
echo SO JUST PRESS THE BUTTON TO CHANGE ALL THEIR PASSWORDS TO TODAY'S MENU: qwerty123QWERTY123$$$
echo IT ALSO DISABLES PASSWORD NEVER EXPIRES
pause
FOR /F %%G IN (%userprofile%\desktop\normalusers.txt) DO ( net user %%G qwerty123QWERTY123$$$)
FOR /F %%G IN (%userprofile%\desktop\adminusers.txt) DO ( net user %%G qwerty123QWERTY123$$$)
FOR /F %%G IN (%userprofile%\desktop\normalusers.txt) DO ( WMIC USERACCOUNT WHERE "Name='%%G'" SET PasswordExpires=TRUE)
FOR /F %%G IN (%userprofile%\desktop\adminusers.txt) DO ( WMIC USERACCOUNT WHERE "Name='%%G'" SET PasswordExpires=TRUE)
pause
cls
echo ALRIGHT SO THIS IS THE PART OF THAT IS REASON THE WHY THERE ARE SEPERATE TEXT FILES FOR ADMINS AND REGULAR USERS
echo PRESS THE BUTTON TO REMOVE THE ADMIN GROUP FROM ALL NON ADMINS, AND ADD THE ADMIN GROUP TO ALL ADMINS
echo IF /I IT SAYS THE USER IS ALREADY IN THE GROUP OR WHATEVER IGNORE IT
pause
FOR /F %%G IN (%userprofile%\desktop\normalusers.txt) DO ( net localgroup administrators %%G /delete )
FOR /F %%G IN (%userprofile%\desktop\adminusers.txt) DO ( net localgroup administrators %%G /add )
echo CONGRATS, YOU COMPLETED THE ULTRA GAMER BASIC USER AUDITING. BY NOW IT'S 1AM SO I PROBABLY FORGOT SOME STUFF BUT BETTER THAN NOTHING HAHA
pause
cls
color c7
echo AIGHT LETS INSTALL FIREFOX
%userprofile%\desktop\firefox.exe /s /OptionalExtensions=false
pause