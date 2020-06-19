:: Wrapper: Offline Launcher
:: Author: benson#0411
:: License: MIT
set WRAPPER_VER=1.1.1
title Wrapper: Offline v%WRAPPER_VER% [Initializing...]

::::::::::::::::::::
:: Initialization ::
::::::::::::::::::::

:: Stop commands from spamming stuff, cleans up the screen
@echo off && cls

:: Lets variables work or something idk im not a nerd
SETLOCAL ENABLEDELAYEDEXPANSION

:: Make sure we're starting in the correct folder
cd %~dp0

echo Wrapper: Offline
echo A project from VisualPlugin adapted by Benson
echo Version %WRAPPER_VER%
echo:

set ACTUALLYLOADSETTINGS=yes
echo Loading settings...
call settings.bat
echo:

:: Prevents CTRL+C cancelling (please close with 0)
if %VERBOSEWRAPPER%==no (
	if "%~1" equ "point_insertion" goto point_insertion
	start "" /B cmd /C "%~F0" point_insertion
	exit
)

:point_insertion

if %VERBOSEWRAPPER%==yes ( echo Verbose mode activated. && echo:)

::::::::::::::::::::::
:: Dependency Check ::
::::::::::::::::::::::

if %SKIPCHECKDEPENDS%==yes (
	echo Checking dependencies has been skipped.
	echo:
	goto skip_dependency_install
)

if %VERBOSEWRAPPER%==no (
	echo Checking for dependencies...
	echo:
)

title Wrapper: Offline v%WRAPPER_VER% [Checking dependencies...]

:: Preload variables
set NEEDTHEDEPENDERS=no
set ADMINREQUIRED=no
set FLASH_DETECTED=no
set FLASH_CHROMIUM_DETECTED=no
set FLASH_FIREFOX_DETECTED=no
set NODEJS_DETECTED=no
set HTTPSERVER_DETECTED=no
set HTTPSCERT_DETECTED=no

:: Flash Player
if %VERBOSEWRAPPER%==yes ( echo Checking for Flash installation... )
set FLASH_DIR="%windir%\SysWOW64\Macromed\Flash\"
if exist "%FLASH_DIR%\*pepper.exe" set FLASH_DETECTED=yes && set FLASH_CHROMIUM_DETECTED=yes
if exist "%FLASH_DIR%\*pepper.exe" set FLASH_DETECTED=yes && set FLASH_CHROMIUM_DETECTED=yes
if exist "%FLASH_DIR%\*plugin.exe" set FLASH_DETECTED=yes && set FLASH_FIREFOX_DETECTED=yes
if exist "%FLASH_DIR%\*plugin.exe" set FLASH_DETECTED=yes && set FLASH_FIREFOX_DETECTED=yes
if %FLASH_DETECTED%==yes (
	if %INCLUDEDCHROMIUM%==yes (
		if %FLASH_CHROMIUM_DETECTED%==no (
			echo Flash for Chrome could not be found.
			echo:
		) else (
			echo Flash is installed.
			echo:
		)
	) else (
		echo Flash is installed.
		echo:
	)
) else (
	echo Flash could not be found.
	echo:
	set NEEDTHEDEPENDERS=yes
	set ADMINREQUIRED=yes
)
:flash_checked

:: Node.js
if %VERBOSEWRAPPER%==yes ( echo Checking for Node.js installation... )
for /f "delims=" %%i in ('npm -v 2^>nul') do set output=%%i
IF "!output!" EQU "" (
	echo Node.js could not be found.
	echo:
	set NEEDTHEDEPENDERS=yes
	set ADMINREQUIRED=yes
	goto httpserver_checked
) else (
	echo Node.js is installed.
	echo:
	set NODEJS_DETECTED=yes
)
:nodejs_checked

:: http-server
if %VERBOSEWRAPPER%==yes ( echo Checking for http-server installation... )
npm list -g | find "http-server" >> NUL
if %ERRORLEVEL% == 0 (
	echo http-server is installed.
	echo:
	set HTTPSERVER_DETECTED=yes
) else (
	echo http-server could not be found.
	echo:
	set NEEDTHEDEPENDERS=yes
)
:httpserver_checked

