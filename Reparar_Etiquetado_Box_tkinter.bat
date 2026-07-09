@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Reparar_Etiquetado_Box_tkinter.ps1"
if errorlevel 1 (
    echo.
    echo ERROR: No se pudo reparar Etiquetado Box Salazon.
    pause
    exit /b 1
)

echo.
echo Reparacion completada.
pause
