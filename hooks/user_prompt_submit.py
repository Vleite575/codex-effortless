#!/usr/bin/env python3
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from router import choose
from judge import choose_with_codex

payload = json.load(sys.stdin)
prompt = payload.get("prompt") or payload.get("user_prompt") or payload.get("text") or ""
prompt = prompt if isinstance(prompt, str) else json.dumps(prompt)
if __import__("os").environ.get("CODEX_EFFORTLESS_JUDGE") == "codex":
    try:
        effort, reason = choose_with_codex(prompt, __import__("os").environ.get("CODEX_EFFORTLESS_JUDGE_MODEL", "gpt-5-mini"))
    except Exception:
        effort, reason = choose(prompt)
else:
    effort, reason = choose(prompt)

# Codex displays hook status/context in supported clients; this never changes files.
print(json.dumps({"continue": True, "additional_context": f"Effortless: {effort} — {reason}"}))
