# Scripts

本目录存放 `sharecrm` skill 的安装器与轻量自测脚本。

## 文件列表

- [install.sh](/Users/zengwenwen/Documents/github/sharecrm-cli-skills/scripts/install.sh)：macOS / Linux 一键安装脚本
- [install.ps1](/Users/zengwenwen/Documents/github/sharecrm-cli-skills/scripts/install.ps1)：Windows PowerShell 一键安装脚本
- [test-install.sh](/Users/zengwenwen/Documents/github/sharecrm-cli-skills/scripts/test-install.sh)：`install.sh` 轻量自测
- [test-install.ps1](/Users/zengwenwen/Documents/github/sharecrm-cli-skills/scripts/test-install.ps1)：`install.ps1` 轻量自测

## 快速安装

macOS / Linux：

```bash
curl -fsSL https://raw.githubusercontent.com/emengs/sharecrm-cli-skills/main/scripts/install.sh | sh
```

Windows PowerShell：

```powershell
irm https://raw.githubusercontent.com/emengs/sharecrm-cli-skills/main/scripts/install.ps1 | iex
```

## 传参方式

`install.sh` 通过 `sh -s -- ...` 传参：

```bash
curl -fsSL https://raw.githubusercontent.com/emengs/sharecrm-cli-skills/main/scripts/install.sh | sh -s -- --agent claude-code
curl -fsSL https://raw.githubusercontent.com/emengs/sharecrm-cli-skills/main/scripts/install.sh | sh -s -- --dir "$HOME/.claude/skills"
curl -fsSL https://raw.githubusercontent.com/emengs/sharecrm-cli-skills/main/scripts/install.sh | sh -s -- --ref main
```

`install.ps1` 通过 scriptblock 调用传参：

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/emengs/sharecrm-cli-skills/main/scripts/install.ps1))) -Agent claude-code
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/emengs/sharecrm-cli-skills/main/scripts/install.ps1))) -Dir "$HOME\.claude\skills"
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/emengs/sharecrm-cli-skills/main/scripts/install.ps1))) -Ref main
```

## 支持参数

`install.sh`：

- `--agent <name>`：`claude-code`、`codex`、`gemini-cli`、`openclaw`、`cursor`
- `--dir <path>`：自定义安装目录
- `--ref <git-ref>`：指定分支、tag 或 commit
- `--help`：查看帮助

`install.ps1`：

- `-Agent <name>`：`claude-code`、`codex`、`gemini-cli`、`openclaw`、`cursor`
- `-Dir <path>`：自定义安装目录
- `-Ref <git-ref>`：指定分支、tag 或 commit
- `-Help`：查看帮助

两个脚本都不允许同时传 agent 和 dir。

## 默认安装目录

不传参数时，两套脚本都会按下面的顺序自动检测：

1. `~/.claude/skills`
2. `~/.gemini/skills`
3. `~/.openclaw/skills`
4. `~/.cursor/skills`
5. `~/.codex/skills`
6. 若以上都不存在，则回退到 `~/.agents/skills`

## 安装行为

脚本默认会：

- 从 GitHub 下载仓库归档
- 提取 `skills/sharecrm`
- 安装到 `<skills-root>/sharecrm`
- 如果已存在旧版本，先备份成 `sharecrm.backup.<timestamp>`

## 依赖与限制

`install.sh`：

- 仅支持 macOS / Linux
- 需要 `curl`、`tar`、`mktemp`、`cp`、`mv`

`install.ps1`：

- 面向 Windows PowerShell / PowerShell 7
- 依赖 `Invoke-WebRequest`
- 解压归档时依赖系统可用的 `tar`

`curl | sh` 和 `irm | iex` 都必须使用 `raw.githubusercontent.com` 的原始文件地址。

## 测试

macOS / Linux：

```bash
sh scripts/test-install.sh
```

Windows PowerShell：

```powershell
pwsh -File .\scripts\test-install.ps1
```

当前仓库里的 shell 自测已经可以在本地运行；PowerShell 自测需要本机安装 `pwsh` 或 `powershell`。
