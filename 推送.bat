@echo off
cd /d "%~dp0"

echo.
echo ============================================
echo   Blog Push Tool
echo ============================================
git status --short
if %errorlevel% neq 0 (
    echo [FAIL] git status error
    pause
    exit /b 1
)

git diff-index --quiet HEAD --
if %errorlevel% equ 0 (
    echo [SKIP] No changes to push
    pause
    exit /b 0
)

set /p MSG="Commit message (Enter for default): "
if "%MSG%"=="" set MSG=update blog

echo.
echo Committing: %MSG%
git add -A
git commit -m "%MSG%"

echo.
echo Pushing...
git push origin main

if %errorlevel% equ 0 (
    echo.
    echo [OK] Pushed!
    echo Check build: https://github.com/tsinghong1984/tsinghong1984.github.io/actions
) else (
    echo.
    echo [FAIL] Network error, try later: git push origin main
)

echo.
pause
