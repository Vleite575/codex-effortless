#!/usr/bin/env python3
import json
import re
import subprocess


def choose_with_codex(prompt: str, model: str) -> tuple[str, str]:
    instruction = (
        "Você escolhe o menor esforço que ainda resolve bem uma tarefa de agente que lê arquivos, "
        "executa ferramentas e edita código. Responda somente JSON válido no formato "
        '{"effort":"low|medium|high|xhigh|max","sure":0.0,"why":"até 6 palavras"}.\n'
        "low: resposta sem ferramentas ou alteração curta; medium: trabalho normal em várias etapas; "
        "high: arquitetura, segurança, depuração difícil ou grande refatoração; xhigh/max: trabalho excepcionalmente difícil.\n\n"
        + prompt
    )
    result = subprocess.run(
        ["codex", "exec", "-m", model, "-c", "model_reasoning_effort=low",
         "--sandbox", "read-only", "--ask-for-approval", "never", instruction],
        capture_output=True, text=True, timeout=45, check=False,
    )
    matches = re.findall(r"\{[^{}]+\}", result.stdout)
    if result.returncode != 0 or not matches:
        raise RuntimeError("modelo julgador não retornou low/medium/high")
    try:
        verdict = json.loads(matches[-1])
        effort = verdict["effort"].lower()
        if effort not in {"low", "medium", "high", "xhigh", "max"}:
            raise ValueError
    except (ValueError, KeyError, TypeError, json.JSONDecodeError) as error:
        raise RuntimeError("modelo julgador retornou JSON inválido") from error
    why = str(verdict.get("why", "classificação OpenAI"))[:60]
    return effort, f"OpenAI: {why}"
