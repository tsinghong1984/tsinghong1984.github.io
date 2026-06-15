@echo off
chcp 65001 >nul
cd /d D:\yuproject\graduate_life\AI\git\tsinghong\tsinghong1984.github.io

echo.
echo ============================================
echo   博客推送工具
echo ============================================
echo.
echo   可用标签: 无线通信  里德堡原子  网络技术  AI大模型
echo   文章 front matter 里加: tags: [标签名]
echo.

:: 检查是否有改动
git status --short
if %errorlevel% neq 0 (
    echo [失败] git status 出错
    pause
    exit /b 1
)

:: 如果没有改动就退出
git diff-index --quiet HEAD --
if %errorlevel% equ 0 (
    echo [跳过] 没有新改动，无需推送
    pause
    exit /b 0
)

:: 有改动，询问提交信息
set /p MSG="输入提交描述（直接回车使用默认）: "
if "%MSG%"=="" set MSG=更新博客内容

echo.
echo 正在提交: %MSG%
git add -A
git commit -m "%MSG%"

echo.
echo 正在推送...
git push origin main

if %errorlevel% equ 0 (
    echo.
    echo [成功] 推送完成！
    echo 查看构建状态: https://github.com/tsinghong1984/tsinghong1984.github.io/actions
) else (
    echo.
    echo [失败] 推送失败，请检查网络
    echo 稍后可手动执行: git push origin main
)

echo.
pause
