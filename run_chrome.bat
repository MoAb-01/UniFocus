@echo off
setlocal EnableDelayedExpansion

title UniFocus - Localhost Web (Chrome)
cd /d "%~dp0"

echo ========================================================
echo        UniFocus: Starting Flutter Web on Localhost
echo ========================================================
echo.

:: 1. Ensure Git is in PATH (Flutter requires Git to verify its SDK)
where git >nul 2>&1
if errorlevel 1 (
    if exist "C:\Program Files\Git\cmd" set "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin;!PATH!"
    if exist "C:\Program Files (x86)\Git\cmd" set "PATH=C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin;!PATH!"
    if exist "%LOCALAPPDATA%\Programs\Git\cmd" set "PATH=%LOCALAPPDATA%\Programs\Git\cmd;!PATH!"
)

:: 2. Ensure Flutter is in PATH
where flutter >nul 2>&1
if errorlevel 1 (
    if exist "C:\src\flutter\bin" set "PATH=C:\src\flutter\bin;!PATH!"
    if exist "C:\flutter\bin" set "PATH=C:\flutter\bin;!PATH!"
    if exist "%LOCALAPPDATA%\flutter\bin" set "PATH=%LOCALAPPDATA%\flutter\bin;!PATH!"
    if exist "%USERPROFILE%\flutter\bin" set "PATH=%USERPROFILE%\flutter\bin;!PATH!"
    if exist "%USERPROFILE%\development\flutter\bin" set "PATH=%USERPROFILE%\development\flutter\bin;!PATH!"
    if exist "D:\flutter\bin" set "PATH=D:\flutter\bin;!PATH!"
    if exist "E:\flutter\bin" set "PATH=E:\flutter\bin;!PATH!"
)

:: 3. Verify Flutter is now executable
where flutter >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter SDK not found!
    echo Please make sure Flutter is installed.
    echo.
    goto :EXIT_SCRIPT
)

:: 4. Verify Git is now executable
where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git was not found!
    echo Flutter requires Git in order to run properly.
    echo Please install Git or add it to your system PATH.
    echo.
    goto :EXIT_SCRIPT
)

set "WEB_PORT=5000"
set "WEB_HOST=localhost"

echo [INFO] Project Directory : %~dp0
echo [INFO] Target Device     : Google Chrome
echo [INFO] Local URL         : http://!WEB_HOST!:!WEB_PORT!
echo.
echo Starting web server and launching Chrome...
echo --------------------------------------------------------
echo  Useful Flutter Web Controls:
echo   [r] Hot Reload
echo   [R] Hot Restart
echo   [h] List all interactive commands
echo   [q] Quit and close session
echo --------------------------------------------------------
echo.

:: 5. Launch Flutter Web with Chrome on port 5000
:: Using cmd.exe /c ensures that any internal exit in flutter.bat never kills this parent window
cmd.exe /c "flutter run -d chrome --web-hostname=!WEB_HOST! --web-port=!WEB_PORT! %*"

if !ERRORLEVEL! equ 0 goto :SESSION_DONE

echo.
echo --------------------------------------------------------
echo [NOTICE] Chrome launch on port !WEB_PORT! exited with code !ERRORLEVEL!.
echo Attempting fallback: Launching Chrome with dynamic port...
echo --------------------------------------------------------
echo.

cmd.exe /c "flutter run -d chrome --web-hostname=!WEB_HOST! %*"

if !ERRORLEVEL! equ 0 goto :SESSION_DONE

echo.
echo --------------------------------------------------------
echo [NOTICE] Attempting Web-Server mode fallback...
echo (Opening http://!WEB_HOST!:!WEB_PORT! in your browser)
echo --------------------------------------------------------
echo.
start http://!WEB_HOST!:!WEB_PORT!
cmd.exe /c "flutter run -d web-server --web-hostname=!WEB_HOST! --web-port=!WEB_PORT! %*"

:SESSION_DONE
echo.
echo ========================================================
echo UniFocus session ended.
echo ========================================================

:EXIT_SCRIPT
echo.
echo Press any key to exit this window...
pause >nul