:: HTTPS cert
if %VERBOSEWRAPPER%==yes ( echo Checking for HTTPS certificate... )
:: ...in probably the least reliable way possible.
pushd server
if exist "isinstalled.txt" (
	echo HTTPS cert probably installed.
	echo:
	set HTTPSCERT_DETECTED=yes
) else (
	echo HTTPS cert probably not installed.
	echo:
	set NEEDTHEDEPENDERS=yes
	set ADMINREQUIRED=yes
)
popd

::::::::::::::::::::::::
:: Dependency Install ::
::::::::::::::::::::::::

if %NEEDTHEDEPENDERS%==yes (
	if %SKIPDEPENDINSTALL%==no (
		echo:
		echo Installing missing dependencies...
		echo:
	) else (
	echo Skipping dependency install.
	goto skip_dependency_install
	)
) else (
	echo All dependencies are available.
	echo:
	goto skip_dependency_install
)

title Wrapper: Offline v%WRAPPER_VER% [Installing dependencies...]

:: Preload variables
set INSTALL_FLAGS=ALLUSERS=1 /norestart
set SAFE_MODE=no
if /i "%SAFEBOOT_OPTION%"=="MINIMAL" set SAFE_MODE=yes
if /i "%SAFEBOOT_OPTION%"=="NETWORK" set SAFE_MODE=yes
set CPU_ARCHITECTURE=what
if /i "%processor_architecture%"=="x86" set CPU_ARCHITECTURE=32
if /i "%processor_architecture%"=="AMD64" set CPU_ARCHITECTURE=64
if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" set CPU_ARCHITECTURE=64

:: Check for admin if installing Flash or Node.js
:: Skipped in Safe Mode, just in case anyone is running Wrapper in safe mode... for some reason
:: and also because that was just there in the code i used for this and i was like "eh screw it why remove it"
if %ADMINREQUIRED%==yes (
	if %VERBOSEWRAPPER%==yes ( echo Checking for Administrator rights... && echo:)
	if /i not "%SAFE_MODE%"=="yes" (
		fsutil dirty query %systemdrive% >NUL 2>&1
		if /i not !ERRORLEVEL!==0 (
			color cf
			if %VERBOSEWRAPPER%==no ( cls )
			echo:
			echo  ERROR
			echo:
			echo  Wrapper needs to install its dependencies.
			echo  To do this, it must be started with Admin rights.
			echo:
			echo  Close this window and re-open Wrapper as an Admin.
			echo  ^(right-click start_wrapper.bat and click "Run as Administrator"^)
			echo:
			pause
			exit
		)
	)
	if %VERBOSEWRAPPER%==yes ( echo Admin rights detected. && echo:)
)

