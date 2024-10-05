 cd /d "%~dp0"
 cd ..
 set rootpath=%cd%

	REM Cache
	echo Creating Partition Cache...
	"%rootpath%\BAT\hdl_dump" toc !@hdl_path!> "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt"
	if errorlevel 1 (
	"%rootpath%\BAT\Diagbox" gd 0c
	echo\
	echo\
	echo An error occurred^^!
	echo Playstation 2 HDD not recognized^! Try to repair it with HDD Checker. Or format the HDD with wLaunchELF
	"%rootpath%\BAT\Diagbox" gd 0f
	del /Q "%rootpath%\BAT\__Cache\*" >nul 2>&1
	echo\
	echo\
	pause
	) else (
	
	echo Creating Game Cache...
	"%rootpath%\BAT\hdl_dump" hdl_toc !@hdl_path!> "%rootpath%\BAT\__Cache\PS2_GAMES_HDD.txt"
	
	REM PS2 GAMES PARTITION
	"%rootpath%\BAT\busybox" sed "s/\(.\{46\}\)./\1/" "%rootpath%\BAT\__Cache\PS2_GAMES_HDD.txt" | "%rootpath%\BAT\busybox" sed "1d; $ d" | "%rootpath%\BAT\busybox" cut -c35-500 > "%rootpath%\TMP\PS2GAMES.txt"
	"%rootpath%\BAT\busybox" grep -e "0x1337" "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt" | "%rootpath%\BAT\busybox" cut -c30-250 | "%rootpath%\BAT\busybox" sed -e "s/^/|/" > "%rootpath%\TMP\PARTITION_HDL.txt"
	"%rootpath%\BAT\busybox" paste -d " " "%rootpath%\TMP\PS2GAMES.txt" "%rootpath%\TMP\PARTITION_HDL.txt" | "%rootpath%\BAT\busybox" sort -k2 > "%rootpath%\BAT\__Cache\PARTITION_HDL_GAME.txt" & "%rootpath%\BAT\busybox" sed -i "s/ |/|/g" "%rootpath%\BAT\__Cache\PARTITION_HDL_GAME.txt"
	
	REM PS1 GAMES PARTITION
	"%rootpath%\BAT\busybox" grep -e "\.POPS\." "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt" | "%rootpath%\BAT\busybox" cut -c30-250 | "%rootpath%\BAT\busybox" cut -c4-13 | "%rootpath%\BAT\busybox" sed -e "s/-/_/g; s/.\{8\}/&./" > "%rootpath%\TMP\POPS_GAMES_ID.txt"
	"%rootpath%\BAT\busybox" grep -e "\.POPS\." "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt" | "%rootpath%\BAT\busybox" cut -c30-250 | "%rootpath%\BAT\busybox" sed -e "s/^/|/" > "%rootpath%\TMP\PARTITION_POPS.txt"
	
	for /f "usebackq" %%A in ("%rootpath%\TMP\POPS_GAMES_ID.txt") do (
	"%rootpath%\BAT\busybox" grep "%%A" "%rootpath%\BAT\TitlesDB\TitlesDB_PS1_English.txt" >nul
		if errorlevel 1 (echo %%A __UNKNOW>> "%rootpath%\TMP\PS1GAMES.txt") else ("%rootpath%\BAT\busybox" grep "%%A" "%rootpath%\BAT\TitlesDB\TitlesDB_PS1_English.txt" >> "%rootpath%\TMP\PS1GAMES.txt")
		"%rootpath%\BAT\busybox" sed -i "s/%%A __UNKNOW//g" "%rootpath%\TMP\PS1GAMES.txt"
	)
	if not exist "%rootpath%\TMP\PS1GAMES.txt" (type nul> "%rootpath%\BAT\__Cache\PARTITION_POPS_GAME.txt") else ("%rootpath%\BAT\busybox" paste -d " " "%rootpath%\TMP\PS1GAMES.txt" "%rootpath%\TMP\PARTITION_POPS.txt" 2>&1 | "%rootpath%\BAT\busybox" sort -k2 > "%rootpath%\BAT\__Cache\PARTITION_POPS_GAME.txt" & "%rootpath%\BAT\busybox" sed -i "s/ |/|/g; s/^|//g; s/\^//g" "%rootpath%\BAT\__Cache\PARTITION_POPS_GAME.txt")
	
	REM APPS PARTITION
	"%rootpath%\BAT\busybox" grep -e "PP.APPS-" "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt" | "%rootpath%\BAT\busybox" cut -c30-250 | "%rootpath%\BAT\busybox" cut -c4-13 | "%rootpath%\BAT\busybox" sed -e "s/-/_/g; s/.\{8\}/&./" > "%rootpath%\TMP\APPS_ID.txt"
	"%rootpath%\BAT\busybox" grep -e "PP.APPS-" "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt" | "%rootpath%\BAT\busybox" cut -c30-250 | "%rootpath%\BAT\busybox" sed -e "s/^/|/" > "%rootpath%\TMP\PARTITION_APPS.txt"
	
	for /f "usebackq" %%A in ("%rootpath%\TMP\APPS_ID.txt") do (
	"%rootpath%\BAT\busybox" grep "%%A" "%rootpath%\BAT\TitlesDB\TitlesDB_APP.txt" >nul
		if errorlevel 1 (echo %%A __UNKNOW>> "%rootpath%\TMP\APPS.txt") else ("%rootpath%\BAT\busybox" grep "%%A" "%rootpath%\BAT\TitlesDB\TitlesDB_APP.txt" >> "%rootpath%\TMP\APPS.txt")
		"%rootpath%\BAT\busybox" sed -i "s/%%A __UNKNOW//g" "%rootpath%\TMP\APPS.txt"
	)
	if not exist "%rootpath%\TMP\APPS.txt" (type nul> "%rootpath%\BAT\__Cache\PARTITION_APPS.txt") else ("%rootpath%\BAT\busybox" paste -d " " "%rootpath%\TMP\APPS.txt" "%rootpath%\TMP\PARTITION_APPS.txt" 2>&1 | "%rootpath%\BAT\busybox" sort -k2 > "%rootpath%\BAT\__Cache\PARTITION_APPS.txt" & "%rootpath%\BAT\busybox" sed -i "s/ |/|/g; s/^|//g; s/\^//g" "%rootpath%\BAT\__Cache\PARTITION_APPS.txt")
   
   REM Total Size Used/Available
   "%rootpath%\BAT\busybox" grep "Total slice size:" "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt" > "%rootpath%\TMP\Total_Used_Available.txt"
   for /f "usebackq tokens=6,8" %%s in ("%rootpath%\TMP\Total_Used_Available.txt") do set "TotalHDD_Used=%%s" & set TotalHDD_Available=%%t
   for %%s in (!TotalHDD_Used! !TotalHDD_Available!) do (
   if "%%s"=="!TotalHDD_Used:~0,-1!" set /A TypePartSize=!TotalHDD_Used:~0,-3!
   if "%%s"=="!TotalHDD_Available!" set /A TypePartSize=!TotalHDD_Available:~0,-2!
   
   if !TypePartSize! LSS 1000 (set TypePartSize=!TypePartSize!MB) else (set /a "value=!TypePartSize! / 1000" & set /a "remainder=!TypePartSize! %% 1000" & set TypePartSize=!value!.!remainder!GB)
   if "%%s"=="!TotalHDD_Used:~0,-1!" set @TotalHDD_Used=!TypePartSize!
   if "%%s"=="!TotalHDD_Available!" set @TotalHDD_Available=!TypePartSize!
   )

	REM Total Percentage Size Used/Available 
	set /A percentage=!TotalHDD_Used:~0,-3! * 1000/ !TotalHDD_Size!
	set @TotalHDD_Percentage=!percentage:~0,-1!.!percentage:~-2!%%%%
	
    REM Current OPL Resource Partition
	echo device !@pfsshell_path! > "%rootpath%\TMP\PFS-OPLPART.txt"
	echo mount __common >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo cd OPL >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo lcd "%rootpath%\TMP" >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo get conf_hdd.cfg >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo cd .. >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo umount >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo exit >> "%rootpath%\TMP\PFS-OPLPART.txt"
	type "%rootpath%\TMP\PFS-OPLPART.txt" | "%rootpath%\BAT\pfsshell" >nul 2>&1
	
	if not exist "%rootpath%\TMP\conf_hdd.cfg" (set OPLPART=__common) else ("%rootpath%\BAT\busybox" grep "hdd_partition=" "%rootpath%\TMP\conf_hdd.cfg" | "%rootpath%\BAT\busybox" sed "s/^.*=//" > "%rootpath%\TMP\OPLPART.txt" & set /P OPLPART=<"%rootpath%\TMP\OPLPART.txt")
	echo hdd_partition=!OPLPART!> "%rootpath%\HDD-OSD\__common\OPL\conf_hdd.cfg"
	if !OPLPART!==+OPL (set "CUSTOM_OPLPART=") else (set "CUSTOM_OPLPART=Yes")
	
	if not exist "%rootpath%\TMP\conf_hdd.cfg" (
	echo device !@pfsshell_path! > "%rootpath%\TMP\PFS-OPLPART.txt"
	echo mount __common >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo mkdir OPL >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo cd OPL >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo lcd "%rootpath%\HDD-OSD\__common\OPL" >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo put conf_hdd.cfg >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo cd .. >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo umount >> "%rootpath%\TMP\PFS-OPLPART.txt"
	echo exit >> "%rootpath%\TMP\PFS-OPLPART.txt"
	type "%rootpath%\TMP\PFS-OPLPART.txt" | "%rootpath%\BAT\pfsshell" >nul 2>&1
	)
	
	REM Check if it's a PSX DESR HDD
	echo device !@pfsshell_path! > "%rootpath%\TMP\pfs-psx.txt"
	echo mount __system >> "%rootpath%\TMP\pfs-psx.txt"
	echo lcd "%rootpath%\TMP" >> "%rootpath%\TMP\pfs-psx.txt"
	echo get main.xml >> "%rootpath%\TMP\pfs-psx.txt"
	echo get psxmain.xml >> "%rootpath%\TMP\pfs-psx.txt"
	echo umount >> "%rootpath%\TMP\pfs-psx.txt"
	echo exit >> "%rootpath%\TMP\pfs-psx.txt"
	type "%rootpath%\TMP\pfs-psx.txt" | "%rootpath%\BAT\pfsshell" >nul 2>&1
	if exist "%rootpath%\TMP\psxmain.xml" ren "%rootpath%\TMP\psxmain.xml" main.xml
	if exist "%rootpath%\TMP\main.xml" (set @PSX2DESR_HDD=Yes) else (set @PSX2DESR_HDD=No)
	
	REM Check if PSBBN is installed
	echo device !@pfsshell_path! > "%rootpath%\TMP\PFS-PSBBN.txt"
	echo mount __system >> "%rootpath%\TMP\PFS-PSBBN.txt"
	echo ls >> "%rootpath%\TMP\PFS-PSBBN.txt"
	echo umount >> "%rootpath%\TMP\PFS-PSBBN.txt"
	echo exit >> "%rootpath%\TMP\PFS-PSBBN.txt"
	type "%rootpath%\TMP\PFS-PSBBN.txt" | "%rootpath%\BAT\pfsshell" 2>&1 | "%rootpath%\BAT\busybox" grep -m1 -o "p2lboot" > "%rootpath%\TMP\hdd-p2lboot.txt" & set /P @hdd_p2lboot=<"%rootpath%\TMP\hdd-p2lboot.txt"
	IF "!@hdd_p2lboot!"=="p2lboot" (set @PSBBN_Installed=Yes) else (set @PSBBN_Installed=No)
	
	echo set @hdl_path=!@hdl_path!> "%rootpath%\BAT\__Cache\HDD.BAT"
	echo set @pfsshell_path=!@pfsshell_path!>> "%rootpath%\BAT\__Cache\HDD.BAT"
	echo set @NumberPS2HDD=!@NumberPS2HDD!>> "%rootpath%\BAT\__Cache\HDD.BAT"
	echo set @ModelePS2HDD=!@ModelePS2HDD!>> "%rootpath%\BAT\__Cache\HDD.BAT"
	echo set @TotalHDD_Size=!@TotalHDD_Size!>> "%rootpath%\BAT\__Cache\HDD.BAT"
	echo set TotalHDD_Size=!TotalHDD_Size!>> "%rootpath%\BAT\__Cache\HDD.BAT"
	echo set @TotalHDD_Used=!@TotalHDD_Used!>> "%rootpath%\BAT\__Cache\HDD.BAT"
	echo set @TotalHDD_Available=!@TotalHDD_Available!>> "%rootpath%\BAT\__Cache\HDD.BAT"
	echo set @TotalHDD_Percentage=!@TotalHDD_Percentage!>> "%rootpath%\BAT\__Cache\HDD.BAT"
	echo set @PSX2DESR_HDD=!@PSX2DESR_HDD!>> "%rootpath%\BAT\__Cache\HDD.BAT"
	echo set @PSBBN_Installed=!@PSBBN_Installed!>> "%rootpath%\BAT\__Cache\HDD.BAT"
	
	echo set OPLPART=!OPLPART!>> "%rootpath%\BAT\__Cache\HDD.BAT"
	echo set CUSTOM_OPLPART=!CUSTOM_OPLPART!>> "%rootpath%\BAT\__Cache\HDD.BAT"
	)