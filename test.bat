@echo off

rem Test
odin test . -out:stay-awake.exe -define:ODIN_TEST_THREADS=1
IF %ERRORLEVEL% NEQ 0 exit /b 1

exit /b 0