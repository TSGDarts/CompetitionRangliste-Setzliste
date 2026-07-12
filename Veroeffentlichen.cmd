@echo off
cd /d "%~dp0"
echo ============================================================
echo   Rangliste ^& Setzliste auf GitHub veroeffentlichen
echo ============================================================
echo.
where git >nul 2>nul
if errorlevel 1 (
  echo *** Git ist auf diesem Rechner nicht installiert. ***
  echo.
  echo So richtest du diesen Rechner EINMALIG ein:
  echo   1^) Git fuer Windows installieren:  https://git-scm.com/download/win
  echo      ^(einfach durchklicken - die Standard-Einstellungen sind ok^)
  echo   2^) Dieses Fenster schliessen und "Veroeffentlichen" erneut starten.
  echo   3^) Beim ERSTEN Senden oeffnet sich der Browser fuer den GitHub-Login -
  echo      mit dem TSGDarts-GitHub-Konto anmelden. Danach laeuft alles automatisch.
  echo.
  pause
  exit /b
)
git add -A
git commit -m "Rangliste/Setzliste aktualisiert" 1>nul 2>nul
if errorlevel 1 echo (keine Aenderungen an index.html - trotzdem senden)
echo Sende zu GitHub...
git push -u origin main
if errorlevel 1 (
  echo.
  echo *** Es gab ein Problem beim Senden. Siehe Meldung oben. ***
  echo Tipp: Beim ERSTEN Mal fragt Git nach dem GitHub-Login ^(Browser oeffnet sich^).
) else (
  echo.
  echo Fertig! Die Webseite ist in ca. 1 Minute aktuell:
  echo   https://tsgdarts.github.io/CompetitionRangliste-Setzliste/
)
echo.
pause
