# AI Assistant Plugin for UEFN

Integrates an AI assistant directly into Unreal Editor for Fortnite (UEFN).

## Files

- `AIAssistantPlugin.uplugin` - Plugin descriptor
- `Content/Editor/AIAssistant/ActionExecutor.verse` - Verse code for parsing/executing AI actions
- `Content/Editor/AIAssistant/SystemPrompt.txt` - System prompt for the AI API
- `Content/Editor/AIAssistant/BLUEPRINT_SETUP.md` - How to set up the EUW Blueprint

## Quick Start

1. Copy `AIAssistantPlugin` folder to your UEFN project's `Plugins/` directory
2. Follow `BLUEPRINT_SETUP.md` to create the Editor Utility Widget
3. Add your API key in the Blueprint's APIKey variable
4. Right-click `EUW_AIAssistant` → Run Editor Utility Widget

## Architecture

```
User Input → EUW Blueprint → API Request → AI Response → Parse JSON → Execute Actions
                                                                    ↓
                                                            Verse (ActionExecutor)
                                                                    ↓
                                                        Spawn Devices in Editor
```

## Limitations

- Requires internet connection for API calls
- Device spawning limited to UEFN device classes
- No Python scripting (UEFN restriction)
- Blueprint-based solution (no C++ modules)