:: Flash Player
if %FLASH_DETECTED%==yes (
	if %INCLUDEDCHROMIUM%==yes (
		if %FLASH_CHROMIUM_DETECTED%==yes (
			 goto after_flash_install
		) else (
			 goto start_flash_install
		)
	) else (
		goto after_flash_install
	)
)
if %FLASH_DETECTED%==no (
	:start_flash_install
	echo Installing Flash Player...
	echo:
	if %INCLUDEDCHROMIUM%==yes (
		if %VERBOSEWRAPPER%==yes ( echo Popup-Chromium option chosen, skipping browser question. && echo:)
		set BROWSER_TYPE=chromium
		goto :escape_browser_ask
	) else (
		:: Ask what type of browser is being used.
		echo What web browser do you use? If it isn't here,
		echo look up whether it's based on Chromium or Firefox.
		echo If it's not based on either, then
		echo Wrapper will not be able to install Flash.
		echo Unless you know what you're doing and have a
		echo version of Flash made for your browser, please
		echo install a Chrome or Firefox based browser.
		echo:
		echo Enter 1 for Chrome
		echo Enter 2 for Firefox
		echo Enter 3 for Edge
		echo Enter 4 for Opera
		echo Enter 5 for Chrome-based browser
		echo Enter 6 for Firefox-based browser
		echo Enter 0 for a non-standard browser (skips install^^)
		:browser_ask
		set /p FLASHCHOICE=Response:
		echo:
		if not '%flashchoice%'=='' set flashchoice=%flashchoice:~0,1%
		if '%flashchoice%'=='1' goto chromium_chosen
		if '%flashchoice%'=='2' goto firefox_chosen
		if '%flashchoice%'=='3' goto chromium_chosen
		if '%flashchoice%'=='4' goto chromium_chosen
		if '%flashchoice%'=='5' goto chromium_chosen
		if '%flashchoice%'=='6' goto firefox_chosen
		if '%flashchoice%'=='0' echo Flash will not be installed.&& goto after_flash_install
		echo You must pick a browser.&& goto browser_ask

		:chromium_chosen
		set BROWSER_TYPE=chromium && if %VERBOSEWRAPPER%==yes ( echo Chromium-based browser picked. && echo:) && goto escape_browser_ask

		:firefox_chosen
		set BROWSER_TYPE=firefox && if %VERBOSEWRAPPER%==yes ( echo Firefox-based browser picked. ) && goto escape_browser_ask
	)

	:escape_browser_ask

	:: Warn before closing browsers
	echo To install Flash Player, Wrapper must kill any currently running web browsers.
	echo Please make sure any work in your browser is saved before proceeding.
	echo Wrapper will not continue installation until you press a key.
	echo:
	pause
	echo:

	:: Summon the Browser Slayer
	echo Ripping and tearing browsers...
	for %%i in (firefox,palemoon,iexplore,chrome,chrome64,opera) do (
		if %VERBOSEWRAPPER%==yes (
			 taskkill /f /im %%i.exe /t
			 wmic process where name="%%i.exe" call terminate
		) else (
			 taskkill /f /im %%i.exe /t >> NUL
			 wmic process where name="%%i.exe" call terminate >> NUL
		)
	)
	echo:

	if %BROWSER_TYPE%==chromium (
		echo Starting Flash installer...
		msiexec /i "utilities\flash_windows_chromium.msi" %INSTALL_FLAGS% /quiet
	)
	if %BROWSER_TYPE%==firefox (
		echo Starting Flash installer...
		msiexec /i "utilities\flash_windows_firefox.msi" %INSTALL_FLAGS% /quiet
	)

	echo Flash has been installed.
	echo:
)
:after_flash_install

:: Node.js
if %NODEJS_DETECTED%==no (
	echo Installing Node.js...
	echo:
	:: Install Node.js
	if %CPU_ARCHITECTURE%==64 (
		if %VERBOSEWRAPPER%==yes ( echo 64-bit system detected, installing 64-bit Node.js. )
		echo Proper Node.js installation doesn't seem possible to do automatically.
		echo You can just keep clicking next until it finishes, and Wrapper will continue once it closes.
		msiexec /i "utilities\node_windows_x64.msi" %INSTALL_FLAGS%
		goto nodejs_installed
	)
	if %CPU_ARCHITECTURE%==32 (
		if %VERBOSEWRAPPER%==yes ( echo 32-bit system detected, installing 32-bit Node.js. )
		echo Proper Node.js installation doesn't seem possible to do automatically.
		echo You can just keep clicking next until it finishes, and Wrapper will continue once it closes.
		msiexec /i "utilities\node_windows_x32.msi" %INSTALL_FLAGS%
		goto nodejs_installed
	)
	if %CPU_ARCHITECTURE%==what (
		echo:
		echo Well, this is a little embarassing.
		echo Wrapper can't tell if you're on a 32-bit or 64-bit system.
		echo Which means it doesn't know which version of Node.js to install...
		echo:
		echo If you have no idea what that means, press 1 to just try anyway.
		echo If you're in the future with newer architectures or something
		echo and you know what you're doing, then press 3 to keep going.
		echo:
		:architecture_ask
		set /p CPUCHOICE= Response:
		echo:
		if not '%cpuchoice%'=='' set cpuchoice=%cpuchoice:~0,1%
		if '%cpuchoice%'=='1' msiexec "utilities\node-v13.12.0-x32.msi" %INSTALL_FLAGS% && if %VERBOSEWRAPPER%==yes ( echo Attempting 32-bit Node.js installation. ) && goto nodejs_installed
		if '%cpuchoice%'=='3' echo Node.js will not be installed. && goto after_nodejs_install
		echo You must pick one or the other.&& goto architecture_ask
	)
	:nodejs_installed
	echo Node.js has been installed.
	set NODEJS_DETECTED=yes
	echo:
	goto install_cert
)
:after_nodejs_install

