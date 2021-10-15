@echo off
::------------------------------------------------------------------------------
:: NAME
::     Discord_Invite_Links_Checker.bat - Discord Invite Links Checker
::
:: DESCRIPTION
::     Crawl a database of Discord invite links
::     and result their statut as valid or invalid.
::
:: AUTHOR
::     IB_U_Z_Z_A_R_Dl
::
:: CREDITS
::     @Grub4K - Creator of the logging name algorithm.
::     @Grub4K - Creator of the timer algorithm.
::     @Grub4K - Creator of the padding CLI algorithm.
::     @Grub4K - Helped reducing variables plural algorithm.
::     @Grub4K - Helped reducing Curl PATH algorithm.
::     @Grub4K - Helped designing the CLI.
::     @blacktario - Original project idea.
::     @blacktario - Proxy checker idea.
::     @sintrode - Helped creating the database parsing algorithm.
::     @Sintrode - Helped me encoding the CLI.
::     A project created in the "server.bat" Discord: https://discord.gg/GSVrHag
::------------------------------------------------------------------------------
cls
>nul chcp 65001
setlocal DisableDelayedExpansion
cd /d "%~dp0"
set "@TITLE=title Progress: [!Invite_Percentage!/100%%] - [!Invite_CN!/!Invite_CN_MAX!]  ^|  Result!s_Results!: [!Results_Valid!-!Results_Invalid!]  ^|  Proxy: [!Proxy!] - [!Proxy_CN!/!Proxy_CN_MAX!] - !TITLE!"
set "@SET_S=if !?! gtr 1 (set s_?=s) else (set s_?=)"
setlocal EnableDelayedExpansion
set TITLE=Discord Invite Links Checker
title !TITLE!
if defined TEMP (set "TMPF=!TEMP!") else if defined TMP (set "TMPF=!TMP!") else (
    call :MSGBOX 2 "Your 'TEMP' and 'TMP' environment variables do not exist." "Please fix one of them and try again." 69648 "!TITLE!"
    exit
)
if defined ProgramFiles(x86) (
    set "PATH=!PATH!;Curl\x64"
) else (
    set "PATH=!PATH!;Curl\x32"
)
>nul 2>&1 where curl.exe || call :ERROR_FATAL !PATH:~-8!\curl.exe
for /f "tokens=4,5delims=. " %%A in ('ver') do (
    if "%%A.%%B"=="10.0" (
        for %%A in (UNDERLINE`4 UNDERLINEOFF`24 RED`31 GREEN`32 YELLOW`33 CYAN`36 BRIGHTBLACK`90 BRIGHTBLUE`94 BRIGHTMAGENTA`95 BRIGHTWHITE`97) do (
            for /f "tokens=1,2delims=`" %%B in ("%%A") do (
                set %%B=[%%Cm
            )
        )
        set BS=
    ) else (
        set BS=
    )
)
for /f "tokens=2delims==." %%A in ('wmic os get LocalDateTime /value') do (
    set "DateTime=%%A"
    set "DateTime=!DateTime:~0,-10!-!DateTime:~-10,2!-!DateTime:~-8,2!_!DateTime:~-6,2!-!DateTime:~-4,2!-!DateTime:~-2!"
)
set "@LOGGING=(if not exist Logs md Logs) & >>Logs\LOGS_%~n0_!DateTime!.txt"
set DateTime=
:MAIN
cls
title !TITLE!
echo.
echo    !BRIGHTWHITE![?]!CYAN! This tool does NOT work with links that do not redirect to: {https://discord.com/invite/[INVITE_CODE]}
echo.
echo    !BRIGHTWHITE![?]!CYAN! Your databases must be in one of the following format:
echo  !CYAN!LINK !CYAN!=!YELLOW! https://example.com/database.txt
echo  !CYAN!LINK !CYAN!=!YELLOW! http://example.com/database.txt
echo  !CYAN!LINK !CYAN!=!YELLOW! example.com/database.txt
echo  !CYAN!FILE PATH !CYAN!=!YELLOW! "C:\Users\example\Downloads\Discord Invite Links Checker\database.txt"
echo  !CYAN!FILE PATH !CYAN!=!YELLOW! database.txt
echo.
echo    !BRIGHTWHITE![?]!CYAN! In your databases, the content must be line by line in exactly the following formats:
echo  !UNDERLINE!proxy database!UNDERLINEOFF! = {[IP]:[PORT]}
echo  !UNDERLINE!invite links database!UNDERLINEOFF! = Any links redirecting to: {https://discord.com/invite/[INVITE_CODE]}
echo.
echo    !BRIGHTWHITE![?]!CYAN! (02/10/2021) Those are recommended !UNDERLINE!proxy database!UNDERLINEOFF!:
echo  !YELLOW!https://api.proxyscrape.com/v2/?request=displayproxies^&protocol=http^&timeout=10000^&country=all^&ssl=all^&anonymity=all
echo  !YELLOW!https://api.proxyscrape.com/?request=displayproxies^&proxytype=http^&timeout=1500^&ssl=yes
echo  !YELLOW!https://www.proxyscan.io/api/proxy?format=txt^&type=https
echo  !YELLOW!https://www.proxy-list.download/api/v1/get?type=http
echo.
echo.
echo    !CYAN!Enter your !UNDERLINE!proxy database!UNDERLINEOFF! !CYAN!LINK!CYAN! (or) !CYAN!FILE PATH!CYAN! / Drag and Drop it below...
set Proxy_DB=
set /p "Proxy_DB=!BS!!CYAN! > !YELLOW!"
call :DB_CHECKER Proxy_DB proxy || goto :MAIN
echo.
echo    !CYAN!Enter your Discord !UNDERLINE!invite links database!UNDERLINEOFF! !CYAN!LINK!CYAN! (or) !CYAN!FILE PATH!CYAN! / Drag and Drop it below...
set Invites_DB=
set /p "Invites_DB=!BS!!CYAN! > !YELLOW!"
call :DB_CHECKER Invites_DB "your Discord invite links" || goto :MAIN
echo.
set Proxy=NULL
set /a Invite_Percentage=0, Invite_CN=0, Invite_CN_MAX=0, Proxy_CN=0, Proxy_CN_MAX=0, Results_Valid=0, Results_Invalid=0
for %%A in (s_Index s_Results s_Results_Valid s_Results_Invalid s_Seconds) do set %%A=
%@FOR_INVITES_DB_DO% (
    set /a Invite_CN_MAX+=1
    %@TITLE%
)
echo  !BRIGHTBLACK!┌─────────────────────────────────────────────────────────────────────────────┐
echo  !BRIGHTBLACK!│         !BRIGHTBLUE!{DISCORD INVITE LINK}!BRIGHTBLACK!         ^<^> !GREEN!{STATUT}!BRIGHTBLACK!  ^<^>    !BRIGHTMAGENTA!{PROXY USED}!BRIGHTBLACK!       │
echo  !BRIGHTBLACK!├─────────────────────────────────────────────────────────────────────────────┤
for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "t1=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100"
%@FOR_INVITES_DB_DO% (
    set /a Invite_CN+=1, Invite_Percentage=Invite_CN*100/Invite_CN_MAX, Results=Results_Valid+Results_Invalid
    %@SET_S:?=Results%
    %@TITLE%
    set "URL=%%A"
    set "URL=!URL:*://=!"
    set "HTTPS_URL=https://!URL!"
    set Redirect_URL=
    for /f %%B in ('curl.exe -fIksw "%%{redirect_url}" "!HTTPS_URL!" -o NUL') do set "Redirect_URL=%%B"
    if not defined Redirect_URL set "Redirect_URL=!URL!"
    set "Redirect_URL=!Redirect_URL:*://=!"
    if "!Redirect_URL:~0,19!"=="discord.com/invite/" (
        set "Invite_Code=!Redirect_URL:discord.com/invite/=!"
        set "Display_Padding=!HTTPS_URL!"
        if "!Display_Padding:~0,37!"=="!Display_Padding!" (
            set "Display_Padding=!Display_Padding!                    "
            set "Display_Padding=!Display_Padding:~0,37!"
        )
        <nul set /p="!BS!!BRIGHTBLACK! │ !BRIGHTBLUE!!Display_Padding!!BRIGHTBLACK! <> "
        call :PROXY
    )
)
for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "t2=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100, tDiff=t2-t1, tDiff+=((~(tDiff&(1<<31))>>31)+1)*8640000, Seconds=tDiff/100"
echo  !BRIGHTBLACK!└─────────────────────────────────────────────────────────────────────────────┘
set /a Percentage=100, Results=Results_Valid+Results_Invalid
%@SET_S:?=Results%
%@SET_S:?=Results_Valid%
%@SET_S:?=Results_Invalid%
%@SET_S:?=Index%
%@SET_S:?=Seconds%
%@TITLE%
echo.
echo !CYAN!Scan completed with !Results_Valid! valid result!s_Results_Valid! and !Results_Invalid! invalid result!s_Results_Invalid! found from !Invite_CN_MAX! indexed link!s_Index! within !Seconds! second!s_Seconds!.
if exist "!@LOGGING:*>>=!" (
    >"!TMPF!\msgbox.vbs" (
        echo Dim Msg,Style,Title,Response
        echo Msg="Scan completed, do you want to open logged result!s_Results!?"
        echo Style=69668
        echo Title="!TITLE!"
        echo Response=MsgBox^(Msg,Style,Title^)
        echo If Response=vbYes then
        echo wscript.quit ^(6^)
        echo End If
        echo If Response=vbNo then
        echo wscript.quit ^(7^)
        echo End If
    )
    cscript //nologo "!TMPF!\msgbox.vbs"
    if "!ErrorLevel!"=="6" start /max "" "!@LOGGING:*>>=!"
    del /f /q "!TMPF!\msgbox.vbs"
)
echo.
<nul set /p="Press !YELLOW!{ANY KEY}!CYAN! to exit..."
>nul pause
exit

:PROXY
set LOG_Proxy=
for /f "delims=" %%A in ('curl.exe -fkLs --connect-timeout 10 --proxy "!Proxy!" "https://discord.com/invite/!Invite_Code!"') do (
    set "LOG_Proxy=%%A"
    if defined LOG_Proxy (
        if not "!LOG_Proxy:discord.com/invite/%Invite_Code%=!"=="!LOG_Proxy!" (
            set /a Results_Valid+=1
            set "Display_Padding=!Proxy!"
            if "!Display_Padding:~0,21!"=="!Display_Padding!" (
                set "Display_Padding=!Display_Padding!                    "
                set "Display_Padding=!Display_Padding:~0,21!"
            )
            echo !GREEN![ VALID ]!BRIGHTBLACK! ^<^> !BRIGHTMAGENTA!!Display_Padding!!BRIGHTBLACK! │
            %@LOGGING% echo VALID: !HTTPS_URL!
            exit /b
        )
    )
)
call :PROXY_CHECKER && (
    if defined LOG_Proxy (
        set /a Results_Invalid+=1
        set "Display_Padding=!Proxy!"
        if "!Display_Padding:~0,21!"=="!Display_Padding!" (
            set "Display_Padding=!Display_Padding!                    "
            set "Display_Padding=!Display_Padding:~0,21!"
        )
        echo !RED![INVALID]!BRIGHTBLACK! ^<^> !BRIGHTMAGENTA!!Display_Padding!!BRIGHTBLACK! │
        %@LOGGING% echo INVALID: !HTTPS_URL!
        exit /b
    )
    goto :PROXY
)
call :GENERATE_NEW_PROXY
goto :PROXY

:GENERATE_NEW_PROXY_ARRAY
set /a Proxy_CN=0, MEM=Proxy_CN_MAX, Proxy_CN_MAX=0
set Proxy=Loading...
%@TITLE%
for /l %%A in (1,1,!MEM!) do set Proxy_[%%A]=
set MEM=0
%@FOR_PROXY_DO% if not "%%A"=="" if not "%%B"=="" (
    set /a MEM+=1, Proxy_CN_MAX=MEM
    set "Proxy_[!MEM!]=%%A:%%B"
    %@TITLE%
)
set Proxy_CN=0
:GENERATE_NEW_PROXY
set /a Proxy_CN+=1
if not defined Proxy_[!Proxy_CN!] goto :GENERATE_NEW_PROXY_ARRAY
set Proxy=Searching...
%@TITLE%
for /f "tokens=1,2delims=:" %%A in ("!Proxy_[%Proxy_CN%]!") do (
    if not "%%A:%%B"=="!Proxy!" (
        set "Proxy_IP=%%A"
        set "Proxy_PORT=%%B"
        if defined Proxy_IP if defined Proxy_PORT call :CHECK_PORT Proxy_PORT && call :CHECK_IP Proxy_IP && (
            set "Proxy=!Proxy_[%Proxy_CN%]!"
            call :PROXY_CHECKER && exit /b
        )
    )
)
goto :GENERATE_NEW_PROXY

:PROXY_CHECKER
set LOG_Proxy_Checker=
for /f "delims=" %%A in ('curl.exe -fkLs --connect-timeout 5 --proxy "!Proxy!" "https://discord.com/invite/discord-developers"') do (
    set "LOG_Proxy_Checker=%%A"
    if defined LOG_Proxy_Checker (
        if not "!LOG_Proxy_Checker:discord.com/invite/discord-developers=!"=="!LOG_Proxy_Checker!" (
            %@TITLE%
            exit /b 0
        )
    )
)
exit /b 1

:DB_CHECKER
if not defined %1 exit /b 1
call :STRIP_WHITE_SPACES %1
set "%1=!%1:"=!"
if exist "!%1!" (
    if "%1"=="Invites_DB" (
        set "@FOR_INVITES_DB_DO=for /f "usebackq" %%A in ("!%1!") do"
    )
    if "%1"=="Proxy_DB" (
        set "@FOR_PROXY_DO=for /f "usebackqtokens=1-2delims=:" %%A in ("!%1!") do"
    )
) else (
    call :CHECK_URL %1 || exit /b 1
    title Establishing connection to your %~2 database: "!%1!". - !TITLE!
    curl.exe -fIkLs "!%1!" -o NUL || (
        title ERROR: Conection failed to your %~2 database: "!%1!". - !TITLE!
        call :MSGBOX 2 "ERROR: Conection failed to your %~2 database: '!%1!'." "Try again..." 69680 "!TITLE!"
        exit /b 1
    )
    title !TITLE!
    if "%1"=="Invites_DB" (
        set "@FOR_INVITES_DB_DO=for /f %%A in ('curl.exe -fkLs "!%1!"') do"
    )
    if "%1"=="Proxy_DB" (
        set "@FOR_PROXY_DO=for /f "tokens=1-2delims=:" %%A in ('curl.exe -fkLs "!%1!"') do"
    )
)
exit /b 0

:STRIP_WHITE_SPACES
if "!%1:~0,1!"==" " set "%1=!%1:~1!" & goto :STRIP_WHITE_SPACES
:_STRIP_WHITE_SPACES
if "!%1:~-1!"==" " set "%1=!%1:~0,-1!" & goto :_STRIP_WHITE_SPACES
exit /b

:CHECK_PORT
if defined %1 if "!%1!"=="!%1:..=!" if !%1! geq 0 if !%1! leq 65535 exit /b 0
exit /b 1

:CHECK_URL
for /f "tokens=1-4delims=." %%A in ("!%1!") do call :CHECKBETWEEN0AND255 %%A && call :CHECKBETWEEN0AND255 %%B && call :CHECKBETWEEN0AND255 %%C && call :CHECKBETWEEN0AND255 %%D && call :CHECK_IP %2 %1
call :_CHECK_URL %1 || exit /b 1
exit /b 0

:_CHECK_URL
<nul set /p="!%1!" | >nul findstr [A-Z0-9] || exit /b 1
if defined %1 if not "!%1:~0,1!"=="." if not "!%1:~-1!"=="." if not "!%1!"=="!%1:~0,3!" if not "!%1!"=="!%1:.=!" if "!%1!"=="!%1:..=!" exit /b 0
exit /b 1

:CHECK_IP
call :_CHECK_IP %1 || exit /b 1
exit /b 0

:_CHECK_IP
if not defined %1 exit /b 1
if "!%1!"=="!%1:~0,6!" exit /b 1
if not "!%1!"=="!%1:..=!" exit /b 1
for /f "tokens=1-5delims=." %%A in ("!%1!") do (
if not "%%E"=="" exit /b 1
call :CHECKBETWEEN0AND255 %%A || exit /b 1
call :CHECKBETWEEN0AND255 %%B || exit /b 1
call :CHECKBETWEEN0AND255 %%C || exit /b 1
call :CHECKBETWEEN0AND255 %%D || exit /b 1
)
exit /b 0

:CHECKBETWEEN0AND255
if "%~1"=="" exit /b 1
for /f "delims=1234567890" %%A in ("%~1") do exit /b 1
if %~1 lss 0 exit /b 1
if %~1 gtr 255 exit /b 1
exit /b 0

:MSGBOX
if "%1"=="2" mshta vbscript:Execute("msgbox ""%~2"" & Chr(10) & Chr(10) & ""%~3"",%4,""%~5"":close")
exit /b

:ERROR_FATAL
call :MSGBOX 2 "ERROR: '%~dp0%1' not found." "Exiting Discord Invite Links Checker..." 69648 "!TITLE!"
exit