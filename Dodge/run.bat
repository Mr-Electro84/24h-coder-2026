@echo off

START /MIN CMD.EXE /C powershell -ExecutionPolicy Bypass -File ".\compile-game.ps1"
game-launcher.bat # For launching the game without a cmd window.

pause