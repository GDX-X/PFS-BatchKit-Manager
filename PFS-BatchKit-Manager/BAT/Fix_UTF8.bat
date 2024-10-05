@echo off

chcp 65001 >nul 2>&1
if not defined dbtitleTMP set /P dbtitleTMP=<"%rootpath%\TMP\NodbtitleTMP.txt"
if exist "%rootpath%\TMP\!gameid2!\RELEASE.txt" set /P RELEASETMP=<"%rootpath%\TMP\!gameid2!\RELEASE.txt"
if exist "%rootpath%\TMP\!gameid2!\DEVELOPER.txt" set /P DEVELOPERTMP=<"%rootpath%\TMP\!gameid2!\DEVELOPER.txt"
if exist "%rootpath%\TMP\!gameid2!\PUBLISHER.txt" set /P PUBLISHERTMP=<"%rootpath%\TMP\!gameid2!\PUBLISHER.txt"
if exist "%rootpath%\TMP\!gameid2!\GENRE.txt" set /P GENRETMP=<"%rootpath%\TMP\!gameid2!\GENRE.txt"
if !PartitionType!==APP if exist "%rootpath%\TMP\!gameid2!\Contentweb.txt" set /P Contentweb=<"%rootpath%\TMP\!gameid2!\Contentweb.txt"

if !PartitionType!==PS1 chcp 1252 >nul 2>&1
	
	chcp 1252 >nul 2>&1
	if exist "%rootpath%\TMP\!gameid2!\RELEASE.txt" (
	if "!DBLang!"=="Fr" "%rootpath%\BAT\busybox" sed -i "s/Janvier/January/g; s/Février/February/g; s/Mars/March/g; s/Avril/April/g; s/Mai/May/g; s/Juin/June/g; s/Juillet/July/g; s/Aout/August/g; s/Septembre/September/g; s/Octobre/October/g; s/Novembre/November/g; s/Décembre/December/g" "%rootpath%\TMP\!gameid2!\RELEASE.txt"
	if "!DBLang!"=="De" "%rootpath%\BAT\busybox" sed -i "s/Januar/January/g; s/Februar/February/g; s/März/March/g; s/April/April/g; s/Mai/May/g; s/Juni/June/g; s/Juli/July/g; s/August/August/g; s/September/September/g; s/Oktober/October/g; s/November/November/g; s/Dezember/December/g" "%rootpath%\TMP\!gameid2!\RELEASE.txt"
	if "!DBLang!"=="Es" "%rootpath%\BAT\busybox" sed -i "s/Enero/January/g; s/Febrero/February/g; s/Marzo/March/g; s/Abril/April/g; s/Mayo/May/g; s/Junio/June/g; s/Julio/July/g; s/Agosto/August/g; s/Septiembre/September/g; s/Octubre/October/g; s/Noviembre/November/g; s/Diciembre/December/g" "%rootpath%\TMP\!gameid2!\RELEASE.txt"
	if "!DBLang!"=="It" "%rootpath%\BAT\busybox" sed -i "s/Gennaio/January/g; s/Febbraio/February/g; s/Marzo/March/g; s/Aprile/April/g; s/Maggio/May/g; s/Giugno/June/g; s/Luglio/July/g; s/Agosto/August/g; s/Settembre/September/g; s/Ottobre/October/g; s/Novembre/November/g; s/Dicembre/December/g" "%rootpath%\TMP\!gameid2!\RELEASE.txt"
	if "!DBLang!"=="Pt" "%rootpath%\BAT\busybox" sed -i "s/Janeiro/January/g; s/Fevereiro/February/g; s/Março/March/g; s/Abril/April/g; s/Maio/May/g; s/Junho/June/g; s/Julho/July/g; s/Agosto/August/g; s/Setembro/September/g; s/Outubro/October/g; s/Novembro/November/g; s/Dezembro/December/g" "%rootpath%\TMP\!gameid2!\RELEASE.txt"
	)
	if !PartitionType!==PS2 chcp 65001 >nul 2>&1
	
	REM PSBBN Original Date format
	if defined RELEASETMP "%rootpath%\BAT\busybox" sed -E "s/January/01/g; s/February/02/g; s/March/03/g; s/April/04/g; s/May/05/g; s/June/06/g; s/July/07/g; s/August/08/g; s/September/09/g; s/October/10/g; s/November/11/g; s/December/12/g" "%rootpath%\TMP\!gameid2!\RELEASE.txt" > "%rootpath%\TMP\RELEASEBBN.txt" & "%rootpath%\BAT\busybox" sed -i "s/^\([1-9]\) /0\1 /g; s/ //g; s/\(.\{2\}\)\(.\{2\}\)\(.\{4\}\)/\3\2\1/" "%rootpath%\TMP\RELEASEBBN.txt" & set /P RELEASEBBN=<"%rootpath%\TMP\RELEASEBBN.txt"

	echo Title:     [!dbtitleTMP!]
	echo Gameid:    [!gameid2!]
	echo Region:    [!region!]
	echo Release:   [!RELEASETMP!]
	echo Developer: [!DEVELOPERTMP!]
	echo Publisher: [!PUBLISHERTMP!]
	echo Genre:     [!GENRETMP!]
if !PartitionType!==APP echo Source:    [!Contentweb!]
