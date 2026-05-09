# sharecrm-cli-skills

`sharecrm-cli-skills` 是一个面向 `sharecrm` CLI 的技能仓库，用来为智能代理提供可复用的纷享销客产品操作能力。目前仓库的核心内容是 `sharecrm` 主技能，以及围绕认证、安装、对象 API 名称等配套参考文档。

## Quick Start

如果你只想先把 `sharecrm` skill 装起来，优先使用下面任一方式：

```bash
npx skills add emengs/sharecrm-cli-skills --skill sharecrm -g -y
```

macOS / Linux：

```bash
curl -fsSL https://raw.githubusercontent.com/emengs/sharecrm-cli-skills/main/scripts/install.sh | sh
```

Windows PowerShell：

```powershell
irm https://raw.githubusercontent.com/emengs/sharecrm-cli-skills/main/scripts/install.ps1 | iex
```

注意：`https://github.com/.../scripts/install.sh` 是 GitHub 页面地址，不是
脚本原始内容地址；用于 `curl | sh` 时必须使用 `raw.githubusercontent.com`
形式的 URL。PowerShell 下的 `irm ... | iex` 也同样必须使用 raw URL。

如果你要指定 agent 安装目标，可以使用：

```bash
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent claude-code -g -y
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent codex -g -y
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent gemini-cli -g -y
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent openclaw -g -y
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent cursor -g -y
```

安装完成后：

1. 重启客户端或新开会话
2. 确认目标 skills 目录下存在 `sharecrm/SKILL.md`
3. 直接发起一个 `sharecrm` 相关请求，确认 agent 能读取该 skill

脚本安装器的完整参数、默认目录和测试方式见
[scripts/README.md](/Users/zengwenwen/Documents/github/sharecrm-cli-skills/scripts/README.md)。

## 项目目标

- 为代理提供统一的 `sharecrm` CLI 使用约束
- 将纷享销客产品能力按技能方式沉淀，减少重复提示词
- 把高频操作的前置条件、风险控制和参考资料集中管理

## 当前内容

当前仓库主要包含一个主技能：

- `skills/sharecrm/SKILL.md`

该技能用于指导代理通过 `sharecrm` 命令操作纷享销客产品能力，覆盖以下典型场景：

- CRM 对象与数据查询、创建、维护
- 知识、方案、企业、销售、营销、服务等产品能力调用
- 文件、审批、流程、日程、标签、用户组等通用产品操作
- `sharecrm` 登录授权、权限检查和错误处理约束

## 目录结构

```text
.
├── README.md
└── skills
    └── sharecrm
        ├── SKILL.md
        └── references
            ├── objectApiNames.md
            ├── shareCrmInstall.md
            └── userAuth.md
```

各文件职责如下：

- `skills/sharecrm/SKILL.md`：主技能定义，包含适用场景、产品映射、执行规则、危险操作确认和错误处理
- `skills/sharecrm/references/shareCrmInstall.md`：`sharecrm` CLI 安装说明
- `skills/sharecrm/references/userAuth.md`：认证、会话管理与登录失效恢复流程
- `skills/sharecrm/references/objectApiNames.md`：常见 CRM 对象名称与 `apiName` 对照表

## 使用前提

在使用本仓库中的技能前，建议先确认以下环境：

1. 已安装 `sharecrm` CLI
2. 本机可直接执行 `sharecrm -V`
3. 已完成 `sharecrm auth login` 登录授权
4. 当前账号具备对应产品与数据的访问权限

如未安装 `sharecrm`，可参考：

- [skills/sharecrm/references/shareCrmInstall.md](skills/sharecrm/references/shareCrmInstall.md)

如需查看认证与会话规则，可参考：

- [skills/sharecrm/references/userAuth.md](skills/sharecrm/references/userAuth.md)

## 安装与接入指南

