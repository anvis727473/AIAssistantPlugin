# UEFN AI Assistant - CLI

Ferramenta de linha de comando para gerar código Verse e ações JSON.

## Configuração

1. Defina sua API key:
```powershell
$env:OPENAI_API_KEY="sua-chave-aqui"
```

2. Execute:
```powershell
.\ai.ps1 "crie um spawner de armas"
```

## Exemplos

```powershell
# Criar device
.\ai.ps1 "spawn a player spawner at center"

# Criar mapa completo
.\ai.ps1 "create a deathrun with 5 stages"

# Código Verse
.\ai.ps1 "write a countdown timer in verse"
```

## Output

O script mostra:
- Resposta da IA (explicação)
- Lista de ações (devices a criar)
- Código Verse (se gerado)
- Salva JSON completo em `response.json`
