Cyberpatriot scripts and tools

>Import default known good group policy (GPO.inf)
1. Open Group Policy Editor
2. Go to Computer Security > Winodws Settings 
3. Right click Security Settings > Import Policy
4. Import GPO.inf

>Setup for user audit script
1. Read the CyberPatriot readme and copy the list of users
2. Copy all non-administrator users into normalusers.txt (Seperated by newlines)
3. Copy all administrator users into adminusers.txt (Seperated by newlines)
4. Run the script file as administrator