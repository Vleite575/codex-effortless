# codex-effortless

Protótipo local inspirado no `effortless` do Claude Code.

## O que funciona

- Terminal: escolhe `low`, `medium` ou `high` e chama `codex exec` com esse esforço.
- App Codex: plugin/hook local que mostra a decisão visualmente no status/contexto da mensagem.
- Julgador padrão: regras locais, sem enviar o prompt para outro modelo.
- Julgador opcional: `CODEX_EFFORTLESS_JUDGE=codex` usa `gpt-5-mini` pela autenticação local do Codex.
- Judge padrão: `gpt-5-mini`; altere com `CODEX_EFFORTLESS_JUDGE_MODEL`.
- O modelo principal continua sendo o padrão do Codex (ou `CODEX_MODEL`), para preservar qualidade e cache.

## Instalação no terminal

```sh
chmod +x bin/codex-effortless
export PATH="$PWD/bin:$PATH"
codex-effortless "corrija este bug e crie um teste"
```

Para usar o julgador OpenAI barato:

```sh
CODEX_EFFORTLESS_JUDGE=codex codex-effortless "corrija este bug e crie um teste"
```

## Instalação no app

Este workspace já contém `.agents/plugins/marketplace.json`, apontando para este pacote. Reinicie o app, abra Plugins → ACH Local Plugins e instale `codex-effortless`. Revise/confie no hook quando solicitado. O pacote inclui um MCP local que renderiza a barra visual.

Depois de instalado, invoque `Codex Effortless` no app para abrir o widget. Ele reproduz a barra da captura com Auto, modelo, contexto, Compact e configurações; os botões Compact e configurações enviam ações para a conversa.

O hook também pede ao agente para renderizar o widget automaticamente em cada mensagem enviada. Como o Codex não permite que um hook chame diretamente um MCP tool, a ativação depende do agente aceitar essa instrução.

## Verificação

```sh
python3 -m unittest discover -s tests -q
```

## Limites deliberados

Não há troca automática de modelo, compaction, handoff ou interface própria. Essas partes dependem de APIs do app que não estão expostas de forma estável.