:: http-server
if %HTTPSERVER_DETECTED%==no (
	if %NODEJS_DETECTED%==yes (
		echo Installing http-server...
		echo:

		:: Attempt to install through NPM normally
		call npm install http-server -g

		:: Double check for installation
		echo Checking for http-server installation again...
		npm list -g | find "http-server" >> NUL
		if %ERRORLEVEL% == 0 (
			goto http-server-installed
		) else (
			echo:
			echo Online installation attempt failed. Trying again from local files...
			echo:
			call npm install utilities\http-server-master -g
			goto triplecheckhttpserver
		)

		:: Triple check for installation
		echo Checking for http-server installation AGAIN...
		:triplecheckhttpserver
		npm list -g | find "http-server" >> NUL
		if %ERRORLEVEL% == 0 (
			goto http-server-installed
		) else (
			echo:
			echo Local file installation failed. Something's not right.
			echo Unless this was intentional, ask for support or install http-server manually.
			echo Enter "npm install http-server -g" into a command prompt.
			echo:
			pause
			exit
		)
	) else (
		color cf
		echo:
		echo http-server is missing, but somehow Node.js has not been installed yet.
		echo Seems either the install failed, or Wrapper managed to skip it.
		echo If installing directly from nodejs.org does not work, something is horribly wrong.
		echo Please ask for help in the #support channel on Discord, or email me.
		pause
		exit
	)
	:http-server-installed
	echo http-server has been installed.
	echo:
	goto install_cert
)

:: Install HTTPS certificate
:install_cert
pushd server
if %HTTPSCERT_DETECTED%==no (
	echo Installing HTTPS certificate...
	echo:
	if %VERBOSEWRAPPER%==yes (
		certutil -addstore -f -enterprise -user root the.crt
	) else (
		certutil -addstore -f -enterprise -user root the.crt >> NUL
	)
	echo watch benson on youtube >> isinstalled.txt
)
popd
:after_cert_install

:: Alert user to restart Wrapper without running as Admin
if %ADMINREQUIRED%==yes (
	color 20
	if %VERBOSEWRAPPER%==no ( cls )
	echo:
	echo Dependencies needing Admin now installed^^!
	echo:
	echo Wrapper no longer needs Admin rights,
	echo please restart normally by double-clicking.
	echo:
	echo If you saw this from running normally,
	echo Wrapper should continue normally after a restart.
	echo:
	pause
	exit
)
color 0f
echo All dependencies now installed^^! Continuing with Wrapper boot.
echo:

:skip_dependency_install

::::::::::::::::::::::
:: Starting Wrapper ::
::::::::::::::::::::::

title Wrapper: Offline v%WRAPPER_VER% [Loading...]

pushd utilities
:: Start http-server
echo Loading assets...
if %VERBOSEWRAPPER%==yes (
	start /MIN open_http-server.bat
) else (
	start SilentCMD open_http-server.bat
)

:: Start Node.js
echo Loading Node.js...
if %VERBOSEWRAPPER%==yes (
	start /MIN open_nodejs.bat
) else (
	start SilentCMD open_nodejs.bat
)
popd

:: Open Wrapper in preferred browser
if %INCLUDEDCHROMIUM%==no (
	if %CUSTOMBROWSER%=="<BROWSER_PATH>" (
		echo Opening Wrapper in your default browser...
		start http://localhost
	) else (
		echo Opening Wrapper in your set browser...
		echo If this does not work, you may have set the path wrong.
		start %CUSTOMBROWSER% http://localhost
	)
) else (
	echo Opening Wrapper using included Chromium...
	pushd utilities\ungoogled-chromium
	if %APPCHROMIUM%==yes (
		start chrome.exe --user-data-dir=the_profile --app=http://localhost
	) else (
		start chrome.exe --user-data-dir=the_profile http://localhost
	)
	popd
)

echo Wrapper has been started^^! The video list should now be open.

::::::::::::::::
:: Post-Start ::
::::::::::::::::

title Wrapper: Offline v%WRAPPER_VER%
:wrapperstartedcls
if %VERBOSEWRAPPER%==no ( cls )
:wrapperstarted

