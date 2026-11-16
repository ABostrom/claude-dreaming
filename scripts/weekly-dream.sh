#!/usr/bin/env bash
# Weekly memory dream: runs Claude Code headless with the dreaming skill. It only proposes a branch.
#
# Cron (crontab -e), Sundays at 03:00; cron has a short PATH, so make sure `claude` is on it:
#   0 3 * * 0  PATH=$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin  /path/to/weekly-dream.sh /path/to/project
#
# Usage: weekly-dream.sh <project-dir> [log-dir]
set -u

project_dir="${1:?usage: weekly-dream.sh <project-dir> [log-dir]}"
log_dir="${2:-$HOME/.claude/dream-logs}"
date="$(date +%Y-%m-%d)"
mkdir -p "$log_dir"
log="$log_dir/dream-$date.log"

cd "$project_dir" || exit 1

prompt="Use the dreaming skill to run this week's memory dream for $date. Unattended: propose on a branch, leave the main branch checked out, write the report file and, if an issue is configured, post the comment."
tools='Read,Grep,Glob,Edit,Write,Skill,Bash(git:*),Bash(gh issue view:*),Bash(gh issue comment:*),Bash(python:*),Bash(python3:*),Bash(ls:*),Bash(grep:*),Bash(wc:*),Bash(head:*),Bash(tail:*),Bash(cat:*)'

claude -p "$prompt" --permission-mode acceptEdits --allowedTools "$tools" > "$log" 2>&1
