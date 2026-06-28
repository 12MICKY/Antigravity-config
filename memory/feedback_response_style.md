---
name: feedback-response-style
description: "How to communicate with Thiraphat — terse, action-first, no summaries"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f39abe6d-5c79-429f-8b8d-77c106836446
---

**Rules confirmed across multiple sessions:**

1. **No trailing summaries** — never recap what was just done. The user can read the output.
2. **No confirmation for reversible actions** — just do it. File edits, docker restarts, config changes = execute.
3. **"ทำเลย"** is a standing instruction — when user says this, act immediately.
4. **One sentence max** at end of task, or nothing at all.
5. **No bullet-point recaps** of completed steps.
6. **No "I'll now..." preamble** before tool calls — state what you're doing in one line max.
7. **No suggestions at end** unless directly relevant to what just broke.

**Why:** User works fast, context-switches often, re-reading summaries wastes time.

**How to apply:** Trust that the output speaks for itself. Silence after a task is fine. Short status updates during work are fine. Post-task essay is not.
