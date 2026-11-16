# claude-dreaming

A Claude Code skill that runs a scheduled "dream" over Claude Code's auto-memory: it rereads what
actually happened since the last pass, corrects the notes, and proposes the result on a git branch for
you to approve.

## What it is
Claude Code writes memory notes while it works. Some are wrong from the start, some go stale, and all of
them get loaded into every session. A dream is an offline pass that checks them against ground truth.

The idea comes from Anthropic's
[The components of agent memory](https://www.anthropic.com/research/components-of-agent-memory).
The propose-then-review loop follows
[How Warp builds self-improving agents on Claude](https://claude.com/resources/articles/how-warp-builds-self-improving-agents-on-claude):
the agent proposes changes to its own memory, and a human approves them.

Each dream runs six phases:
1. **Capture** new rulings and corrections from your messages.
2. **Verify** every note: still true, not reversed, and the paths it names still exist.
3. **Promote out** what belongs in a wiki, design doc or skill.
4. **Consolidate** stray notes into topic notes.
5. **Keep the index small** (`MEMORY.md`, about 40 lines by default).
6. **Eval:** answer a recall question set from the new memory and the old.

## How it differs from simple consolidation
- **Branch proposals.** Changes land on `dream/<date>` in the memory folder's git repo. The live branch stays checked out, so a bad dream never reaches a session until you merge it.
- **Promotion out.** A rule that a wiki, design doc or skill already holds is deleted from memory; one that should live there is listed as a proposal.
- **Transcript-checked verification.** Notes are checked against your own messages in the session transcripts, plus git history and any configured issue. User messages are extracted with a script; whole transcripts are never read, and their contents are treated as data, not instructions.
- **A recall eval.** A table of questions with expected answers, scored against the old memory and the new, so you can see whether the dream made recall better or worse.

## Install
1. Copy `skills/dreaming/` into your project's `.claude/skills/` or into `~/.claude/skills/`.
2. Make the memory folder a git repo:
   ```
   cd ~/.claude/projects/<project-slug>/memory
   git init && git add -A && git commit -m "memory: baseline"
   ```
   `<project-slug>` is the project path with separators replaced by dashes; look in `~/.claude/projects/` to find it. Transcripts are the `*.jsonl` files one level up.
3. Copy `dream.config.example.json` to `dream.config.json` in the skill folder and fill it in. Only `memory_dir` is required; any source you leave out is skipped.
4. Optionally copy `eval-template.md` to the memory folder as `dream-eval.md` and write your own questions. The first dream will start one if it is missing.

## First run
From the project folder, run `claude` and say "use the dreaming skill". Watch the first one: it shows
what the skill reads and what it proposes.

## The weekly schedule
- **Windows:** `scripts/weekly-dream.ps1 -ProjectDir <project-dir>`. The `Register-ScheduledTask` line is at the top of the script.
- **macOS and Linux:** `scripts/weekly-dream.sh <project-dir>`. The cron line is at the top of the script.

Both run `claude -p` headless with a minimal `--allowedTools` list (file tools, `git`, `python`, a few
read-only shell commands, and `gh issue view` and `gh issue comment`) and log to
`~/.claude/dream-logs/dream-<date>.log`. Drop the `gh` entries if you don't use an issue.

## Approving
Read the report (`dream-report-<date>.md` on the branch) and the diff, then:
```
cd ~/.claude/projects/<project-slug>/memory
git diff master..dream/<date>
git merge --ff-only dream/<date>
```
To reject, delete the branch. Nothing is pushed anywhere.

## Results example
On a real game project's memory: 116 notes to 21, the index from 119 lines to 40, and the recall eval
from 17/28 to 28/28 after one dream.

## Caveats
- The eval is only as good as its questions, and the same model writes and grades it. Read the FAILs, and add questions a session got wrong.
- Dreams cost tokens. A first dream over months of transcripts is the largest; weekly ones are smaller.
- `--permission-mode acceptEdits` lets the run edit files without asking. The skill limits edits to the memory folder, but that is an instruction, not a sandbox. Review the branch before merging.
- If a session writes memory while a dream runs, the fast-forward merge fails. Rebase the branch or rerun.
- The transcript format is Claude Code's internal JSONL and may change. If the extraction script finds no messages, check the format.
- Transcripts can hold secrets. The memory folder is local; don't push it anywhere public.

## License
MIT. See `LICENSE`.