这一节给出更完整的安装方式，覆盖 `npx` 安装、手动复制、
符号链接开发模式，以及接入不同 agent 平台时的目录选择建议。

## 脚本安装器说明

仓库内置了两套一键安装脚本：

- macOS / Linux：[scripts/install.sh](/Users/zengwenwen/Documents/github/sharecrm-cli-skills/scripts/install.sh)
- Windows PowerShell：[scripts/install.ps1](/Users/zengwenwen/Documents/github/sharecrm-cli-skills/scripts/install.ps1)

如果你只想查看安装脚本本身的用法，可以直接看
[scripts/README.md](/Users/zengwenwen/Documents/github/sharecrm-cli-skills/scripts/README.md)。

它们的目标是一致的：

- 自动下载当前仓库中的 `skills/sharecrm`
- 安装到合适的 skills 目录
- 如果目标目录里已存在旧版本，先备份再替换
- 安装完成后输出下一步验证提示

详细参数、默认目录、备份行为和测试命令统一放在
[scripts/README.md](/Users/zengwenwen/Documents/github/sharecrm-cli-skills/scripts/README.md)。

### 兼容性总览

不同平台对 `SKILL.md` 的支持方式并不完全一致：

| 平台 | 支持方式 | 推荐目录 | 备注 |
| --- | --- | --- | --- |
| Claude Code | 原生 Agent Skills | `~/.claude/skills` / `.claude/skills` | 官方原生支持 |
| Gemini CLI | 原生 skills | `.gemini/skills`，全局常见为 `~/.gemini/skills` | 可用 `/skills reload` 重新加载 |
| OpenClaw | 原生 AgentSkills 兼容 | `~/.openclaw/skills` / `~/.agents/skills` / `<workspace>/skills` | 支持多级优先级 |
| Codex 兼容运行时 | 取决于宿主实现 | `~/.agents/skills` / `.agents/skills` / `~/.codex/skills` | `skills` CLI 已支持 Codex 目标路径 |
| Cursor | `skills` CLI 兼容，原生以 Rules 为主 | `~/.cursor/skills` 或 `.agents/skills`；原生规则用 `.cursor/rules` | 手动接入时更推荐 Rules |

### 方式一：使用 `npx` 安装

如果你的环境已经接入 `skills` CLI，可以直接从 GitHub 安装当前
skill。官方 CLI 当前更推荐显式写出仓库和 skill 名：

```bash
npx skills add emengs/sharecrm-cli-skills --skill sharecrm -g -y
```

参数说明：

- `emengs/sharecrm-cli-skills`：GitHub 仓库
- `--skill sharecrm`：安装仓库中的 `skills/sharecrm`
- `-g`：安装到当前用户的全局技能目录
- `-y`：跳过交互确认

如果只想先检查本机是否可用，可以执行：

```bash
npx skills --help
```

如果你要明确安装到某个 agent，可以加 `--agent`：

```bash
# Claude Code
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent claude-code -g -y

# Codex
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent codex -g -y

# Gemini CLI
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent gemini-cli -g -y

# OpenClaw
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent openclaw -g -y

# Cursor
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent cursor -g -y
```

如果你想本地开发并持续修改 skill，`npx` 安装通常不如手动软链接
方便，因为手动方式可以让目标平台直接读取当前仓库中的最新文件。

### 方式二：本地手动安装

先获取仓库：

```bash
git clone https://github.com/emengs/sharecrm-cli-skills.git
cd sharecrm-cli-skills
```

接下来可以选择“复制”或“软链接”两种方式。

复制适合稳定使用：

```bash
cp -R skills/sharecrm <目标技能目录>/sharecrm
```

软链接适合本地调试和持续迭代：

```bash
ln -s "$(pwd)/skills/sharecrm" <目标技能目录>/sharecrm
```

最终都应满足下面的目录结构：

```text
<skills-root>/
└── sharecrm/
    ├── SKILL.md
    └── references/
```

