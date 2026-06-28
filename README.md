# AI Assistant Plugin for UEFN

Integra uma IA diretamente no Unreal Editor for Fortnite. Você digita um prompt, a IA cria código Verse e coloca devices no seu mapa.

---

## Integração com MiMoCode e OpenCode

### Comando `/uefn`

Dentro do MiMoCode ou OpenCode, digite:

```
/uefn create a deathrun map with 5 stages
```

Ou qualquer coisa sobre UEFN:

```
/uefn spawn a weapon spawner at center
/uefn write a countdown timer in verse
/uefn create an arena with 4 spawn points
```

### Como funciona

O comando `/uefn`:
1. Entende seu pedido
2. Gera código Verse (se precisar)
3. Cria JSON com as ações (devices a spawnar)
4. Você copia o JSON e usa no plugin UEFN

### Arquivos instalados

- **MiMoCode**: `C:\Users\andre\.config\mimocode\commands\uefn.md`
- **OpenCode**: `C:\Users\andre\.config\opencode\commands\uefn.md`

---

## Instalação

### 1. Copie o plugin

```
Copie a pasta "AIAssistantPlugin" para:
SeuProjetoUEFN/Plugins/
```

Estrutura final:
```
SeuProjetoUEFN/
├── Content/
├── Plugins/
│   └── AIAssistantPlugin/
│       ├── AIAssistantPlugin.uplugin
│       ├── Content/Editor/AIAssistant/
│       │   ├── ActionExecutor.verse
│       │   ├── SystemPrompt.txt
│       │   └── BLUEPRINT_SETUP.md
│       └── README.md
└── ...
```

### 2. Abra o projeto UEFN

- O UEFN vai detectar o plugin automaticamente
- Se pedir para recompilar, aceite

---

## Configuração do Blueprint

### Passo 1: Criar o Editor Utility Widget

1. No Content Browser, clique com botão direito
2. Vá em **Editor Utilities** → **Editor Utility Widget**
3. Nomeie: `WBP_AIAssistant`
4. Abra o Blueprint

### Passo 2: Montar a Interface

No Widget Designer, crie esta estrutura:

```
Canvas Panel (raiz)
└── Vertical Box
    ├── Text Block ("AI Assistant") ← Título
    ├── Vertical Box
    │   ├── Text Block ("Prompt:")
    │   └── Multi-line Editable Text ← Nome: InputPrompt
    ├── Button ← Nome: RunButton
    │   └── Text Block ("Execute")
    └── Vertical Box
        ├── Text Block ("Response:")
        └── Editable Text ← Nome: OutputText
```

**Configurações dos widgets:**
| Widget | Propriedade | Valor |
|--------|-------------|-------|
| InputPrompt | Is Read Only | false |
| InputPrompt | Hint Text | "Digite seu prompt..." |
| InputPrompt | Height | 100 |
| RunButton | Width | 200 |
| RunButton | Height | 40 |
| OutputText | Is Read Only | true |
| OutputText | Is Multiline | true |
| OutputText | Height | 300 |

### Passo 3: Configurar o Graph

Abra a aba **Graph** e crie estes nodes:

#### Variáveis (crie primeiro)
- `UserPrompt: Text`
- `LevelContext: String`
- `VerseCode: String`
- `ActionsArray: Array`
- `Explanation: String`
- `APIEndpoint: String`
- `APIKey: String`

#### Fluxo dos Nodes

```
[Event OnClicked RunButton]
        ↓
[Get Text] de InputPrompt → salva em UserPrompt
        ↓
[GetLevelContext] → salva em LevelContext
        ↓
[Request Web] POST para API
  URL: https://api.openai.com/v1/chat/completions
  Headers:
    Content-Type: application/json
    Authorization: Bearer {APIKey}
  Body:
  {
    "model": "gpt-4",
    "messages": [
      {"role": "system", "content": "[cole o SystemPrompt.txt]"},
      {"role": "user", "content": "Nível atual:\n{LevelContext}\n\nPedido: {UserPrompt}"}
    ]
  }
        ↓
[On Complete] → pega Response Body
        ↓
[JSON Parse] → extrai verse_code, actions, explanation
        ↓
[Set Text] em OutputText ← Explanation
        ↓
[For Each] em ActionsArray
  → Executa cada ação (spawn, modify, delete)
```

