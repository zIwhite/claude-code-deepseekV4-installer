@echo off
chcp 936 >nul
title 最终安全卸载 - 仅提示和打开卸载界面

echo ================================================
echo   最终安全卸载脚本 - 绝不会闪退
echo ================================================
echo 本脚本将执行：
echo   1. 尝试卸载 Claude Code（如果失败会跳过）
echo   2. 删除 DeepSeek 环境变量
echo   3. 打开控制面板让您手动卸载 Node.js 和 Git
echo.
echo 请确保以管理员身份运行。
echo ================================================
set /p "confirm=输入 Y 并回车继续: "
if /i not "%confirm%"=="Y" exit /b

echo.
echo [1/3] 尝试卸载 Claude Code...
call npm uninstall -g @anthropic-ai/claude-code 2>nul
echo 完成（如果出现错误请忽略）

echo [2/3] 删除 DeepSeek 环境变量...
reg delete "HKCU\Environment" /v "ANTHROPIC_API_KEY" /f >nul 2>nul
reg delete "HKCU\Environment" /v "ANTHROPIC_BASE_URL" /f >nul 2>nul
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "ANTHROPIC_API_KEY" /f >nul 2>nul
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "ANTHROPIC_BASE_URL" /f >nul 2>nul
echo 已删除

echo [3/3] 正在打开控制面板的“卸载程序”...
echo 请在弹出的窗口中，手动卸载 Node.js 和 Git。
start control appwiz.cpl

echo.
echo ================================================
echo 脚本完成。请手动卸载 Node.js 和 Git，
echo 然后删除残留文件夹（参考上面的说明）。
echo ================================================
pause
exit /b