### Claude Code

Claude Code 官方支持两类 skills 目录：

- 用户级目录：`~/.claude/skills`
- 项目级目录：`.claude/skills`

安装到用户级目录：

```bash
mkdir -p ~/.claude/skills
ln -s "$(pwd)/skills/sharecrm" ~/.claude/skills/sharecrm
```

安装到当前项目目录：

```bash
mkdir -p .claude/skills
ln -s "$(pwd)/skills/sharecrm" .claude/skills/sharecrm
```

如果不想使用软链接，把 `ln -s` 换成 `cp -R` 即可。修改完成后，
重启 Claude Code 或开启新会话加载新 skill。

### Gemini CLI

Gemini CLI 当前已经内置 skills 机制，并支持重新加载已发现的
skills。对于手动安装，保守做法是优先使用项目级 `.gemini/skills`
目录：

```bash
mkdir -p .gemini/skills
ln -s "$(pwd)/skills/sharecrm" .gemini/skills/sharecrm
```

如果 Gemini CLI 已经在运行，可以在交互会话里执行：

```text
/skills reload
```

如果你更倾向于集中管理多个可复用 skill，`skills` CLI 生态常见的
全局目录是 `~/.gemini/skills`。但手动安装时，优先使用项目级
`.gemini/skills` 仍然是更稳妥的方案。

### OpenClaw

OpenClaw 原生支持 AgentSkills 兼容目录，并且有明确的加载优先级。
这个仓库可以直接挂到下列任一位置：

- `~/.openclaw/skills`
- `~/.agents/skills`
- `<workspace>/.agents/skills`
- `<workspace>/skills`

推荐安装到用户级目录：

```bash
mkdir -p ~/.openclaw/skills
ln -s "$(pwd)/skills/sharecrm" ~/.openclaw/skills/sharecrm
```

如果你想让当前工作区优先覆盖全局版本，可以安装到工作区目录：

```bash
mkdir -p ./skills
ln -s "$(pwd)/skills/sharecrm" ./skills/sharecrm
```

如果你已经有一套基于 `.agents/skills` 的公共目录，也可以这样放：

```bash
mkdir -p ~/.agents/skills
ln -s "$(pwd)/skills/sharecrm" ~/.agents/skills/sharecrm
```

### Codex / Codex 兼容运行时

OpenAI 官方公开文档目前更强调 Codex 的 agent 能力本身，而通用
`SKILL.md` 目录更多来自开放 skills 生态的兼容约定。因此这里建议按
“Codex 兼容运行时”来处理。

对当前仓库，推荐的兼容目录有：

- `~/.agents/skills`
- `.agents/skills`
- `~/.codex/skills`，如果你的宿主明确采用这一路径

用户级安装：

```bash
mkdir -p ~/.agents/skills
ln -s "$(pwd)/skills/sharecrm" ~/.agents/skills/sharecrm
```

项目级安装：

```bash
mkdir -p .agents/skills
ln -s "$(pwd)/skills/sharecrm" .agents/skills/sharecrm
```

某些本地 Codex 封装使用 `~/.codex/skills` 时，可以改成：

```bash
mkdir -p ~/.codex/skills
ln -s "$(pwd)/skills/sharecrm" ~/.codex/skills/sharecrm
```

如果你不确定宿主加载哪个目录，优先检查宿主配置或文档，不要同时把
同一个 skill 复制到多个目录里，以免后续更新时出现版本漂移。

### Cursor

Cursor 当前官方主线仍然是 Rules，而不是把 `SKILL.md` 作为主要
文档入口。不过在 `skills` CLI 生态里，Cursor 已经有兼容的 skills
安装路径。因此，Cursor 有两种接入方式：

1. 通过 `npx skills add ... --agent cursor` 自动安装
2. 手动转成 Cursor Rules

如果你不想依赖 `skills` CLI，推荐两种手动适配方式：

