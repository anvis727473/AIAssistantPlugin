# WBP_AIAssistant - Blueprint Setup Guide

## Overview
This is a step-by-step guide to create the Editor Utility Widget (EUW) Blueprint that serves as the AI Assistant UI in UEFN.

## Step 1: Create the Editor Utility Widget

1. Open UEFN
2. Right-click in Content Browser → Editor Utilities → Editor Utility Widget
3. Name it: `WBP_AIAssistant`
4. Open it in the Widget Designer

## Step 2: Design the UI Layout

### Root Canvas Panel
- Set as the root widget
- Fill screen

### Top Section - Header
Add a **Vertical Box** at the top:
- **Text Block**: "AI Assistant" (Title)
  - Font Size: 24
  - Justification: Center

### Middle Section - Input Area
Add a **Vertical Box** below the header:
- **Text Block**: "Prompt:"
- **Multi-line Editable Text** (name: `InputPrompt`)
  - Is Read Only: false
  - Hint Text: "Type your prompt here..."
  - Height: 100
  - Allow Multi-line: true

### Action Button
- **Button** (name: `RunButton`)
  - Button Text: "Execute"
  - Width: 200
  - Height: 40

### Bottom Section - Output Area
Add a **Vertical Box** below the button:
- **Text Block**: "Response:"
- **Editable Text** (name: `OutputText`)
  - Is Read Only: true
  - Is Multiline: true
  - Height: 300

### Layout Structure (Widget Hierarchy)
```
Canvas Panel
└── Vertical Box
    ├── Text Block ("AI Assistant")
    ├── Vertical Box
    │   ├── Text Block ("Prompt:")
    │   └── Multi-line Editable Text (InputPrompt)
    ├── Button (RunButton)
    │   └── Text Block ("Execute")
    └── Vertical Box
        ├── Text Block ("Response:")
        └── Editable Text (OutputText)
```

## Step 3: Blueprint Graph Logic

Open the **Graph** tab in the Widget Blueprint.

### Event Graph Setup

#### Node 1: On Button Click
- Add event: `Event OnClicked` for `RunButton`

#### Node 2: Get Input Text
- Get `InputPrompt` → `Get Text (Text)` node
- Store in variable: `UserPrompt`

#### Node 2.5: Get Level Context
- Call `GetLevelContext()` from ActionExecutor
- Store in variable: `LevelContext`
- This reads all actors in the level and sends them to the AI

#### Node 3: Web Request
- Add node: `Request` (from UEFN Web Request plugin)
- Method: POST
- URL: (your API endpoint, e.g., https://api.openai.com/v1/chat/completions)
- Headers:
  - Content-Type: application/json
  - Authorization: Bearer YOUR_API_KEY
- Content:
```json
{
  "model": "gpt-4",
  "messages": [
    {"role": "system", "content": "[PASTE CONTENT FROM SystemPrompt.txt]"},
    {"role": "user", "content": "Current level state:\n{LevelContext}\n\nUser request: {UserPrompt}"}
  ],
  "temperature": 0.7
}
```

#### Node 4: Handle Response
- Add event: `On Complete` from the Web Request node
- Get Response Body
- Parse JSON using `JSON String to Struct` node

#### Node 5: Extract Fields
- Get "verse_code" field → Store as `VerseCode`
- Get "actions" field → Store as `ActionsArray`
- Get "explanation" field → Store as `Explanation`

#### Node 6: Update Output
- Set `OutputText` text to: `Explanation`

#### Node 7: Execute Actions
- For each action in `ActionsArray`:
  - Get "type" field
  - Branch: if type = "spawn_device"
  - Get "device_class", "location", "rotation"
  - Call `SpawnActorFromAsset` or appropriate UEFN function

### Variable List
Create these variables in the Blueprint:
- `UserPrompt: Text`
- `LevelContext: String`
- `VerseCode: String`
- `ActionsArray: Array of Structs`
- `Explanation: String`
- `APIEndpoint: String`
- `APIKey: String`

## Step 4: Compile and Save

1. Click **Compile** in the toolbar
2. Click **Save**
3. Close the Widget Blueprint

## Step 5: Create Editor Utility Blueprint

1. Right-click in Content Browser → Editor Utilities → Editor Utility Blueprint
2. Base Class: `EditorUtilityWidget`
3. Name it: `EUW_AIAssistant`
4. Open it
5. In Class Defaults, set Widget: `WBP_AIAssistant`
6. Compile and Save

## Step 6: Launch the AI Assistant

1. Right-click on `EUW_AIAssistant` in Content Browser
2. Select "Run Editor Utility Widget"
3. The AI Assistant window should appear

## Notes

- The Web Request node requires the UEFN Web Request plugin to be enabled
- Store your API key securely (consider using environment variables)
- Test with simple prompts first
- The ActionExecutor.verse file handles the actual device spawning

## Troubleshooting

- If Web Request fails: Check API key and endpoint URL
- If JSON parsing fails: Verify the AI response format matches SystemPrompt.txt
- If devices don't spawn: Check device_class names match UEFN exactly
