param(
    [string]$Agent,
    [string]$Dir,
    [string]$Ref = "main",
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoOwner = if ($env:REPO_OWNER) { $env:REPO_OWNER } else { 'emengs' }
$RepoName = if ($env:REPO_NAME) { $env:REPO_NAME } else { 'sharecrm-cli-skills' }
$SkillName = 'sharecrm'
$RawInstallUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Ref/scripts/install.ps1"

function Show-Usage {
    @"
Install the $SkillName skill on Windows.

Usage:
  irm $RawInstallUrl | iex

Advanced usage:
  & ([scriptblock]::Create((irm $RawInstallUrl))) -Agent claude-code
  & ([scriptblock]::Create((irm $RawInstallUrl))) -Dir '$env:USERPROFILE\.claude\skills'

Options:
  -Agent <name>  Supported values: claude-code, codex, gemini-cli, openclaw, cursor
  -Dir <path>    Install into a custom skills directory.
  -Ref <git-ref> Install from a specific GitHub ref. Defaults to: $Ref
  -Help          Show this help message.
"@
}

function Fail([string]$Message) {
    throw $Message
}

function Get-UserHome {
    if ($env:USERPROFILE) {
        return $env:USERPROFILE
    }

    if ($HOME) {
        return $HOME
    }

    Fail 'Unable to determine the current user home directory.'
}

function Resolve-AgentDir([string]$AgentName) {
    $homeDir = Get-UserHome

    switch ($AgentName) {
        'claude-code' { return (Join-Path $homeDir '.claude\skills') }
        'codex' { return (Join-Path $homeDir '.agents\skills') }
        'gemini-cli' { return (Join-Path $homeDir '.gemini\skills') }
        'openclaw' { return (Join-Path $homeDir '.openclaw\skills') }
        'cursor' { return (Join-Path $homeDir '.cursor\skills') }
        default { Fail "Unsupported agent: $AgentName" }
    }
}

function Detect-DefaultDir {
    $homeDir = Get-UserHome

    $claudeDir = Join-Path $homeDir '.claude'
    $geminiDir = Join-Path $homeDir '.gemini'
    $openClawDir = Join-Path $homeDir '.openclaw'
    $cursorDir = Join-Path $homeDir '.cursor'
    $codexDir = Join-Path $homeDir '.codex'

    if (Test-Path -LiteralPath $claudeDir) {
        return (Join-Path $claudeDir 'skills')
    }

    if (Test-Path -LiteralPath $geminiDir) {
        return (Join-Path $geminiDir 'skills')
    }

    if (Test-Path -LiteralPath $openClawDir) {
        return (Join-Path $openClawDir 'skills')
    }

    if (Test-Path -LiteralPath $cursorDir) {
        return (Join-Path $cursorDir 'skills')
    }

    if (Test-Path -LiteralPath $codexDir) {
        return (Join-Path $codexDir 'skills')
    }

    return (Join-Path $homeDir '.agents\skills')
}

function Get-SkillSourceDir([string]$WorkDir) {
    if ($env:SHARECRM_SKILL_SOURCE_DIR) {
        if (-not (Test-Path -LiteralPath $env:SHARECRM_SKILL_SOURCE_DIR)) {
            Fail "SHARECRM_SKILL_SOURCE_DIR does not exist: $env:SHARECRM_SKILL_SOURCE_DIR"
        }

        return $env:SHARECRM_SKILL_SOURCE_DIR
    }

    $archiveUrl = "https://codeload.github.com/$RepoOwner/$RepoName/tar.gz/$Ref"
    $archivePath = Join-Path $WorkDir 'repo.tar.gz'
    $extractDir = Join-Path $WorkDir 'extracted'
    $repoDir = Join-Path $extractDir "$RepoName-$Ref"
    $skillSourceDir = Join-Path $repoDir "skills\$SkillName"

    Write-Host "Downloading $RepoOwner/$RepoName@$Ref ..."
    Invoke-WebRequest -Uri $archiveUrl -OutFile $archivePath

    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
    tar -xzf $archivePath -C $extractDir

    if (-not (Test-Path -LiteralPath (Join-Path $skillSourceDir 'SKILL.md'))) {
        Fail "Downloaded archive does not contain skills/$SkillName/SKILL.md"
    }

    return $skillSourceDir
}

function Backup-ExistingInstall([string]$TargetDir) {
    if (-not (Test-Path -LiteralPath $TargetDir)) {
        return $null
    }

    $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
    $backupDir = "$TargetDir.backup.$timestamp"
    Move-Item -LiteralPath $TargetDir -Destination $backupDir
    return $backupDir
}

function Install-Skill([string]$SourceDir, [string]$TargetRoot) {
    New-Item -ItemType Directory -Path $TargetRoot -Force | Out-Null

    $targetDir = Join-Path $TargetRoot $SkillName
    $tempDir = Join-Path $TargetRoot ".$SkillName.tmp.$PID"

    if (Test-Path -LiteralPath $tempDir) {
        Remove-Item -LiteralPath $tempDir -Recurse -Force
    }

    Copy-Item -LiteralPath $SourceDir -Destination $tempDir -Recurse
    $backupDir = Backup-ExistingInstall $targetDir
    Move-Item -LiteralPath $tempDir -Destination $targetDir

    return @{
        InstalledDir = $targetDir
        BackupDir = $backupDir
    }
}

if ($Help) {
    Show-Usage
    return
}

if ($Agent -and $Dir) {
    Fail 'Use either -Dir or -Agent, not both.'
}

$targetDir = if ($Dir) {
    $Dir
}
elseif ($Agent) {
    Resolve-AgentDir $Agent
}
else {
    Detect-DefaultDir
}

$workDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())

try {
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null

    $sourceDir = Get-SkillSourceDir $workDir
    $result = Install-Skill -SourceDir $sourceDir -TargetRoot $targetDir

    Write-Host "Installed $SkillName skill to: $($result.InstalledDir)"

    if ($result.BackupDir) {
        Write-Host "Previous installation backed up to: $($result.BackupDir)"
    }

    if ($result.InstalledDir -like "*\.cursor\skills\*") {
        Write-Host 'Note: Cursor primarily uses .cursor/rules. This install targets its compatible skills directory.'
    }

    Write-Host 'Next steps:'
    Write-Host '1. Restart your client or open a new session.'
    Write-Host "2. Verify that $($result.InstalledDir)\SKILL.md exists."
    Write-Host '3. Ask the agent to perform a sharecrm-related task.'
}
finally {
    if (Test-Path -LiteralPath $workDir) {
        Remove-Item -LiteralPath $workDir -Recurse -Force
    }
}
