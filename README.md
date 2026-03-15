# Barkeep — Claude Code Status Bar

A zero-token-overhead status bar for Claude Code that displays your current objective, working directory, context window usage, and total token usage.

## Install

Open PowerShell and paste:

```powershell
powershell -c "irm https://raw.githubusercontent.com/sky-salsa/barkeep/main/install.ps1 | iex"
```

Restart Claude Code. That's it.

## What You Get

```
🫧 Objective → fix the login redirect | my-project | ▓▓▓▓░░░░░░ 41% context | TTU: 45.2k
```

| Section | What It Shows |
|---------|--------------|
| Objective | What you're working on (set it yourself or ask Claude) |
| Directory | Current working directory |
| Context % | How much of the context window you've used |
| TTU | Total tokens used this session (input + output) |

## Setting Objectives

**Type it yourself:**
- `objective: fix the login redirect` — sets the objective (message doesn't go to Claude)
- `objective: clear` — clears it

**Ask Claude:**
- "Hey, set the objective to fix the login redirect"
- Claude updates the status bar directly

Both are session-scoped — they don't leak across sessions.

## Uninstall

Delete `~/.claude/extensions/barkeep/` and remove the `statusLine` and `UserPromptSubmit` hook entries from `~/.claude/settings.json`.

## Files

| File | Purpose |
|------|---------|
| `statusline.py` | Main status bar script |
| `objective-hook.py` | Captures `objective:` messages from the prompt |
| `set-objective.py` | CLI script for Claude to set objectives |
| `install.ps1` | One-line installer |

## Dependencies

Python 3 (stdlib only). No pip packages.

---

## Changelog

### v0.3.0 — 2026-03-15
- **Renamed:** Project is now "Barkeep"
- **Added:** One-line PowerShell installer
- **Added:** LLM-set objectives via `set-objective.py` (Claude can set objectives directly)
- **Added:** Session ID tracking so LLM-set objectives are session-scoped
- **Added:** Total Token Usage (TTU) display in status bar
- **Fixed:** Critical bug — LLM-set objectives were global, overriding all sessions
- **Fixed:** Hook failure mode — missing/broken hook no longer bricks Claude Code

### v0.2.0 — 2026-03-13
- **Added:** Objective system (hook + statusline integration)
- **Added:** `objective-hook.py` with `{"decision": "block"}` to consume objective commands
- **Fixed:** Objective commands leaking into conversation as user messages
- **Removed:** Token burn display (upstream data was unreliable)

### v0.1.0 — 2026-03-13
- **Initial release:** Status bar with directory name, context % bar, color scheme
