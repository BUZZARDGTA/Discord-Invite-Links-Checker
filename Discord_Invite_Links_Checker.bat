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
::     @Grub4K - Helped reducing Curl PATH algorithm.
::     @Grub4K - Helped designing the CLI.
::     @blacktario - Original project idea.
::     @blacktario - Proxy checker idea.
::     @sintrode - Helped creating the database parsing algorithm.
::     A project created in the "server.bat" Discord: https://discord.gg/GSVrHag
::------------------------------------------------------------------------------
set title=Discord Invite Links Checker
set "MACRO_TITLE=title Progress: [!INVITE_PERCENTAGE!/100%%] - [!INVITE_CN!/!INVITE_CN_MAX!]  ^|  Results: [!Valid_Result!-!Invalid_Result!]  ^|  Proxy: [!PROXY!] - [!PROXY_CN!/!PROXY_CN_MAX!] - !title!"
Setlocal EnableDelayedExpansion
cd /d "%~dp0"
cls
title !title!
if defined TEMP (set "TMPF=!TEMP!") else if defined TMP (set "TMPF=!TMP!") else (
    call :MSGBOX 2 "Your 'TEMP' and 'TMP' environment variables do not exist." "Please fix one of them and try again." 69648 "!title!"
    exit
)
if defined ProgramFiles(x86) (
    set "PATH=Curl\x64;!PATH!"
) else (
    set "PATH=Curl\x32;!PATH!"
)
>nul 2>&1 where curl.exe || call :ERROR_FATAL !PATH:~0,8!\curl.exe
for /f "tokens=4,5delims=. " %%a in ('ver') do (
    if "%%a.%%b"=="10.0" (
        for %%A in (underline`4 underlineoff`24 red`31 green`32 yellow`33 cyan`36 brightblack`90 brightblue`94 brightmagenta`95 brightwhite`97) do (
            for /F "tokens=1,2delims=`" %%B in ("%%A") do (
                set %%B=[%%Cm
            )
        )
        set BS=
    ) else (
        set BS=
    )
)
for /F "tokens=2delims==." %%a in ('wmic os get LocalDateTime /value') do set "DateTime=%%a"
set "DateTime=!DateTime:~0,-10!-!DateTime:~-10,2!-!DateTime:~-8,2!_!DateTime:~-6,2!-!DateTime:~-4,2!-!DateTime:~-2!"
set "LOGGING=(if not exist Logs md Logs) & >>Logs\LOGS_%~n0_!DateTime!.txt"
:MAIN
cls
title !title!
echo.
echo    !brightwhite![?]!cyan! This tool does NOT work with links that do not redirect to: {https://discord.com/invite/[INVITE_CODE]}
echo.
echo    !brightwhite![?]!cyan! Your databases must be in one of the following format:
echo  !cyan!LINK !cyan!=!yellow! https://example.com/database.txt
echo  !cyan!LINK !cyan!=!yellow! http://example.com/database.txt
echo  !cyan!LINK !cyan!=!yellow! example.com/database.txt
echo  !cyan!FILE PATH !cyan!=!yellow! "C:\Users\example\Downloads\Discord Invite Links Checker\database.txt"
echo  !cyan!FILE PATH !cyan!=!yellow! database.txt
echo.
echo    !brightwhite![?]!cyan! In your databases, the content must be line by line in exactly the following formats:
echo  !underline!proxy database!underlineoff! = {[IP]:[PORT]}
echo  !underline!invite links database!underlineoff! = Any links redirecting to: {https://discord.com/invite/[INVITE_CODE]}
echo.
echo    !brightwhite![?]!cyan! (02/10/2021) Those are recommended !underline!proxy database!underlineoff!:
echo  !yellow!https://api.proxyscrape.com/v2/?request=displayproxies^&protocol=http^&timeout=10000^&country=all^&ssl=all^&anonymity=all
echo  !yellow!https://api.proxyscrape.com/?request=displayproxies^&proxytype=http^&timeout=1500^&ssl=yes
echo  !yellow!https://www.proxyscan.io/api/proxy?format=txt^&type=https
echo  !yellow!https://www.proxy-list.download/api/v1/get?type=http
echo.
echo.
echo    !cyan!Enter your !underline!proxy database!underlineoff! !cyan!LINK!cyan! (or) !cyan!FILE PATH!cyan! / Drag and Drop it below...
set PROXY_DB=
set /p "PROXY_DB=!BS!!cyan! > !yellow!"
call :DB_CHECKER PROXY_DB proxy || goto :MAIN
echo.
echo    !cyan!Enter your Discord !underline!invite links database!underlineoff! !cyan!LINK!cyan! (or) !cyan!FILE PATH!cyan! / Drag and Drop it below...
set Invites_DB=
set /p "Invites_DB=!BS!!cyan! > !yellow!"
call :DB_CHECKER Invites_DB "your Discord invite links" || goto :MAIN
echo.
set PROXY=NULL
set /a INVITE_CN=0, INVITE_CN_MAX=0, PROXY_CN=0, PROXY_CN_MAX=0, Valid_Result=0, Invalid_Result=0
%MACRO_FOR_INVITES_DB_DO% (
    set /a INVITE_CN_MAX+=1
    %MACRO_TITLE%
)
echo  !brightblack!ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo  !brightblack!³         !brightblue!{DISCORD INVITE LINK}!brightblack!         ^<^> !green!{STATUT}!brightblack!  ^<^>    !brightmagenta!{PROXY USED}!brightblack!       ³
echo  !brightblack!ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
for /f "tokens=1-4delims=:.," %%a in ("!time: =0!") do set /a "t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100"
%MACRO_FOR_INVITES_DB_DO% (
    set /a INVITE_CN+=1, INVITE_PERCENTAGE=INVITE_CN*100/INVITE_CN_MAX
    %MACRO_TITLE%
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
        <nul set /p="!BS!!brightblack! ³ !brightblue!!Display_Padding!!brightblack! <> "
        call :PROXY
    )
)
for /f "tokens=1-4delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, tDiff=t2-t1, tDiff+=((~(tDiff&(1<<31))>>31)+1)*8640000, seconds=tDiff/100"
echo  !brightblack!ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo.
for %%A in (s_r1 s_r2 s_i s_s) do set %%A=
if !Valid_Result! gtr 1 set s_r1=s
if !Invalid_Result! gtr 1 set s_r2=s
if !INVITE_CN_MAX! gtr 1 set s_i=s
if !seconds! gtr 1 set s_s=s
echo !cyan!Scan completed with !Valid_Result! valid result!s_r1! and !Invalid_Result! invalid result!s_r2! found from !INVITE_CN_MAX! indexed link!s_i! within !seconds! second!s_s!.
if exist "!LOGGING:*>>=!" (
    >"!TMPF!\msgbox.vbs" (
        echo Dim Msg,Style,Title,Response
        echo Msg="Scan completed, do you want to open logged results?"
        echo Style=69668
        echo Title="!title!"
        echo Response=MsgBox^(Msg,Style,Title^)
        echo If Response=vbYes then
        echo wscript.quit ^(6^)
        echo End If
        echo If Response=vbNo then
        echo wscript.quit ^(7^)
        echo End If
    )
    cscript //nologo "!TMPF!\msgbox.vbs"
    if "!errorlevel!"=="6" start /max "" "!LOGGING:*>>=!"
    del /f /q "!TMPF!\msgbox.vbs"
)
echo.
<nul set /p="Press !yellow!{ANY KEY}!cyan! to exit..."
>nul pause
exit

:PROXY
set LOG_PROXY=
for /f "delims=" %%A in ('curl.exe -fkLs --connect-timeout 10 --proxy "!PROXY!" "https://discord.com/invite/!Invite_Code!"') do (
    set "LOG_PROXY=%%A"
    if defined LOG_PROXY (
        if not "!LOG_PROXY:discord.com/invite/%Invite_Code%=!"=="!LOG_PROXY!" (
            set /a Valid_Result+=1
            set "Display_Padding=!PROXY!"
            if "!Display_Padding:~0,21!"=="!Display_Padding!" (
                set "Display_Padding=!Display_Padding!                    "
                set "Display_Padding=!Display_Padding:~0,21!"
            )
            echo !green![ VALID ]!brightblack! ^<^> !brightmagenta!!Display_Padding!!brightblack! ³
            %LOGGING% echo VALID: !HTTPS_URL!
            exit /b
        )
    )
)
call :PROXY_CHECKER && (
    if defined LOG_PROXY (
        set /a Invalid_Result+=1
        set "Display_Padding=!PROXY!"
        if "!Display_Padding:~0,21!"=="!Display_Padding!" (
            set "Display_Padding=!Display_Padding!                    "
            set "Display_Padding=!Display_Padding:~0,21!"
        )
        echo !red![INVALID]!brightblack! ^<^> !brightmagenta!!Display_Padding!!brightblack! ³
        %LOGGING% echo INVALID: !HTTPS_URL!
        exit /b
    )
    goto :PROXY
)
call :GENERATE_NEW_PROXY
goto :PROXY

:GENERATE_NEW_PROXY_ARRAY
set /a PROXY_CN=0, MEM=PROXY_CN_MAX, PROXY_CN_MAX=0
set PROXY=Loading...
%MACRO_TITLE%
for /L %%A in (1,1,!MEM!) do set PROXY_[%%A]=
set PROXY_CN_MAX=0
%MACRO_FOR_PROXY_DO% if not "%%A"=="" if not "%%B"=="" (
    set /a PROXY_CN+=1, PROXY_CN_MAX=PROXY_CN
    set "PROXY_[!PROXY_CN!]=%%A:%%B"
    %MACRO_TITLE%
)
set PROXY_CN=0
:GENERATE_NEW_PROXY
set /a PROXY_CN+=1
if not defined PROXY_[!PROXY_CN!] goto :GENERATE_NEW_PROXY_ARRAY
set PROXY=Searching...
%MACRO_TITLE%
for /F "tokens=1,2delims=:" %%A in ("!PROXY_[%PROXY_CN%]!") do (
    if not "%%A:%%B"=="!PROXY!" (
        set "PROXY_IP=%%A"
        set "PROXY_PORT=%%B"
        if defined PROXY_IP if defined PROXY_PORT call :CHECK_PORT PROXY_PORT && call :CHECK_IP PROXY_IP && (
            set "PROXY=!PROXY_[%PROXY_CN%]!"
            call :PROXY_CHECKER && exit /b
        )
    )
)
goto :GENERATE_NEW_PROXY

:PROXY_CHECKER
set LOG_PROXY_CHECKER=
for /f "delims=" %%A in ('curl.exe -fkLs --connect-timeout 5 --proxy "!PROXY!" "https://discord.com/invite/discord-developers"') do (
    set "LOG_PROXY_CHECKER=%%A"
    if defined LOG_PROXY_CHECKER (
        if not "!LOG_PROXY_CHECKER:discord.com/invite/discord-developers=!"=="!LOG_PROXY_CHECKER!" (
            %MACRO_TITLE%
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
        set "MACRO_FOR_INVITES_DB_DO=for /f "usebackq" %%A in ("!%1!") do"
    )
    if "%1"=="PROXY_DB" (
        set "MACRO_FOR_PROXY_DO=for /f "usebackqtokens=1-2delims=:" %%A in ("!%1!") do"
    )
) else (
    call :CHECK_URL %1 || exit /b 1
    title Establishing connection to your %~2 database: "!%1!". - !title!
    curl.exe -fIkLs "!%1!" -o NUL || (
        title ERROR: Conection failed to your %~2 database: "!%1!". - !title!
        call :MSGBOX 2 "ERROR: Conection failed to your %~2 database: '!%1!'." "Try again..." 69680 "!title!"
        exit /b 1
    )
    title !title!
    if "%1"=="Invites_DB" (
        set "MACRO_FOR_INVITES_DB_DO=for /f %%A in ('curl.exe -fkLs "!%1!"') do"
    )
    if "%1"=="PROXY_DB" (
        set "MACRO_FOR_PROXY_DO=for /f "tokens=1-2delims=:" %%A in ('curl.exe -fkLs "!%1!"') do"
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
for /f "tokens=1-4delims=." %%a in ("!%1!") do call :CHECKBETWEEN0AND255 %%a && call :CHECKBETWEEN0AND255 %%b && call :CHECKBETWEEN0AND255 %%c && call :CHECKBETWEEN0AND255 %%d && call :CHECK_IP %2 %1
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
for /f "tokens=1-5delims=." %%a in ("!%1!") do (
if not "%%e"=="" exit /b 1
call :CHECKBETWEEN0AND255 %%a || exit /b 1
call :CHECKBETWEEN0AND255 %%b || exit /b 1
call :CHECKBETWEEN0AND255 %%c || exit /b 1
call :CHECKBETWEEN0AND255 %%d || exit /b 1
)
exit /b 0

:CHECKBETWEEN0AND255
if "%~1"=="" exit /b 1
for /f "delims=1234567890" %%a in ("%~1") do exit /b 1
if %~1 lss 0 exit /b 1
if %~1 gtr 255 exit /b 1
exit /b 0

:MSGBOX
if "%1"=="2" mshta vbscript:Execute("msgbox ""%~2"" & Chr(10) & Chr(10) & ""%~3"",%4,""%~5"":close")
exit /b

:ERROR_FATAL
call :MSGBOX 2 "ERROR: '%~dp0%1' not found." "Exiting Discord Invite Links Checker..." 69648 "!title!"
exit