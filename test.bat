@echo off

rem Test
odin test . -out:stay-awake-test.exe -define:ODIN_TEST_THREADS=1
IF %ERRORLEVEL% NEQ 0 exit /b 1

del .\stay-awake-test.exe

exit /b 0