### Passo 4: Criar o EUW

1. Clique direito no Content Browser
2. **Editor Utilities** → **Editor Utility Blueprint**
3. Base Class: `EditorUtilityWidget`
4. Nome: `EUW_AIAssistant`
5. Abra → Class Defaults → Widget: `WBP_AIAssistant`
6. Compile e Save

---

## Como Usar

### Abrir o Assistente

1. No Content Browser, clique direito em `EUW_AIAssistant`
2. Selecione **Run Editor Utility Widget**
3. A janela do assistente aparece

### Exemplos de Prompts

**Criar um device:**
```
Crie um spawner de armas no centro do mapa
```

**Criar um mapa completo:**
```
Crie um mapa de deathrun com 5 fases, cada fase com checkpoint e armadilha
```

**Modificar algo:**
```
Mova todos os spawners 500 unidades para cima
```

**Código Verse:**
```
Escreva código Verse para um timer de 30 segundos
```

**Mapa temático:**
```
Crie uma arena de batalha com 4 spawners nos cantos, barreiras ao redor e um objetivo no centro
```

---

## O que a IA pode fazer

### Ações Suportadas

| Ação | Descrição |
|------|-----------|
| `spawn_device` | Cria um device novo no mapa |
| `modify_actor` | Move ou rotaciona um actor existente |
| `delete_actor` | Remove um actor do mapa |
| `create_folder` | Cria uma pasta no Content Browser |

### Devices Disponíveis

- PlayerSpawnerDevice
- BasicSpawnerDevice
- TriggerDevice
- ButtonDevice
- AudioPlayerDevice
- VFXDevice
- BarrierDevice
- GoalDevice
- CheckpointDevice
- TeleporterDevice
- ItemPlacerDevice
- HealthDevice
- ShieldDevice
- AmmoDevice
- WeaponDevice
- VehicleSpawnerDevice

---

## Arquitetura

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│  Interface (EUW) │────▶│  API (GPT-4) │────▶│ ActionExecutor  │
│  - InputPrompt   │     │  - System    │     │  .verse         │
│  - RunButton     │     │    Prompt    │     │  - Parse JSON   │
│  - OutputText    │     │  - JSON      │     │  - Spawn/Modify │
└─────────────────┘     └──────────────┘     └─────────────────┘
        │                      │                      │
        │                      │                      │
        ▼                      ▼                      ▼
   User types            AI understands           Devices appear
   prompt                map + context            in editor
```

---

## Solução de Problemas

### Web Request não funciona
- Verifique se a API key está correta
- Teste a URL no Postman primeiro
- Verifique se o UEFN tem acesso à internet

### JSON não parseia
- A resposta da IA deve ser JSON válido
- Verifique se o SystemPrompt.txt está colado corretamente

### Devices não aparecem
- Verifique se o device_class está escrito corretamente
- O device precisa existir no UEFN
- Verifique o OutputText para ver erros

### Plugin não aparece
- Reinicie o UEFN
- Verifique se a pasta está em Plugins/
- Verifique o Output Log do UEFN

---

## Limitações

- Precisa de conexão com a internet
- A IA não vê o mapa visualmente (só a lista de devices)
- Devices devem existir no UEFN
- Não cria meshes customizados (só devices)
- API key fica no Blueprint (não é seguro para compartilhar)

---

## Segurança

- Nunca compartilhe o Blueprint com sua API key
- Use variáveis de ambiente para a key
- O plugin não coleta dados

---

## Licença

Uso livre para projetos UEFN.
