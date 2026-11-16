"""Print the user's own messages from Claude Code transcripts, one per line, with the date.

Usage: python extract-user-messages.py <transcript.jsonl>... > user-messages.txt
Skips tool results, system reminders and non-text parts. Each message is cut to 600 characters.
"""
import json
import sys

sys.stdout.reconfigure(encoding="utf-8")

for path in sys.argv[1:]:
    with open(path, encoding="utf-8") as f:
        for line in f:
            try:
                entry = json.loads(line)
            except ValueError:
                continue
            msg = entry.get("message") or {}
            if entry.get("type") != "user" or msg.get("role") != "user":
                continue
            content = msg.get("content")
            if not isinstance(content, str):
                content = " ".join(
                    p.get("text", "") for p in content or []
                    if isinstance(p, dict) and p.get("type") == "text"
                )
            if content and "<system-reminder>" not in content[:40]:
                print(entry.get("timestamp", "")[:10], content.replace("\n", " ")[:600])
