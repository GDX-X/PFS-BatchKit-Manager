 cd /d "%~dp0"
 cd ..
 set rootpath=%cd%

 echo Creating Partition Cache...
 "%rootpath%\BAT\hdl_dump" toc %@hdl_path% > "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt"
 echo Creating Game Cache...
 "%rootpath%\BAT\hdl_dump" hdl_toc %@hdl_path% > "%rootpath%\BAT\__Cache\PS2_GAMES_HDD.txt"

 REM PS2 GAMES PARTITION
 "%rootpath%\BAT\busybox" sed "s/\(.\{46\}\)./\1/" "%rootpath%\BAT\__Cache\PS2_GAMES_HDD.txt" | "%rootpath%\BAT\busybox" sed "1d; $ d" | "%rootpath%\BAT\busybox" cut -c35-500 > "%rootpath%\TMP\PS2GAMES.txt"
 "%rootpath%\BAT\busybox" grep -e "0x1337" "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt" | "%rootpath%\BAT\busybox" cut -c30-250 | "%rootpath%\BAT\busybox" sed -e "s/^/|/" > "%rootpath%\TMP\PARTITION_HDL.txt"
 "%rootpath%\BAT\busybox" paste -d " " "%rootpath%\TMP\PS2GAMES.txt" "%rootpath%\TMP\PARTITION_HDL.txt" | "%rootpath%\BAT\busybox" sort -k2 > "%rootpath%\BAT\__Cache\PARTITION_HDL_GAME.txt" & "%rootpath%\BAT\busybox" sed -i "s/ |/|/g" "%rootpath%\BAT\__Cache\PARTITION_HDL_GAME.txt"
 
 REM PS1 GAMES PARTITION
 "%rootpath%\BAT\busybox" grep -e "\.POPS\." "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt" | "%rootpath%\BAT\busybox" cut -c30-250 | "%rootpath%\BAT\busybox" cut -c4-13 | "%rootpath%\BAT\busybox" sed -e "s/-/_/g; s/.\{8\}/&./" > "%rootpath%\TMP\POPS_GAMES_ID.txt"
 "%rootpath%\BAT\busybox" grep -e "\.POPS\." "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt" | "%rootpath%\BAT\busybox" cut -c30-250 | "%rootpath%\BAT\busybox" sed -e "s/^/|/" > "%rootpath%\TMP\PARTITION_POPS.txt"

 for /f "usebackq" %%A  in ("%rootpath%\TMP\POPS_GAMES_ID.txt") do (
 "%rootpath%\BAT\busybox" grep "%%A" "%rootpath%\BAT\TitlesDB\TitlesDB_PS1_English.txt" >nul
	if errorlevel 1 (echo %%A __UNKNOW>> "%rootpath%\TMP\PS1GAMES.txt") else ("%rootpath%\BAT\busybox" grep "%%A" "%rootpath%\BAT\TitlesDB\TitlesDB_PS1_English.txt" >> "%rootpath%\TMP\PS1GAMES.txt")
    "%rootpath%\BAT\busybox" sed -i "s/%%A __UNKNOW//g" "%rootpath%\TMP\PS1GAMES.txt"
   )
 "%rootpath%\BAT\busybox" paste -d " " "%rootpath%\TMP\PS1GAMES.txt" "%rootpath%\TMP\PARTITION_POPS.txt" 2>&1 | "%rootpath%\BAT\busybox" sort -k2 > "%rootpath%\BAT\__Cache\PARTITION_POPS_GAME.txt" & "%rootpath%\BAT\busybox" sed -i "s/ |/|/g; s/^|//" "%rootpath%\BAT\__Cache\PARTITION_POPS_GAME.txt"

 REM APPS PARTITION
 "%rootpath%\BAT\busybox" grep -e "PP.APPS-" "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt" | "%rootpath%\BAT\busybox" cut -c30-250 | "%rootpath%\BAT\busybox" cut -c4-13 | "%rootpath%\BAT\busybox" sed -e "s/-/_/g; s/.\{8\}/&./" > "%rootpath%\TMP\APPS_ID.txt"
 "%rootpath%\BAT\busybox" grep -e "PP.APPS-" "%rootpath%\BAT\__Cache\PARTITION_PS2HDD.txt" | "%rootpath%\BAT\busybox" cut -c30-250 | "%rootpath%\BAT\busybox" sed -e "s/^/|/" > "%rootpath%\TMP\PARTITION_APPS.txt"
 
 for /f "usebackq" %%A  in ("%rootpath%\TMP\APPS_ID.txt") do (
 "%rootpath%\BAT\busybox" grep "%%A" "%rootpath%\BAT\TitlesDB\TitlesDB_APPS.txt" >nul
	if errorlevel 1 (echo %%A __UNKNOW>> "%rootpath%\TMP\APPS.txt") else ("%rootpath%\BAT\busybox" grep "%%A" "%rootpath%\BAT\TitlesDB\TitlesDB_APPS.txt" >> "%rootpath%\TMP\APPS.txt")
    "%rootpath%\BAT\busybox" sed -i "s/%%A __UNKNOW//g" "%rootpath%\TMP\APPS.txt"
   )
 "%rootpath%\BAT\busybox" paste -d " " "%rootpath%\TMP\APPS.txt" "%rootpath%\TMP\PARTITION_APPS.txt" 2>&1 | "%rootpath%\BAT\busybox" sort -k2 > "%rootpath%\BAT\__Cache\PARTITION_APPS.txt" & "%rootpath%\BAT\busybox" sed -i "s/ |/|/g; s/^|//" "%rootpath%\BAT\__Cache\PARTITION_APPS.txt"