echo:
echo Wrapper: Offline v%WRAPPER_VER% running
echo A project from VisualPlugin adapted by Benson
echo:
echo DON'T CLOSE THIS WINDOW^^! Use the quit option (0) when you're done.
echo:
echo Enter 1 to reopen the video list
echo Enter 2 to open the server page
echo Enter 3 to open Wrapper's files
echo Enter 4 to open the settings file
echo Enter 5 to open the README
echo Enter 6 to clean up the screen
echo Enter 0 to quit Wrapper
:wrapperidle
set /p CHOICE=Choice:
echo:
if NOT DEFINED choice echo Time to choose.&& goto wrapperidle
if '%choice%'==' ' echo Time to choose.&& goto wrapperidle
if '%choice%'=='1' goto reopen_webpage
if '%choice%'=='2' goto open_server
if '%choice%'=='3' goto open_files
if '%choice%'=='4' goto open_settings
if '%choice%'=='5' goto open_readme
if '%choice%'=='6' goto clear_idle_screen
if '%choice%'=='0' goto exitwrapperconfirm
if '%choice%'=='watchbensononyoutube' goto watchbensononyoutube
if '%choice%'=='fourtythree' goto fourtythree
echo Time to choose.&& goto wrapperidle

:reopen_webpage
if %INCLUDEDCHROMIUM%==no (
	if %CUSTOMBROWSER%=="<BROWSER_PATH>" (
		echo Opening Wrapper in your default browser...
		start http://localhost
	) else (
		echo Opening Wrapper in your set browser...
		start %CUSTOMBROWSER% http://localhost >> NUL
	)
) else (
	echo Opening Wrapper using included Chromium...
	pushd utilities\ungoogled-chromium
	if %APPCHROMIUM%==yes (
		start chrome.exe --user-data-dir=the_profile --app=http://localhost >> NUL
	) else (
		start chrome.exe --user-data-dir=the_profile http://localhost >> NUL
	)
	popd
)
goto wrapperidle

:open_server
if %CUSTOMBROWSER%=="<BROWSER_PATH>" (
	echo Opening the server page in your default browser...
	start https://localhost:4343
) else (
	if %CUSTOMBROWSER%=="" (
		echo Opening the server page in your default browser...
		start https://localhost:4343
	) else (
		echo Opening the server page in your set browser...
		start %CUSTOMBROWSER% https://localhost:4343 >> NUL
	)
)
goto wrapperidle

:open_files
pushd ..
echo Opening the wrapper-offline folder...
start explorer.exe wrapper-offline
popd
goto wrapperidle

:open_settings
echo Opening the settings file...
echo NOTE: Changes won't take effect until a restart of Wrapper.
start notepad.exe settings.bat
goto wrapperidle

:open_readme
echo Opening the README...
start notepad.exe README.txt
goto wrapperidle

:clear_idle_screen
if %VERBOSEWRAPPER%==yes ( echo Verbose mode enabled, clearing blocked. )
goto wrapperstartedcls

:watchbensononyoutube
echo watch benson on youtube
goto wrapperidle

:fourtythree
echo OH MY GOD. FOURTY THREE CHARS. NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
goto wrapperidle


::::::::::::::
:: Shutdown ::
::::::::::::::

:: Confirmation before shutting down
:exitwrapperconfirm
echo Are you sure you want to quit Wrapper?
echo Be sure to save all your work.
echo Type Y to quit, and N to go back.
:exitwrapperretry
set /p EXITCHOICE= Response:
echo:
if not '%exitchoice%'=='' set exitchoice=%exitchoice:~0,1%
if '%exitchoice%'=='Yes' goto point_extraction
if '%exitchoice%'=='yes' goto point_extraction
if '%exitchoice%'=='Y' goto point_extraction
if '%exitchoice%'=='y' goto point_extraction
if '%exitchoice%'=='No' goto wrapperstartedcls
if '%exitchoice%'=='no' goto wrapperstartedcls
if '%exitchoice%'=='N' goto wrapperstartedcls
if '%exitchoice%'=='n' goto wrapperstartedcls
echo You must answer Yes or No. && goto :exitwrapperretry

:point_extraction

title Wrapper: Offline v%WRAPPER_VER% [Shutting down...]

:: Shut down Node.js and http-server
if %VERBOSEWRAPPER%==yes (
	TASKKILL /IM node.exe /F
	echo:
) else (
	TASKKILL /IM node.exe /F >> NUL
)

:: This is where I get off.
echo Wrapper has been shut down.
echo This window will now close.
echo Open start_wrapper.bat again to start Wrapper again.
ENDLOCAL
pause
exit