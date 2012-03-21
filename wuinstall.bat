@echo off

REM - WuInstall Continuous Updates Until Completion
REM - 
REM - Copyright 2012 Dusty Wilson <myfirstname at linux.com>
REM - License GPLv3
REM - 
REM - This script combined with WuInstall Freeware (wuinstall.com)
REM - will allow you to perform an automated install of all Windows
REM - Updates available.  I recommend that you tie this in with a
REM - WSUS server so you can choose the updates you want to have
REM - installed.  You will run this script from a separate computer;
REM - from the WSUS server, for example.  If you run it on the
REM - computer to receive the updates, it will not be continuous
REM - since it must reboot frequently and the script will obviously
REM - stop running each reboot.
REM - 
REM - Please report bugs and patches are welcomed.  This has ONLY
REM - been tested in a domain environment with WSUS on the LAN.

if "%1." == "." goto fail

\\domainname\path\blah\pstools\psexec \\%1 -c -v -s -u domainname\username -p password \\domainname\path\blah\wuinstall\wuinstall.exe /install

REM 53= psexec unable to connect (probably still rebooting)
if errorlevel 53 goto rerun

REM 12= timeout occurred
if errorlevel 12 goto end

REM 11= reboot; errors occurred during update
if errorlevel 11 goto rebootandrerun

REM 10= reboot; no errors occurred during update
if errorlevel 10 goto rebootandrerun

REM 8= wuinstall is expired
if errorlevel 8 goto end

REM 7= syntax error
if errorlevel 7 goto end

REM 6= reboot wanted but failed
if errorlevel 6 goto rebootandcontinue

REM 5= reboot started
if errorlevel 5 goto rerunwithdelay

REM 4= invalid criteria
if errorlevel 4 goto end

REM 3= criteria didn't match anything
if errorlevel 3 goto end

REM 2= no updates available
if errorlevel 2 goto end

REM 1= updates installed; errors occurred during update
if errorlevel 1 goto rerun

REM 0= updates install; no errors occurred during update
if errorlevel 0 goto rerun

goto end

:rebootandrerun
shutdown /m \\%1 /r /t 1
goto rerunwithdelay

:rerunwithdelay
echo Delaying for 2 minutes...
ping 1.1.1.1 -n 1 -w 120000 >nul
goto rerun

:rerun
call %0 %*
goto end

:fail
echo Needs hostname as first argument.

:end
