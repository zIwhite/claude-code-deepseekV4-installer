# Claude Code + DeepSeek 一键安装包（Windows）

> 一键安装 Claude Code，自动配置 DeepSeek API，附带 Node.js 和 Git 自动安装与清理脚本。

---

## 📦 文件

| 文件 | 作用 |
|------|------|
| `安装ClaudeCode.bat` | 一键安装（管理员运行） |
| `清理ClaudeCode.bat` | 一键卸载（管理员运行） |

---

## ⚙️ 安装

1. 右键 `安装ClaudeCode.bat` → **以管理员身份运行**
2. 输入你的 [DeepSeek API Key](https://platform.deepseek.com/api_keys)
3. 安装完成后，在目标文件夹右键 → `Git Bash Here` → 输入 `claude` 启动

---

## 🧹 卸载

1. 右键 `清理ClaudeCode.bat` → **以管理员身份运行**
2. 按提示手动卸载 Node.js 和 Git（控制面板）
3. 删除残留文件夹（可选），重启电脑

---

## 💡 小贴士

- 在**空文件夹**启动 `claude` 可省 Token
- 输入 `/clear` 清空历史，不扣费
- 费用按 DeepSeek API 计费，远低于官方 Claude

---

## ❓ 常见问题

| 问题 | 解决方法 |
|------|----------|
| 右键没有 Git Bash Here | 重启电脑 |
| 安装闪退 | 以管理员身份运行，暂时关闭杀毒软件 |
| 如何确认成功 | `claude --version` 显示版本号 |
