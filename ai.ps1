param(
    [string]$Prompt
)

$ApiKey = $env:OPENROUTER_API_KEY
if (-not $ApiKey) {
    Write-Host "Erro: OPENROUTER_API_KEY nao configurada" -ForegroundColor Red
    exit 1
}

if (-not $Prompt) {
    $Prompt = Read-Host "Digite seu prompt"
}

$body = @{
    model = "openai/gpt-4"
    messages = @(
        @{
            role = "system"
            content = "Voce e um assistente UEFN. Responda SEMPRE com JSON: {`"verse_code`":`"`",`"actions`":[{`"type`":`"spawn_device`",`"device_class`":`"DeviceName`",`"location`":{`"x`":0,`"y`":0,`"z`":0},`"rotation`":{`"pitch`":0,`"yaw`":0,`"roll`":0}}],`"explanation`":`"`"}. Devices: PlayerSpawnerDevice, BasicSpawnerDevice, TriggerDevice, ButtonDevice, BarrierDevice, GoalDevice, CheckpointDevice, TeleporterDevice."
        },
        @{
            role = "user"
            content = $Prompt
        }
    )
    temperature = 0.7
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/chat/completions" -Method Post -Headers @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $ApiKey"
} -Body $body

$json = $response.choices[0].message.content | ConvertFrom-Json

Write-Host "`nResposta:" -ForegroundColor Cyan
Write-Host $json.explanation -ForegroundColor Green

if ($json.actions.Count -gt 0) {
    Write-Host "`nAcoes:" -ForegroundColor Cyan
    $json.actions | ForEach-Object {
        Write-Host "  - $($_.type): $($_.device_class) em ($($_.location.x), $($_.location.y), $($_.location.z))" -ForegroundColor Yellow
    }
}

if ($json.verse_code) {
    Write-Host "`nCodigo Verse:" -ForegroundColor Cyan
    Write-Host $json.verse_code -ForegroundColor White
}

$json | ConvertTo-Json -Depth 10 | Out-File "response.json"
Write-Host "`nSalvo em response.json" -ForegroundColor Gray
