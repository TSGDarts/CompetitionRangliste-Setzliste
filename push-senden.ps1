# Sendet eine OneSignal Web-Push an alle angemeldeten Geraete.
# Der geheime REST API Key steht in onesignal-key.txt (NICHT im Repo).
$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$keyFile = Join-Path $dir 'onesignal-key.txt'
$appId = 'ae7e40d9-eaa7-45e6-847e-28d0e0462f1b'

if (-not (Test-Path $keyFile)) {
  Write-Host 'Hinweis: onesignal-key.txt fehlt - keine Push gesendet.'
  exit 0
}
$key = (Get-Content $keyFile -Raw).Trim()
if ([string]::IsNullOrWhiteSpace($key) -or $key -match 'HIER-DEINEN') {
  Write-Host 'Hinweis: In onesignal-key.txt steht noch kein echter Key - keine Push gesendet.'
  exit 0
}

$titel   = 'TSG 08 Roth - Competition'
$text    = 'Neuer Spieltag ist online! Schau in Rangliste und Setzliste. 🎯'
$link    = 'https://tsgdarts.github.io/CompetitionRangliste-Setzliste/'

$payload = @{
  app_id            = $appId
  included_segments = @('Subscribed Users')
  headings          = @{ en = $titel; de = $titel }
  contents          = @{ en = $text; de = $text }
  url               = $link
} | ConvertTo-Json -Depth 6

$bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
try {
  $resp = Invoke-RestMethod -Method Post -Uri 'https://onesignal.com/api/v1/notifications' `
    -Headers @{ Authorization = "Basic $key" } -ContentType 'application/json; charset=utf-8' -Body $bytes
  if ($null -ne $resp.recipients) {
    Write-Host ("Push gesendet an {0} Geraet(e). (ID {1})" -f $resp.recipients, $resp.id) -ForegroundColor Green
  } else {
    Write-Host 'Push-Anfrage abgeschickt.' -ForegroundColor Green
    ($resp | ConvertTo-Json -Depth 6) | Write-Host
  }
} catch {
  Write-Host '*** Push konnte NICHT gesendet werden ***' -ForegroundColor Red
  Write-Host $_.Exception.Message
  if ($_.ErrorDetails -and $_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message }
  Write-Host '(Pruefe: REST API Key korrekt? Segment "Subscribed Users" vorhanden? Schon jemand angemeldet?)'
}
