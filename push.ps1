$ErrorActionPreference = "Continue"
Set-Location "$PSScriptRoot"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  博客推送工具" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  文件夹即标签: 把文章放到 _posts/对应文件夹/ 自动打标签"
Write-Host "  标签列表: 网络技术  无线通信  里德堡原子  AI大模型"
Write-Host ""

# 检查是否有改动
$status = git status --short 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[失败] git status 出错" -ForegroundColor Red
    Read-Host "按回车退出"
    exit 1
}

# 如果没有改动就退出
git diff-index --quiet HEAD -- 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[跳过] 没有新改动，无需推送" -ForegroundColor Yellow
    Read-Host "按回车退出"
    exit 0
}

# 有改动，询问提交信息
$msg = Read-Host "输入提交描述（直接回车使用默认）"
if ([string]::IsNullOrWhiteSpace($msg)) {
    $msg = "更新博客内容"
}

Write-Host ""
Write-Host "正在提交: $msg"
git add -A
git commit -m "$msg"

Write-Host ""
Write-Host "正在推送..."
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[成功] 推送完成！" -ForegroundColor Green
    Write-Host "查看构建状态: https://github.com/tsinghong1984/tsinghong1984.github.io/actions"
} else {
    Write-Host ""
    Write-Host "[失败] 推送失败，请检查网络" -ForegroundColor Red
    Write-Host "稍后可手动执行: git push origin main"
}

Write-Host ""
Read-Host "按回车退出"