1. 把关键规则提炼到 `.cursor/rules/sharecrm.mdc`
2. 把总说明写入项目根目录 `AGENTS.md`

手动规则目录：

```bash
mkdir -p .cursor/rules
```

一个最小可用的规则文件可以命名为
`.cursor/rules/sharecrm.mdc`，并把 `skills/sharecrm/SKILL.md`
里的核心约束迁移进去，例如：

```md
---
description: Use when operating ShareCRM through the sharecrm CLI.
globs:
  alwaysApply: false
---

- Only use the `sharecrm` CLI for ShareCRM operations.
- Never invent record IDs, object API names, or field names.
- Confirm high-impact write operations before executing them.
- Read local reference docs under `skills/sharecrm/references/` when needed.
```

如果你想保留更完整的上下文，也可以在 `AGENTS.md` 里说明：

- `sharecrm` 相关任务优先参考 `skills/sharecrm/SKILL.md`
- 认证流程参考 `skills/sharecrm/references/userAuth.md`
- 安装流程参考 `skills/sharecrm/references/shareCrmInstall.md`

### 安装后验证

完成安装后，建议做一次最小验证：

1. 检查目标目录下是否存在 `sharecrm/SKILL.md`
2. 确认 `references/` 子目录也一并存在
3. 重启客户端，或在支持的平台里执行 reload 命令
4. 发送一个 `sharecrm` 相关请求，确认 agent 能引用该 skill

不同平台可参考的验证动作：

- Claude Code：新开会话后询问可用 skills
- Gemini CLI：执行 `/skills reload`
- OpenClaw：开启新 session，检查 skill 是否被发现
- Cursor：检查 `.cursor/rules` 或 `AGENTS.md` 是否被项目加载

### 目录选择建议

- 需要个人复用时，优先安装到用户级目录
- 需要团队共享时，优先安装到项目级目录并纳入 git
- 需要持续修改时，优先使用软链接而不是复制
- 遇到多平台共存时，优先选择每个平台的原生目录，不混用

## 发布与分发

如果你希望其他人能直接安装这个 skill，建议把分发链路分成三层：

1. GitHub：源码和版本管理的单一事实来源
2. `skills.sh` / `npx skills`：跨 agent 生态的安装入口
3. ClawHub：OpenClaw 生态下的技能注册中心

### GitHub：作为源代码主仓库

当前仓库已经适合作为公开分发源：

- 仓库地址：`https://github.com/emengs/sharecrm-cli-skills`
- skill 目录：`skills/sharecrm`
- 入口文件：`skills/sharecrm/SKILL.md`

建议保持以下发布习惯：

- 每次对外发布前更新 `SKILL.md` frontmatter 中的 `version`
- 为重大更新打 git tag，便于追踪分发版本
- 在 `README.md` 中保持安装命令和目录结构说明最新
- 把新增参考文档一并纳入仓库，而不是只更新主 skill

一个最小发布流程可以是：

```bash
git add .
git commit -m "release: update sharecrm skill"
git tag v1.1.0
git push origin main --tags
```

如果你不想打 tag，至少应保证默认分支上的 `README.md` 和
`skills/sharecrm` 是可直接安装的状态。

### skills.sh：跨平台安装入口

`skills.sh` 背后的 `skills` CLI 可以直接从 GitHub 安装 skill，因此对
这个仓库来说，GitHub 本身就是分发源。

安装命令示例：

```bash
npx skills add emengs/sharecrm-cli-skills --skill sharecrm -g -y
```

如果你希望用户安装到特定 agent，可以显式指定：

```bash
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent claude-code -g -y
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent codex -g -y
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent gemini-cli -g -y
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent openclaw -g -y
npx skills add emengs/sharecrm-cli-skills --skill sharecrm --agent cursor -g -y
```

