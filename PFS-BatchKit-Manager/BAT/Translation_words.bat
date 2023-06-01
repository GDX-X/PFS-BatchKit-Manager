REM This file is only used to translate certain word
chcp 1252 >nul 2>&1

if %language%==french echo "!RELEASETMP!"| "%rootpath%\BAT\busybox" sed -e "s/January/Janvier/g; s/February/Février/g; s/March/Mars/g; s/April/Avril/g; s/May/Mai/g; s/June/Juin/g; s/July/Juillet/g; s/August/Aout/g; s/September/Septembre/g; s/October/Octobre/g; s/November/Novembre/g; s/December/Décembre/g" | "%rootpath%\BAT\busybox" sed -e "s/\""//g" > "%rootpath%\TMP\RELEASE_%language%.txt" & set /P RELEASETMP=<"%rootpath%\TMP\RELEASE_%language%.txt"




chcp 65001 >nul 2>&1