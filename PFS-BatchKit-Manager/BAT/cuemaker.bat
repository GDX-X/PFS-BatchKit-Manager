for %%f in (*.bin) do (

	setlocal DisableDelayedExpansion
	set filecuename=%%f
    set fcuename=%%~nf
    setlocal EnableDelayedExpansion
	
if not exist "!fcuename!.cue" (
	echo FILE "!fcuename!.bin" BINARY> !fcuename!.cue
	echo   TRACK 01 MODE2/2352>> !fcuename!.cue
	echo     INDEX 01 00:00:00>> !fcuename!.cue
	)
 endlocal
endlocal
)
