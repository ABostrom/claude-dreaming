---
name: dream-eval
description: "Recall eval for the memory dream: questions any session must answer from memory plus the docs it points to, with expected answers and scores for the dream branch and the main branch. Not a memory; not indexed."
---

# Recall eval, <YYYY-MM-DD>

Each question is answered from the index and the notes alone, following a note's pointer into the wiki
where it gives one. **New** is branch `dream/<YYYY-MM-DD>`; **Main** is the main branch at `<short-sha>`.
Rerun this after the next dream and add any question a session got wrong in the meantime.

| # | Question | Expected answer | New | Main |
|---|---|---|---|---|
| 1 | Do I ask before merging to main after a green test run? | No. Fast-forward main and say so afterwards | PASS (core) | PASS |
| 2 | Which command runs the full test suite? | `make test` from the repo root; the old `run-tests.sh` was removed | PASS | FAIL: the note still names `run-tests.sh`, which no longer exists |
| 3 | How many questions do I put to the user at once? | One at a time, in plain words | PASS after fix (first answer missed "one at a time") | FAIL: buried in an unrelated note, never in the index |

**Score:** New 3/3, Main 1/3.

Scoring: PASS when the answer matches in substance; "PASS (core)" when the index line alone answers it;
"PASS after fix" when the branch first failed and was fixed in this dream; FAIL with the reason.