`skills.sh` 的一个关键点是：skill 不需要单独“上传”到一个独立仓库。
根据官方 FAQ，公开 GitHub skill 会随着用户通过 `npx skills add` 的
安装记录进入其排名和目录体系。实际效果上：

- GitHub 决定内容来源
- `npx skills` 负责安装
- `skills.sh` 负责发现、展示和安装统计

为了让这个仓库更适合被 `skills.sh` 生态消费，建议：

- 保持 `README.md` 里有清晰的安装命令
- 保持 `SKILL.md` 的 `name`、`description`、`version` 完整
- skill 名称尽量稳定，避免频繁重命名目录
- 仓库保持公开，避免依赖私有附件或外部未公开文件

### ClawHub：发布到 OpenClaw 注册中心

如果你希望 OpenClaw 用户能直接通过 `openclaw skills install` 或
`clawhub install` 获取这个 skill，就需要额外发布到 ClawHub。

ClawHub 官方定位是 OpenClaw 的公共 skills registry，支持：

- 搜索 skill
- 安装 skill
- 发布新 skill 或新版本
- 用 `sync` 扫描本地 skills 并同步到注册中心

首次发布前，先登录：

```bash
clawhub login
```

发布当前 skill 的一个最小示例：

```bash
clawhub publish ./skills/sharecrm \
  --slug sharecrm \
  --name "sharecrm" \
  --version 1.1.0 \
  --tags latest
```

如果后续想批量同步本地 workspace 中的 skills，可以使用：

```bash
clawhub sync --all
```

发布后，OpenClaw 用户就可以通过下面的方式安装：

```bash
openclaw skills install sharecrm
```

或者：

```bash
clawhub install sharecrm
```

如果你打算长期维护 ClawHub 版本，建议：

- GitHub 版本号和 ClawHub `--version` 保持一致
- 每次发布都带上 changelog 或至少保证 commit/tag 可追溯
- 先在本地验证目录结构，再执行 publish
- 避免直接覆盖一个内容变化很大的旧版本 tag

### 推荐分发策略

对这个仓库，我建议采用下面的顺序：

1. 以 GitHub 仓库作为唯一源码源头
2. 通过 `npx skills add` 覆盖 Claude Code、Codex、Gemini CLI、Cursor 等跨平台安装
3. 如果你确实面向 OpenClaw 用户群，再额外发布到 ClawHub

这样可以减少重复维护成本，同时保留 OpenClaw 原生分发渠道。

### 发布前检查清单

发布前建议至少检查这些点：

1. `skills/sharecrm/SKILL.md` 存在且 frontmatter 合法
2. `references/` 中被 skill 引用的文件都已提交
3. `README.md` 中的安装命令仍然可用
4. 版本号、git tag、ClawHub 发布版本没有明显冲突
5. 本地至少完成一次手动安装或 `npx skills add` 安装验证

## 技能设计原则

`sharecrm` 主技能当前体现了几个核心约束：

- 只通过 `sharecrm` 命令操作纷享销客能力，不绕过 CLI
- 不猜测对象 ID、字段名或参数，必须基于命令结果和文档确认
- 对创建等高影响操作，必须先获得用户明确确认
- 遇到认证失败或权限问题时，按既定流程恢复，不伪造执行结果

这些规则的目标是让代理在执行真实业务操作时更安全、更稳定，也更容易复用。

## 适合扩展的方向

当前仓库已经具备主技能骨架，后续可以继续补充：

- 按产品拆分更细粒度的子技能
- 为 `data`、`approval`、`file`、`work` 等命令增加独立参考文档
- 补充更完整的示例命令、输入输出样例和故障排查说明
- 为不同代理平台补充安装或挂载说明

## 维护建议

更新技能内容时，建议保持以下约定：

- 技能文件聚焦“何时触发 + 如何执行 + 哪些不能做”
- 参考文档聚焦命令格式、认证流程、对象清单和示例
- 新增产品能力时，优先补文档，再扩展技能中的决策树与规则
