@ECHO OFF
ECHO Y | powershell.exe get-date -format {yyyy/MM/dd}
if %ERRORLEVEL% neq 0 (
exit 1
)
