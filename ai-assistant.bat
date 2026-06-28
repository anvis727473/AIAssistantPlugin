@echo off
setlocal

set API_KEY=%OPENAI_API_KEY%
set API_URL=https://api.openai.com/v1/chat/completions

if "%API_KEY%"=="" (
    echo Erro: Defina OPENAI_API_KEY
    echo set OPENAI_API_KEY=sua-chave-aqui
    exit /b 1
)

set /p PROMPT="Digite seu prompt: "

curl -s %API_URL% ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer %API_KEY%" ^
  -d "{\"model\":\"gpt-4\",\"messages\":[{\"role\":\"system\",\"content\":\"Voce e um assistente UEFN. Responda SEMPRE com JSON: {\\\"verse_code\\\":\\\"\\\",\\\"actions\\\":[{\\\"type\\\":\\\"spawn_device\\\",\\\"device_class\\\":\\\"DeviceName\\\",\\\"location\\\":{\\\"x\\\":0,\\\"y\\\":0,\\\"z\\\":0},\\\"rotation\\\":{\\\"pitch\\\":0,\\\"yaw\\\":0,\\\"roll\\\":0}}],\\\"explanation\\\":\\\"\\\"}. Devices: PlayerSpawnerDevice, BasicSpawnerDevice, TriggerDevice, ButtonDevice, BarrierDevice, GoalDevice, CheckpointDevice, TeleporterDevice.\"},{\"role\":\"user\",\"content\":\"%PROMPT%\"}],\"temperature\":0.7}" > response.json

type response.json
