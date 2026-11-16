# Weekly memory dream: runs Claude Code headless with the dreaming skill. It only proposes a branch.
#
# Register (once, from an elevated or normal PowerShell; adjust the path, day and time):
#   Register-ScheduledTask -TaskName 'Claude Dream' `
#     -Trigger (New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3am) `
#     -Action (New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument '-NoProfile -File "<path>\weekly-dream.ps1" -ProjectDir "<project-dir>"') `
#     -Settings (New-ScheduledTaskSettingsSet -StartWhenAvailable)

param(
  # The project the memory belongs to; Claude Code picks its <project-slug> from this folder.
  [Parameter(Mandatory)] [string] $ProjectDir,
  [string] $LogDir = (Join-Path $HOME '.claude/dream-logs')
)

$ErrorActionPreference = 'Continue'
Set-Location $ProjectDir
$date = Get-Date -Format 'yyyy-MM-dd'
New-Item -ItemType Directory -Force $LogDir | Out-Null
$log = Join-Path $LogDir "dream-$date.log"

$prompt = "Use the dreaming skill to run this week's memory dream for $date. Unattended: propose on a branch, leave the main branch checked out, write the report file and, if an issue is configured, post the comment."
$tools = 'Read,Grep,Glob,Edit,Write,Skill,Bash(git:*),Bash(gh issue view:*),Bash(gh issue comment:*),Bash(python:*),Bash(ls:*),Bash(grep:*),Bash(wc:*),Bash(head:*),Bash(tail:*),Bash(cat:*)'

& claude -p $prompt --permission-mode acceptEdits --allowedTools $tools *> $log
