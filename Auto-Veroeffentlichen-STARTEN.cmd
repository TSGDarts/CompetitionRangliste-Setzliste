@echo off
title TSG Competition - Auto-Veroeffentlichen
cd /d "%~dp0"
echo Starte den Auto-Veroeffentlichen-Helfer ...
echo (Dieses Fenster offen lassen. Zum Beenden einfach schliessen.)
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0auto-push-watcher.ps1"
echo.
echo Der Helfer wurde beendet.
pause
