@echo off
setlocal
cd /d "%~dp0"
set "PUBLISH_WORKTREE=%CD%"
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

rem Git-Daten ausserhalb von OneDrive speichern. OneDrive-Platzhalter im
rem .git-Ordner koennen bei Git sonst "mmap failed" ausloesen.
set "PUBLISH_ROOT=%LOCALAPPDATA%\TSG08Roth\Git-Publish"
set "PUBLISH_CACHE=%PUBLISH_ROOT%\CompetitionRangliste-Setzliste"
set "PUBLISH_GIT=%PUBLISH_CACHE%\.git"
set "PUBLISH_REMOTE=https://TSGDarts@github.com/TSGDarts/CompetitionRangliste-Setzliste.git"

if not exist "%PUBLISH_GIT%\HEAD" (
  echo Richte die lokale Veroeffentlichung einmalig ein...
  if not exist "%PUBLISH_ROOT%" mkdir "%PUBLISH_ROOT%"
  if errorlevel 1 goto :sendefehler
  git clone --quiet --no-checkout "%PUBLISH_REMOTE%" "%PUBLISH_CACHE%"
  if errorlevel 1 goto :sendefehler
)

git -C "%PUBLISH_CACHE%" config user.name "Ferdinand Schneck"
git -C "%PUBLISH_CACHE%" config user.email "ferdinand.schneck@hotmail.de"

echo Gleiche den Stand sicher mit GitHub ab...
git -C "%PUBLISH_CACHE%" fetch --quiet origin main
if errorlevel 1 goto :sendefehler

git --git-dir="%PUBLISH_GIT%" --work-tree="%PUBLISH_WORKTREE%" reset --mixed origin/main 1>nul
if errorlevel 1 goto :sendefehler

git --git-dir="%PUBLISH_GIT%" --work-tree="%PUBLISH_WORKTREE%" add -A
if errorlevel 1 goto :sendefehler

git --git-dir="%PUBLISH_GIT%" --work-tree="%PUBLISH_WORKTREE%" diff --cached --quiet
if errorlevel 2 goto :sendefehler
if errorlevel 1 (
  git --git-dir="%PUBLISH_GIT%" --work-tree="%PUBLISH_WORKTREE%" commit -m "Rangliste/Setzliste aktualisiert" 1>nul
  if errorlevel 1 goto :sendefehler
) else (
  echo (keine Aenderungen - trotzdem senden)
)

echo Sende zu GitHub...
git --git-dir="%PUBLISH_GIT%" --work-tree="%PUBLISH_WORKTREE%" push -u origin HEAD:main
if errorlevel 1 goto :sendefehler

echo.
echo Fertig! Die Webseite ist in ca. 1 Minute aktuell:
echo   https://tsgdarts.github.io/CompetitionRangliste-Setzliste/
goto :ende

:sendefehler
echo.
echo *** Es gab ein Problem beim Senden. Siehe Meldung oben. ***
echo Tipp: Beim ERSTEN Mal fragt Git nach dem GitHub-Login ^(Browser oeffnet sich^).

:ende
echo.
pause
endlocal
