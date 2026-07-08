@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
echo ============================================================
echo   Rangliste ^& Setzliste auf GitHub veroeffentlichen
echo ============================================================
echo.
git add -A
git commit -m "Rangliste/Setzliste aktualisiert" 1>nul 2>nul
if errorlevel 1 echo (keine Aenderungen an index.html - trotzdem senden)
echo Sende zu GitHub...
git push -u origin main
echo.
if errorlevel 1 (
  echo *** Es gab ein Problem beim Senden. Siehe Meldung oben. ***
  echo.
  pause
  exit /b 1
)
echo Fertig! Die Webseite ist in ca. 1 Minute aktuell:
echo   https://tsgdarts.github.io/CompetitionRangliste-Setzliste/
echo.
echo ------------------------------------------------------------
set "SENDEN=J"
set /p "SENDEN=Push-Benachrichtigung an alle Handys senden? [Enter=Ja / n=Nein]: "
if /I "!SENDEN!"=="J" (
  echo.
  echo Sende Push-Benachrichtigung...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0push-senden.ps1"
) else (
  echo Keine Push gesendet.
)
echo.
pause
