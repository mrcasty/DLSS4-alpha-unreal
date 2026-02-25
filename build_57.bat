@echo off
REM ============================================================
REM  Build DLSS Alpha Fix Plugin - Unreal Engine 5.7
REM  Single source, multi-engine build (same source as 5.6)
REM ============================================================
setlocal

set UE_ROOT=C:\Program Files\Epic Games\UE_5.7
set PROJECT_DIR=%~dp05.6\DLSSA
set UPROJECT=%PROJECT_DIR%\DLSSA.uproject
set ENGINE_VER=5.7
set ENGINE_VER_FULL=5.7.0

echo.
echo ============================================================
echo  Building DLSS Alpha Fix for UE %ENGINE_VER%
echo  Engine: %UE_ROOT%
echo  Project: %UPROJECT%  (shared source)
echo ============================================================
echo.

if not exist "%UPROJECT%" (
    echo ERROR: Project file not found: %UPROJECT%
    exit /b 1
)

if not exist "%UE_ROOT%\Engine\Build\BatchFiles\Build.bat" (
    echo ERROR: UE %ENGINE_VER% Build.bat not found at %UE_ROOT%
    exit /b 1
)

REM Clean previous compiler outputs only (preserve ThirdParty binaries like nvngx_dlss.dll)
echo Cleaning previous build artifacts...
if exist "%PROJECT_DIR%\Binaries\Win64" (
    del /q "%PROJECT_DIR%\Binaries\Win64\*.dll" 2>nul
    del /q "%PROJECT_DIR%\Binaries\Win64\*.target" 2>nul
    del /q "%PROJECT_DIR%\Binaries\Win64\*.modules" 2>nul
)
if exist "%PROJECT_DIR%\Intermediate" rd /s /q "%PROJECT_DIR%\Intermediate"
for /d %%P in ("%PROJECT_DIR%\plugins\*") do (
    if exist "%%P\Binaries\Win64" (
        del /q "%%P\Binaries\Win64\*.dll" 2>nul
        del /q "%%P\Binaries\Win64\*.target" 2>nul
        del /q "%%P\Binaries\Win64\*.modules" 2>nul
    )
    if exist "%%P\Intermediate" rd /s /q "%%P\Intermediate"
)

REM Patch version strings to match target engine
echo Patching project and plugin versions to %ENGINE_VER%...
powershell -Command "(Get-Content '%UPROJECT%') -replace '\"EngineAssociation\": \"5\.\d+\"', '\"EngineAssociation\": \"%ENGINE_VER%\"' | Set-Content '%UPROJECT%'"
powershell -Command "Get-ChildItem '%PROJECT_DIR%\plugins' -Recurse -Filter '*.uplugin' | ForEach-Object { (Get-Content $_.FullName) -replace '\"EngineVersion\": \"5\.\d+\.\d+\"', '\"EngineVersion\": \"%ENGINE_VER_FULL%\"' | Set-Content $_.FullName }"

call "%UE_ROOT%\Engine\Build\BatchFiles\Build.bat" DLSSAEditor Win64 Development -Project="%UPROJECT%" -WaitMutex -FromMsBuild

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo BUILD FAILED with error code %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo BUILD SUCCEEDED
pause
