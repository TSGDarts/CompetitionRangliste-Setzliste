# Auto-Veroeffentlichen: ueberwacht index.html. Sobald die App die Datei neu schreibt
# ("Webseite aktualisieren"), wird automatisch zu GitHub hochgeladen.
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $dir
Add-Type -AssemblyName System.Windows.Forms | Out-Null

$fsw = New-Object System.IO.FileSystemWatcher
$fsw.Path = $dir
$fsw.Filter = 'index.html'
$fsw.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::Size

Write-Host "==========================================================="
Write-Host "  TSG Competition - Auto-Veroeffentlichen laeuft"
Write-Host "  Dieses Fenster offen lassen (darfst es minimieren)."
Write-Host ""
Write-Host "  Ablauf: In der App auf 'Webseite aktualisieren' klicken."
Write-Host "  -> laedt automatisch zu GitHub hoch."
Write-Host "==========================================================="
Write-Host ""

while ($true) {
  $res = $fsw.WaitForChanged([System.IO.WatcherChangeTypes]::Changed, 3600000)
  if ($res.TimedOut) { continue }
  Start-Sleep -Milliseconds 2000    # warten, bis die App fertig geschrieben hat

  Write-Host ("[" + (Get-Date -Format 'HH:mm:ss') + "] Aenderung erkannt - sende zu GitHub ...")
  git add -A 2>&1 | Out-Null
  git commit -m "Rangliste/Setzliste aktualisiert" 2>&1 | Out-Null
  git push origin main 2>&1 | Out-Host
  $ok = ($LASTEXITCODE -eq 0)

  if ($ok) {
    Write-Host "Hochgeladen."
    [System.Windows.Forms.MessageBox]::Show(
      "Die Webseite wurde aktualisiert und hochgeladen." + [Environment]::NewLine +
      "In ca. 1 Minute ist sie online aktuell.",
      "TSG Competition - Veroeffentlicht", [System.Windows.Forms.MessageBoxButtons]::OK,
      [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
  } else {
    Write-Host "*** Upload-Problem - siehe Git-Meldung oben. ***"
    [System.Windows.Forms.MessageBox]::Show(
      "Beim Hochladen zu GitHub gab es ein Problem. Siehe das schwarze Fenster.",
      "TSG Competition - Fehler", [System.Windows.Forms.MessageBoxButtons]::OK,
      [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
  }
  Write-Host ""
  Start-Sleep -Seconds 3    # Cooldown gegen doppelte Datei-Ereignisse
}
