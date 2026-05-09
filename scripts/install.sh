#!/bin/sh

set -eu

REPO_OWNER=${REPO_OWNER:-emengs}
REPO_NAME=${REPO_NAME:-sharecrm-cli-skills}
REPO_REF=${REPO_REF:-main}
SKILL_NAME=sharecrm
RAW_INSTALL_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_REF}/scripts/install.sh"

usage() {
  cat <<EOF
Install the ${SKILL_NAME} skill on macOS or Linux.

Usage:
  sh install.sh [--agent <name>] [--dir <path>] [--ref <git-ref>]

Options:
  --agent <name>  Install for a known agent target.
                  Supported values: claude-code, codex, gemini-cli, openclaw, cursor
  --dir <path>    Install into a custom skills directory.
  --ref <git-ref> Install from a specific GitHub ref. Defaults to: ${REPO_REF}
  --help          Show this help message.

Examples:
  curl -fsSL ${RAW_INSTALL_URL} | sh
  curl -fsSL ${RAW_INSTALL_URL} | sh -s -- --agent claude-code
  curl -fsSL ${RAW_INSTALL_URL} | sh -s -- --dir "\$HOME/.claude/skills"
EOF
}

log() {
  printf '%s\n' "$1"
}

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

detect_os() {
  os_name=$(uname -s 2>/dev/null || printf unknown)
  case "$os_name" in
    Darwin|Linux) ;;
    *)
      fail "unsupported operating system: ${os_name}. This installer supports macOS and Linux only."
      ;;
  esac
}

resolve_agent_dir() {
  agent_name=$1

  case "$agent_name" in
    claude-code)
      printf '%s\n' "$HOME/.claude/skills"
      ;;
    codex)
      printf '%s\n' "$HOME/.agents/skills"
      ;;
    gemini-cli)
      printf '%s\n' "$HOME/.gemini/skills"
      ;;
    openclaw)
      printf '%s\n' "$HOME/.openclaw/skills"
      ;;
    cursor)
      printf '%s\n' "$HOME/.cursor/skills"
      ;;
    *)
      fail "unsupported agent: ${agent_name}"
      ;;
  esac
}

detect_default_dir() {
  if [ -d "$HOME/.claude" ]; then
    printf '%s\n' "$HOME/.claude/skills"
  elif [ -d "$HOME/.gemini" ]; then
    printf '%s\n' "$HOME/.gemini/skills"
  elif [ -d "$HOME/.openclaw" ]; then
    printf '%s\n' "$HOME/.openclaw/skills"
  elif [ -d "$HOME/.cursor" ]; then
    printf '%s\n' "$HOME/.cursor/skills"
  elif [ -d "$HOME/.codex" ]; then
    printf '%s\n' "$HOME/.codex/skills"
  else
    printf '%s\n' "$HOME/.agents/skills"
  fi
}

download_skill_source() {
  source_root=$1

  if [ -n "${SHARECRM_SKILL_SOURCE_DIR:-}" ]; then
    [ -d "$SHARECRM_SKILL_SOURCE_DIR" ] || fail "SHARECRM_SKILL_SOURCE_DIR does not exist: $SHARECRM_SKILL_SOURCE_DIR"
    printf '%s\n' "$SHARECRM_SKILL_SOURCE_DIR"
    return 0
  fi

  require_command curl
  require_command tar

  archive_path="$source_root/repo.tar.gz"
  extract_dir="$source_root/extracted"
  repo_dir="${REPO_NAME}-${REPO_REF}"
  archive_url="https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/${REPO_REF}"

  log "Downloading ${REPO_OWNER}/${REPO_NAME}@${REPO_REF} ..."
  curl -fsSL "$archive_url" -o "$archive_path"
  mkdir -p "$extract_dir"
  tar -xzf "$archive_path" -C "$extract_dir"

  skill_source_dir="$extract_dir/$repo_dir/skills/$SKILL_NAME"
  [ -f "$skill_source_dir/SKILL.md" ] || fail "downloaded archive does not contain skills/$SKILL_NAME/SKILL.md"

  printf '%s\n' "$skill_source_dir"
}

backup_existing_install() {
  target_dir=$1

  if [ ! -e "$target_dir" ]; then
    BACKUP_DIR=
    return 0
  fi

  timestamp=$(date +%Y%m%d%H%M%S)
  BACKUP_DIR="${target_dir}.backup.${timestamp}"
  mv "$target_dir" "$BACKUP_DIR"
}

install_skill() {
  source_dir=$1
  target_root=$2

  mkdir -p "$target_root"
  target_dir="$target_root/$SKILL_NAME"
  temp_dir="$target_root/.${SKILL_NAME}.tmp.$$"

  rm -rf "$temp_dir"
  cp -R "$source_dir" "$temp_dir"

  backup_existing_install "$target_dir"
  mv "$temp_dir" "$target_dir"

  INSTALLED_DIR=$target_dir
}

TARGET_DIR=
AGENT=

while [ $# -gt 0 ]; do
  case "$1" in
    --agent)
      [ $# -ge 2 ] || fail "--agent requires a value"
      AGENT=$2
      shift 2
      ;;
    --dir)
      [ $# -ge 2 ] || fail "--dir requires a value"
      TARGET_DIR=$2
      shift 2
      ;;
    --ref)
      [ $# -ge 2 ] || fail "--ref requires a value"
      REPO_REF=$2
      RAW_INSTALL_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_REF}/scripts/install.sh"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      fail "unknown argument: $1"
      ;;
  esac
done

detect_os
require_command mktemp
require_command cp
require_command mv

if [ -n "$TARGET_DIR" ] && [ -n "$AGENT" ]; then
  fail "use either --dir or --agent, not both"
fi

if [ -n "$TARGET_DIR" ]; then
  FINAL_TARGET_DIR=$TARGET_DIR
elif [ -n "$AGENT" ]; then
  FINAL_TARGET_DIR=$(resolve_agent_dir "$AGENT")
else
  FINAL_TARGET_DIR=$(detect_default_dir)
fi

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT INT TERM HUP

SOURCE_DIR=$(download_skill_source "$WORK_DIR")
install_skill "$SOURCE_DIR" "$FINAL_TARGET_DIR"

log "Installed ${SKILL_NAME} skill to: ${INSTALLED_DIR}"

if [ -n "${BACKUP_DIR:-}" ]; then
  log "Previous installation backed up to: ${BACKUP_DIR}"
fi

case "$INSTALLED_DIR" in
  "$HOME/.cursor/skills/"*|"$HOME/.cursor/skills")
    log "Note: Cursor primarily uses .cursor/rules. This install targets its compatible skills directory."
    ;;
esac

log "Next steps:"
log "1. Restart your client or open a new session."
log "2. Verify that ${INSTALLED_DIR}/SKILL.md exists."
log "3. Ask the agent to perform a sharecrm-related task."
