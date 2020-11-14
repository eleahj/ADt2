@ECHO off
SETLOCAL
CALL :find_dp0

IF EXIST "%dp0%\perl.exe" (
  SET "_prog=%dp0%\perl.exe"
) ELSE (
  SET "_prog=perl"
  SET PATHEXT=%PATHEXT:;.JS;=;%
)

"%_prog%"  "%dp0%\..\cloc\lib\cloc" %*
ENDLOCAL
EXIT /b %errorlevel%
:find_dp0
SET dp0=%~dp0
EXIT /b
