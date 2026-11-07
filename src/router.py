#!/usr/bin/env python3
"""Small, deterministic effort router; no dependency and no prompt upload."""

import re
import sys


def choose(prompt: str) -> tuple[str, str]:
    text = prompt.lower()
    if len(text) > 6000 or re.search(r"\b(arquitetura|migra(?:ção|tion)|seguran(?:ça|ity)|concorrência|debug difícil|produção)\b", text):
        return "high", "tarefa ampla, sensível ou de depuração profunda"
    if len(text) > 1200 or re.search(r"\b(refator|implementar|implement|test|api|banco|database|bug|corrigir|fix|review)\b", text):
        return "medium", "mudança de código ou análise com várias etapas"
    return "low", "tarefa curta e localizada"


if __name__ == "__main__":
    effort, reason = choose(" ".join(sys.argv[1:]) or sys.stdin.read())
    print(f"{effort}\t{reason}")
