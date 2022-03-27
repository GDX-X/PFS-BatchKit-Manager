for %%f in (*.bin) do (
if not exist "%%~nf.cue" (
	echo FILE "%%~nf.bin" BINARY> %%~nf.cue
	echo   TRACK 01 MODE2/2352>> %%~nf.cue
	echo     INDEX 01 00:00:00>> %%~nf.cue
	)
)
