@echo off

set BUILD_PARAMS=-strict-style -vet

rem Build
odin build . -out:stay-awake.exe %BUILD_PARAMS%
IF %ERRORLEVEL% NEQ 0 exit /b 1

exit /b 0