@echo off
for /f "delims=" %%i in (install_apps.txt) do (
    %%i
)