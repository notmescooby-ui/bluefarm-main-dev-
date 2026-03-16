@echo off
setlocal enabledelayedexpansion
echo ========================================================
echo         BlueFarm - Aquaculture Monitoring System        
echo ========================================================
echo.

echo Select a platform to run BlueFarm:
echo   [1] Chrome
echo   [2] Edge
echo   [3] Android Studio (Emulator)
echo.
choice /C 123 /N /M "Enter your choice (1/2/3): "
set "choice=%errorlevel%"
echo.

if "%choice%"=="1" (
    set DEVICE=chrome
    set EXTRA_ARGS=--web-port=3000
) else if "%choice%"=="2" (
    set DEVICE=edge
    set EXTRA_ARGS=--web-port=3000
) else if "%choice%"=="3" (
    goto android_setup
) else (
    echo Invalid choice. Exiting.
    pause
    exit /b 1
)
goto run_app

:android_setup
set DEVICE=
set EXTRA_ARGS=

REM Set Android SDK path
if defined ANDROID_HOME (
    set SDK_PATH=%ANDROID_HOME%
) else if defined ANDROID_SDK_ROOT (
    set SDK_PATH=%ANDROID_SDK_ROOT%
) else (
    set SDK_PATH=%LOCALAPPDATA%\Android\Sdk
)

echo.
echo Checking for Android emulators...
echo SDK Path: %SDK_PATH%

if not exist "%SDK_PATH%\emulator\emulator.exe" (
    echo ERROR: Android emulator not found at %SDK_PATH%\emulator\emulator.exe
    echo Please set ANDROID_HOME or install Android SDK properly.
    pause
    exit /b 1
)

if not exist "%SDK_PATH%\platform-tools\adb.exe" (
    echo ERROR: adb not found at %SDK_PATH%\platform-tools\adb.exe
    echo Please install Android platform-tools from SDK Manager.
    pause
    exit /b 1
)

REM Reuse an already-running emulator if available
for /f "tokens=1" %%d in ('"%SDK_PATH%\platform-tools\adb.exe" devices ^| findstr /R "^emulator-[0-9][0-9]*"') do (
    set "DEVICE=%%d"
    goto emulator_started
)

REM List available emulators
echo.
echo Available emulators:
"%SDK_PATH%\emulator\emulator.exe" -list-avds
echo.

REM Launch the first available emulator in background
for /f "tokens=*" %%a in ('"%SDK_PATH%\emulator\emulator.exe" -list-avds') do (
    echo Starting emulator: %%a
    start "" "%SDK_PATH%\emulator\emulator.exe" -avd %%a
    goto emulator_started
)

echo ERROR: No Android emulators found. Create one in Android Studio first.
pause
exit /b 1

:emulator_started
if defined DEVICE (
    echo Using emulator: !DEVICE!
) else (
    echo Waiting for emulator to boot...
    timeout /t 20 /nobreak >nul
)

REM Wait for device to be detected by adb
echo Waiting for device to come online...
"%SDK_PATH%\platform-tools\adb.exe" wait-for-device

:run_app
echo.
echo [1/3] Installing Flutter dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed. Check your Flutter installation.
    pause
    exit /b 1
)
echo.

if "%choice%" neq "3" (
    echo [2/3] Starting React backend on port 4000...
    cd react_frontend
    set PORT=4000
    start /B npm start
    cd ..
    echo Waiting for React to initialize...
    timeout /t 5 /nobreak >nul
    echo.
)

if "!choice!"=="3" (
    REM Auto-detect the emulator device ID if not already chosen
    if not defined DEVICE (
        for /f "tokens=1" %%d in ('"%SDK_PATH%\platform-tools\adb.exe" devices ^| findstr /R "^emulator-[0-9][0-9]*"') do (
            set "DEVICE=%%d"
        )
    )
    if not defined DEVICE (
        echo ERROR: No running emulator detected.
        pause
        exit /b 1
    )
    echo Detected emulator: !DEVICE!
)

echo [3/3] Launching BlueFarm on !DEVICE!...
call flutter run -d !DEVICE! !EXTRA_ARGS!

echo.
echo BlueFarm closed.
pause
