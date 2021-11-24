@echo off
setlocal enableDelayedExpansion
if "%~1" equ "" (
	echo no file passed
	echo pass -help to see the help message
	exit /b 1
)

for %%# in (-h -help /h /help) do (
	if "%~1" equ "%%~#" (
		echo generates SHA1 checksum for a given file
		(echo()
		echo USAGE:
		(echo()
		echo %~nx0 file [variable]
		(echo()
		echo variable string in which the generated checksum will be stored
		(echo()
		exit /b 0
	)
)

if not exist "%~1" (
	echo file %~1 does not exist
	exit /b 2
)

if exist "%~1\" (
	echo %~1 is a directory
	exit /b 3
)

for %%# in (certutil.exe) do (
	if not exist "%%~f$PATH:#" (
		echo no certutil installed
		echo for Windows XP professional and Windows 2003
		echo you need Windows Server 2003 Administration Tools Pack
		echo https://www.microsoft.com/en-us/download/details.aspx?id=3725
		exit /b 4
	)
)

set "SHA1="
for /f "skip=1 tokens=* delims=" %%# in ('certutil -hashfile "%~f1" SHA1') do (
	if not defined SHA1 (
		for %%Z in (%%#) do set "SHA1=!SHA1!%%Z"
	)
)

if "%~2" neq "" (
	endlocal && (
		set "%~2=%SHA1%"
	) 
) else (
	echo %SHA1%
)
endlocal
