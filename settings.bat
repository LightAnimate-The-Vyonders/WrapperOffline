:: Wrapper: Offline Settings
:: Change parts of this file to change settings that Wrapper uses.

:: Opens script in Notepad when run
@ECHO OFF && SETLOCAL
if /i "%ACTUALLYLOADSETTINGS%"=="" (
echo Settings script running standalone detected.
start notepad.exe settings.bat
exit
)
endlocal

::::::::::::::::::::
:: Startup Script ::
::::::::::::::::::::

:: Change this to yes to see more of what exactly Wrapper is doing, and never clear the screen. Useful for development and troubleshooting
set VERBOSEWRAPPER=yes

:: If checking for dependencies takes too long and you know you have them all, you can skip it entirely and it will just attempt to boot Wrapper right away.
set SKIPCHECKDEPENDS=no

:: If (for whatever reason) you want to skip installing any missing dependencies, change this to yes.
set SKIPDEPENDINSTALL=no

:::::::::::::::::::::
:: Browser Options ::
:::::::::::::::::::::

:: A copy of ungoogled-chromium that supports Flash is included with Wrapper: Offline.
:: Switch this to no and it will open Wrapper in that instead. This option overrides CUSTOMBROWSER.
set INCLUDEDCHROMIUM=yes
:: Switch this to no and Chromium will open in normal browser instead of an app format
set APPCHROMIUM=no

:: If you would rather start Wrapper in a browser other than your default, change "<BROWSER_PATH>" to the location of your browser. To reset to your default browser, set this to "<BROWSER_PATH>" again.
:: An easy way to find this: Right-click a Desktop shortcut, click Open file location, and your browser should be the highlighted item. Right click that while holding Shift, and click Copy as path.
set CUSTOMBROWSER="<BROWSER_PATH>"