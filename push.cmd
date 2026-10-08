@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set VERSION_FILE=.\versions\version
set LOG_DIR=.\versions
set BACKUP_FILE=.\versions\version.back.origin

if not exist %LOG_DIR% mkdir %LOG_DIR%

for /f "delims=" %%a in ('powershell -Command "Get-Date -Format 'yyyyMMdd_HHmmss'"') do set timestamp=%%a

if not exist %VERSION_FILE% (
    echo v0.0.00 > %VERSION_FILE%
)
set /p cur_version=<%VERSION_FILE%
if "%cur_version%"=="" (
    set cur_version=v0.0.00
    echo !cur_version! > %VERSION_FILE%
)
set old_version=%cur_version%

git add .
if errorlevel 1 (
    call :log_error "%old_version%" "%timestamp%" "git add failed"
    exit /b 1
)
set "extra_msg=%~1"
if defined extra_msg (
    git commit -m "%cur_version% %extra_msg%"
) else (
    git commit -m "%cur_version%"
)

if errorlevel 1 (
    call :log_error "%old_version%" "%timestamp%" "git commit failed"
    exit /b 1
)

call :increment_version "%cur_version%" new_version
echo !new_version! > %VERSION_FILE%

git push origin main
if errorlevel 1 goto push_fail

echo Push successful.
exit /b 0

:push_fail
set errmsg=git push failed
call :log_error "%old_version%" "%timestamp%" "%errmsg%"

echo [WARN] Push failed, attempting to backup remote and merge...

set branch_name=origin-backup-%old_version%

git fetch origin
if errorlevel 1 (
    call :log_error "%old_version%" "%timestamp%" "git fetch failed during backup"
    exit /b 1
)

git branch !branch_name! origin/main
if errorlevel 1 (
    call :log_error "%old_version%" "%timestamp%" "git branch creation failed"
    exit /b 1
)

git merge origin/main --allow-unrelated-histories -X ours
if errorlevel 1 (
    call :log_error "%old_version%" "%timestamp%" "git merge failed"
    exit /b 1
)

git push origin main
if errorlevel 1 (
    call :log_error "%old_version%" "%timestamp%" "git push after merge failed"
    exit /b 1
)

echo [%timestamp%@%old_version%]:!branch_name! >> %BACKUP_FILE%
echo Backup and push successful.
exit /b 0

:log_error
set log_version=%~1
set log_time=%~2
set log_msg=%~3
set log_file=%LOG_DIR%\%log_version%_%log_time%.log
(
    echo Error: %log_msg%
    echo Time: %log_time%
    echo Version: %log_version%
) > %log_file%
exit /b

:increment_version
set ver=%~1
set ver=%ver:v=%
for /f "tokens=1,2,3 delims=." %%a in ("%ver%") do (
    set major=%%a
    set minor=%%b
    set rev=%%c
)
set /a "rev=100!rev! %% 100"
set /a rev+=1
if !rev! lss 10 set rev=0!rev!
set newver=v%major%.%minor%.!rev!
set "%~2=!newver!"
exit /b