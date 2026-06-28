---
name: feedback-debug-search-first
description: "When stuck on a tricky bug, search community fixes after 2-3 failed guesses instead of iterating more env-var/version permutations"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e7eb26e6-4f90-445a-b18b-283ab196623f
---

After **2-3 unsuccessful guesses** on a tricky bug (env vars, version downgrade, alternate install method), **stop iterating and search the web/community** for the same symptom (GitHub issues, vendor forums, distro bug trackers) before trying more permutations.

**Why:** On 2026-05-27 Thiraphat reported OrcaSlicer crashing when clicking the printer IP. I burned through three rounds of guesses — env vars (`WEBKIT_DISABLE_*`), downgrade to 2.3.0, install Flatpak — before he eventually told me "ขอเเบบที่เขาเจอกันเเล้วเเก้ยังไง" ("show me how others fixed this"). The actual fix (add `100.64.0.0/10` to `moonraker.conf trusted_clients`, or use API key auth) was a known one-line solution found in the **first** community search. He ended up wiping the whole install in frustration. The pattern (env-var roulette, downgrade, container/sandbox alternative) is a strong signal I'm guessing — switch to search.

**How to apply:** When iterating on a non-trivial bug, after the second guess fails, run `WebSearch` for the specific error/symptom (segfault line, error string, stack frame) plus the app name. Read the top vendor/forum/issue hit before suggesting another env var, version, or install method.
