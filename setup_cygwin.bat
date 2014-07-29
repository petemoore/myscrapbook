@echo off

:: This .bat script will install cygwin on a remote machine, and set
:: up an sshd daemon as a Windows service, and then connect to it and
:: run an initial setup script (setup.sh).
::
:: You should run this script *NOT* from the target machine, but from
:: a central machine, and in this way you can set up several machines
:: at the same time by calling this script multiple times with
:: different parameters for each machine. The machine you run this
:: from probably has to be a Windows 2003 Server, due to the fact it
:: uses ntrights.exe utility (but this is currently not known).
::
:: You can call it from a Windows command shell (cmd) like this:
::
::     setup_cygwin.bat server0123 user123 domainX passwordY
::
:: You can call it from another .bat script like this:
::
::     call setup_cygwin.bat server0123 user123 domainX passwordY
::
:: It is not designed to be called from cygwin (not tested).
::
:: These examples would install cygwin on server server0123 under
:: Windows domain account domainX\user123 with password passwordY.

:: Prerequisites:
::
::     1) This script runs on a Windows 2003 Server (target server can
::        be any Windows version - although only Windows 2003 tested).
::     2) The remote server has a D: drive.
::     3) It may be necessary that the local user that runs this
::        script is an admin on the remote server, or may even need to
::        be the same as the user that runs the remote sshd daemon
::        (never tested non-admins or different users to target env).
::     4) It may be necessary to run the script directly from the
::        directory/folder that contains the script (not tested
::        running script from a different folder).

:: This script should be able to be rerun on an existing installation
:: without causing any problems - so if an installation fails, it can
:: be rerun without negative consequences.

set SERVER=%1%
set USERNAME=%2%
set DOMAIN=%3%
set PASSWORD=%4%

net use \\%SERVER%\C$ %PASSWORD% /USER:%DOMAIN%\%USERNAME%
xcopy cygwin \\%SERVER%\C$\cygwin_install /E /V /I /F /H /Y
PsTools\PsExec \\%SERVER%\ -u %DOMAIN%\%USERNAME% -p %PASSWORD% -n 10 -w C:\cygwin_install C:\cygwin_install\setup.exe -L C:\cygwin_install\release -P openssh -q
.\ntrights.exe -u %DOMAIN%\%USERNAME% -m \\%SERVER% +r SeServiceLogonRight
PsTools\PsExec \\%SERVER%\ -u %DOMAIN%\%USERNAME% -p %PASSWORD% -n 10 C:\cygwin\bin\bash.exe --login -c "cygrunsrv -R sshd 2>/dev/null"
PsTools\PsExec \\%SERVER%\ -u %DOMAIN%\%USERNAME% -p %PASSWORD% -n 10 C:\cygwin\bin\bash.exe --login -c "ssh-host-config -u %USERNAME% -y -c 'ntsec mintty' -w '%PASSWORD%'"
::powershell.exe .\set_password.ps1 "%SERVER%" "sshd" "%DOMAIN%" "%USERNAME%" "%PASSWORD%" "%PASSWORD%.pass"
::PsTools\PsExec \\%SERVER%\ -u %DOMAIN%\%USERNAME% -p %PASSWORD% -n 10 C:\cygwin\bin\bash.exe --login -c "cygrunsrv -S sshd"
PsTools\PsExec \\%SERVER%\ -u %DOMAIN%\%USERNAME% -p %PASSWORD% -n 10 net start sshd
PsTools\PsExec \\%SERVER%\ -u %DOMAIN%\%USERNAME% -p %PASSWORD% -n 10 C:\cygwin\bin\bash.exe --login -c "cat /etc/passwd | sed 's/^\(%USERNAME%:.*\):[^:]*:\([^:]*\)$/\1:\/home\/%USERNAME%:\2/' > /home/%USERNAME%/newpasswd"
PsTools\PsExec \\%SERVER%\ -u %DOMAIN%\%USERNAME% -p %PASSWORD% -n 10 C:\cygwin\bin\bash.exe -c "/usr/bin/cp /home/%USERNAME%/newpasswd /etc/passwd"
PsTools\PsExec \\%SERVER%\ -u %DOMAIN%\%USERNAME% -p %PASSWORD% -n 10 C:\cygwin\bin\bash.exe --login -c "mkdir -p /home/%USERNAME%/.ssh"
xcopy .\all_authorized_keys \\%SERVER%\C$\cygwin\home\%USERNAME%\ /V /F /Y
PsTools\PsExec \\%SERVER%\ -u %DOMAIN%\%USERNAME% -p %PASSWORD% -n 10 C:\cygwin\bin\bash.exe --login -c "cat /home/%USERNAME%/all_authorized_keys > /home/%USERNAME%/.ssh/authorized_keys; chmod 600 /home/%USERNAME%/.ssh/authorized_keys; rm /home/%USERNAME%/all_authorized_keys"
C:\cygwin\bin\bash.exe --login -c "ssh -oStrictHostKeyChecking=no %USERNAME%@%SERVER% 'rm newpasswd'"
C:\cygwin\bin\bash.exe --login -c "scp git/tibco_config/setup.sh %USERNAME%@%SERVER%:."
C:\cygwin\bin\bash.exe --login -c "ssh %USERNAME%@%SERVER% 'chmod u+x setup.sh;./setup.sh'"
