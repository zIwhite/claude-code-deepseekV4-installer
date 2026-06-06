@echo off
chcp 936 >nul
title Claude Code + DeepSeek 一键安装（含Git自动安装）

echo ================================================
echo    Claude Code + DeepSeek 一键安装脚本
echo ================================================
echo.

:: ========== 1. 检测 Node.js ==========
echo [1/6] 检测 Node.js 环境...
where node >nul 2>nul
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do echo 已检测到 Node.js %%i
    goto :check_git
)

echo 未检测到 Node.js，即将自动下载安装 Node.js v20.11.0...
echo 请稍候，不要关闭窗口...

set "NODE_URL=https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi"
set "NODE_INSTALLER=%TEMP%\node-v20.11.0-x64.msi"

echo 正在下载 Node.js 安装包...
curl.exe -L --output "%NODE_INSTALLER%" "%NODE_URL%" 2>nul
if errorlevel 1 (
    echo curl 下载失败，尝试使用 PowerShell...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%NODE_URL%' -OutFile '%NODE_INSTALLER%'}"
)

if not exist "%NODE_INSTALLER%" (
    echo 错误：下载失败，请检查网络。
    pause
    exit /b 1
)

echo 下载完成，正在安装 Node.js（请稍等，约1-2分钟）...
start /wait msiexec /i "%NODE_INSTALLER%" /quiet /norestart /passive
timeout /t 3 /nobreak >nul

echo 正在刷新环境变量...
call :RefreshEnv

where node >nul 2>nul
if errorlevel 1 (
    if exist "%ProgramFiles%\nodejs\node.exe" (
        set "PATH=%ProgramFiles%\nodejs;%PATH%"
    ) else if exist "%ProgramFiles(x86)%\nodejs\node.exe" (
        set "PATH=%ProgramFiles(x86)%\nodejs;%PATH%"
    ) else (
        echo 错误：无法找到 Node.js 安装位置，请手动安装。
        pause
        exit /b 1
    )
)

echo Node.js 安装成功！
node -v
echo.

:: ========== 2. 检测并自动安装 Git ==========
:check_git
echo [2/6] 检测 Git 环境...
where git >nul 2>nul
if %errorlevel% equ 0 (
    echo 已检测到 Git
    goto :install_claude
)

echo 未检测到 Git，即将自动下载安装 Git for Windows...
echo 请稍候...

set "GIT_URL=https://registry.npmmirror.com/-/binary/git-for-windows/v2.45.1.windows.1/Git-2.45.1-64-bit.exe"
set "GIT_INSTALLER=%TEMP%\Git-2.45.1-64-bit.exe"

echo 正在下载 Git 安装包...
curl.exe -L --output "%GIT_INSTALLER%" "%GIT_URL%" 2>nul
if errorlevel 1 (
    echo curl 下载失败，尝试使用 PowerShell...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%GIT_URL%' -OutFile '%GIT_INSTALLER%'}"
)

if not exist "%GIT_INSTALLER%" (
    echo 错误：Git 下载失败，请检查网络。
    echo 你可以手动从 https://git-scm.com/downloads 下载安装。
    pause
    exit /b 1
)

echo 下载完成，正在静默安装 Git（约1分钟）...
:: 静默安装参数：/VERYSILENT 完全静默，/NORESTART 不重启
"%GIT_INSTALLER%" /VERYSILENT /NORESTART

:: 等待安装完成
timeout /t 8 /nobreak >nul

:: 刷新环境变量
call :RefreshEnv

:: 再次验证
where git >nul 2>nul
if errorlevel 1 (
    echo 自动安装后仍未检测到 Git，可能静默安装被拦截。
    echo 请手动运行 %GIT_INSTALLER% 完成安装（使用默认选项即可）。
    echo 按任意键后会打开该安装包...
    pause
    start "" "%GIT_INSTALLER%"
    echo 请手动完成 Git 安装（一路 Next 即可），完成后按任意键继续。
    pause
)

echo Git 安装验证通过！
git --version
echo.

:: ========== 3. 安装 Claude Code ==========
:install_claude
echo [3/6] 正在安装 Claude Code...
echo 请稍候，安装过程可能需要1-2分钟...

set npm_config_color=0
call npm install -g @anthropic-ai/claude-code 2>&1
set INSTALL_RESULT=%errorlevel%

if %INSTALL_RESULT% neq 0 (
    echo 安装失败，错误码：%INSTALL_RESULT%
    echo 请检查网络后重试，或手动执行：npm install -g @anthropic-ai/claude-code
    pause
    exit /b 1
)

echo Claude Code 安装成功！
echo.

:: ========== 4. 配置 DeepSeek API Key ==========
echo [4/6] 配置 DeepSeek API 连接...
echo.
echo 请登录 https://platform.deepseek.com/api_keys 获取 API Key
set /p "API_KEY=请输入 API Key（直接回车跳过）: "
if not "%API_KEY%"=="" (
    setx ANTHROPIC_API_KEY "%API_KEY%" >nul
    setx ANTHROPIC_BASE_URL "https://api.deepseek.com" >nul
    echo API Key 已保存。
) else (
    echo 未输入 API Key，可稍后手动设置。
)
echo.


:: ========== 5. 配置 Git Bash 终端支持 ==========
echo [5/6] 正在配置 Git Bash 终端兼容性...

:: Claude Code 是原生 Windows exe，在 Git Bash (MinTTY) 下
:: 无法正确检测 TTY，导致报错 "no stdin data received"。
:: 使用 winpty (Git 自带) 桥接即可解决。
set "BASH_RC=%USERPROFILE%\.bashrc"
set "BASH_PROFILE=%USERPROFILE%\.bash_profile"
set "ALIAS_LINE=alias claude='winpty \claude'"
set "ALIAS_EXISTS=0"

if exist "%BASH_RC%" (
    findstr /c:"alias claude=" "%BASH_RC%" >nul 2>nul
    if not errorlevel 1 set "ALIAS_EXISTS=1"
)

if "%ALIAS_EXISTS%"=="0" (
    echo %ALIAS_LINE% >> "%BASH_RC%"
    echo Git Bash 已配置完成（已添加 winpty 别名）。
) else (
    echo Git Bash 别名已存在，跳过。
)

:: 确保 .bash_profile 能加载 .bashrc（部分 Git Bash 需要）
if not exist "%BASH_PROFILE%" (
    echo test -f ~/.bashrc ^&^& source ~/.bashrc > "%BASH_PROFILE%"
)

echo.
:: ========== 6. 完成 ==========
echo [6/6] 安装完成！
echo.
echo ================================================
echo 使用方式：在任意文件夹右键 → Git Bash Here → 输入 claude（首次需新开 Git Bash 窗口加载配置）
echo ================================================
echo 提示：如果右键没有 Git Bash Here，请重启电脑或注销重新登录。
pause
exit /b

:: ========== 刷新环境变量的函数 ==========
:RefreshEnv
    for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set "SysPath=%%b"
    for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "UserPath=%%b"
    set "PATH=%SysPath%;%UserPath%"
    goto :eof