REM Fix Gameid/Serial visible on covers or disc but no internal ELF/ This solution allows you to install games that have the same name as the original

REM PAL
REM SCES = Published by Sony Computer Entertainment Europe (with one or two exceptions it seems)
REM SCED = SCEE published demos
REM SLES = Third/second party published games
REM SLED = Third/second party published demos
REM PBPX = In some pack-in demos

REM NTSC-U/C = NTSC: USA/Canada
REM SCUS = Sony Computer USA/Canada Software
REM SLUS = Sony Licensed USA/Canada Software
REM LSP = LightSpan Sofware PlayStation

REM NTSC-J
REM SCPS = Sony Computer PlayStation Software
REM SLPS = Sony Licensed PlayStation Software
REM SLPM = Sony Computer PlayStation ???
REM SIPS = Sony ??? PlayStation Software


REM This game ID does not exist I created it to avoid a conflict with the some title
REM SLUD = Sony Licensed USA/Canada Demos
REM SLUG = Sony Licensed USA/Canada Greatest Hits
REM SLUX = Sony Licensed USA/Canada Multi Disc

REM SLPD = Sony Licensed Asia Demos
REM SLPG = Sony Licensed PlayStation Greatest Hits

REM ######################################################################################################################################################

if !GameInstall!==PS2 (

if "!filename!"=="!fname!.iso" "!rootpath!\BAT\busybox" md5sum "!fname!.iso" | "!rootpath!\BAT\busybox" grep -o "[0-9a-f]\{32\}" > "!rootpath!\TMP\MD5.txt" & set /p MD5=<"!rootpath!\TMP\MD5.txt"
if "!filename!"=="!fname!.cue" "!rootpath!\BAT\busybox" md5sum "!fname!.bin" | "!rootpath!\BAT\busybox" grep -o "[0-9a-f]\{32\}" > "!rootpath!\TMP\MD5.txt" & set /p MD5=<"!rootpath!\TMP\MD5.txt"
REM if "!filename!"=="!fname!.zso" "!rootpath!\BAT\busybox" md5sum "!fname!.zso" | "!rootpath!\BAT\busybox" grep -o "[0-9a-f]\{32\}" > "!rootpath!\TMP\MD5.txt" & set /p MD5=<"!rootpath!\TMP\MD5.txt"

REM hdl dump needs the iso to get the information
if "!filename!"=="!fname!.zso" "!rootpath!\BAT\busybox" md5sum "!fname!.iso" | "!rootpath!\BAT\busybox" grep -o "[0-9a-f]\{32\}" > "!rootpath!\TMP\MD5.txt" & set /p MD5=<"!rootpath!\TMP\MD5.txt"

REM SLUS_202.73 Namco Museum
REM BIN
if !MD5!==ca7ec4f6fa440558697f26bbd956c647 set "dbtitle=Namco Museum" & set "dbtitleosd=Namco Museum"
REM ISO
if !MD5!==f141912e121045484a25023419802278 set "dbtitle=Namco Museum" & set "dbtitleosd=Namco Museum"

REM SLUS_202.73 Namco Museum 50th Anniversary
REM ISO
if !MD5!==f9b3ba7499d9260680a2fadca9947888 set "dbtitle=Namco Museum 50th Anniversary" & set "dbtitleosd=Namco Museum 50th Anniversary" & set gameid=SLUG_202.73

REM SLUS_206.43 Soulcalibur II
REM ISO
if !MD5!==a303fbef9858a5049f5c3414008c6b61 set "dbtitle=Soulcalibur II" & set "dbtitleosd=Soulcalibur II"

REM SLUS_206.43 Namco Transmission v1.03
REM ISO
if !MD5!==8bf82a34c037bcff2d19306d118f9515 set "dbtitle=Namco Transmission v1.03" & set "dbtitleosd=Namco Transmission v1.03" & set gameid=SLUD_206.43

REM SLPS_256.96 Mermaid Prism
REM ISO
REM if !MD5!==5141ca0b8d1d1d441f88b3b413eed0db set "dbtitle=Mermaid Prism" & set "dbtitleosd=Mermaid Prism"

REM SLPS_256.96 Simple 2000 Series Vol. 122: Onna no Ko Sen'you: The Ningyo-hime Monogatari: Mermaid Prism
REM ISO
if !MD5!==f7706130022dce36da475df34b40209c set gameid=SLPS_258.33

REM SLPS_253.34 Shadow Hearts II (Disc 1)
REM ISO
REM if !MD5!==320098d6c396ed02186b2f155b19bf27 set "dbtitle=Shadow Hearts II (Disc 1)" & set "dbtitleosd=Shadow Hearts II (Disc 1)"

REM SLPS_253.34 Shadow Hearts II (Disc 2)
REM ISO
if !MD5!==649992c195c015481a4dcb7b36c9a0a0 set gameid=SLPS_253.35

REM SLPS_253.17 Shadow Hearts II (Disc 2) (Gentei DX Pack)
REM ISO
if !MD5!==800524756b4195b6749bfd8e2650ed20 set gameid=SLPS_253.18

REM SLPS_732.14 Shadow Hearts II: Director's Cut (Disc 1)
REM ISO
REM if !MD5!==f83c85907ec71982609fd34c05abfe73 set "dbtitle=Shadow Hearts II: Director's Cut (Disc 1)" & set "dbtitleosd=Shadow Hearts II: Director's Cut (Disc 1)"

REM SLPS_732.14 Shadow Hearts II: Director's Cut (Disc 2)
REM ISO
if !MD5!==962ff1f3450e86a75d0d6c04f687eef1 set gameid=SLPS_732.15

REM SLPM_550.82 Shin Sangoku Musou 5 Special (Disc 1)
REM ISO
REM if !MD5!==504da6151ea1ebe92744a8a350b9e62a set "dbtitle=Shin Sangoku Musou 5 Special (Disc 1)" & set "dbtitleosd=Shin Sangoku Musou 5 Special (Disc 1)"

REM SLPM_550.82 Shin Sangoku Musou 5 Special (Disc 2)
REM ISO
if !MD5!==acdd7c17dff07989da0b8978ee17131a set gameid=SLPM_550.83

REM SLPM_654.38 Star Ocean: Till the End of Time: Director's Cut (Disc 1)
REM ISO
REM if !MD5!==a10510197fddabeab721ccdcf177d634 set "dbtitle=Star Ocean: Till the End of Time: Director's Cut (Disc 1)" & set "dbtitleosd=Star Ocean: Till the End of Time: Director's Cut (Disc 1)"

REM SLPM_654.38 Star Ocean: Till the End of Time: Director's Cut (Disc 2)
REM ISO
if !MD5!==209ac9e271595451b16e1b10ea954f8e set gameid=SLPM_654.39



REM Uselesse Beta
REM REM SCES_539.50 Formula One 06
REM REM ISO
REM if !MD5!==b72851d1d58528775fa48a36923d8bb5 set "dbtitle=Formula One 06" & set "dbtitleosd=Formula One 06"

REM REM SCES_539.50 Formula One 06 (Demo) (Press Kit)
REM REM ISO
REM if !MD5!==ca65ccf5975df4eeea65178039d05f49 set "dbtitle=Formula One 06 (Demo) (Press Kit)" & set "dbtitleosd=Formula One 06 (Demo) (Press Kit)"

REM REM SCES_548.44 Buzz! The Hollywood Quiz
REM REM ISO
REM if !MD5!==219d96f6c4095d390ac218412df83a49 set "dbtitle=Buzz^! The Hollywood Quiz" & set "dbtitleosd=Buzz^! The Hollywood Quiz" & set gameid=SCED_548.44

REM REM SCES_548.44 Buzz! The Hollywood Quiz (Demo) (Press Kit)
REM REM ISO
REM if !MD5!==3de4a0330623dd89de6d1bbf963b172c set "dbtitle=Buzz^! The Hollywood Quiz (Demo) (Press Kit)" & set "dbtitleosd=Buzz^! The Hollywood Quiz (Demo) (Press Kit)"
)

if !GameInstall!==PS1 (

if "!filename!"=="!fname!.VCD" "!rootpath!\BAT\busybox" md5sum "!fname!.VCD" | "!rootpath!\BAT\busybox" grep -o "[0-9a-f]\{32\}" > "!rootpath!\TMP\MD5.txt" & set /p MD5=<"!rootpath!\TMP\MD5.txt"

REM SLPS_015.27 Alive (Japan) (Disc 2)
if !MD5!==4a1f0b0c83af1f0b86c148d7fcbbd683 set "dbtitle=Alive (Disc 2)" & set gameid=SLPS_015.28

REM SLPS_015.27 Alive (Japan) (Disc 3)
if !MD5!==f9fc75f4c8b283f068de54ec2d20da6e set "dbtitle=Alive (Disc 3)" & set gameid=SLPS_015.29

REM SLPS_027.28 Breath of Fire IV (E3 Demo)
if !MD5!==e727685a14959bc599e290befa511351 set "dbtitle=Breath of Fire IV (E3 Demo)" & set gameid=SLPD_027.28

REM SLPS_027.28 Breath of Fire IV: Utsurowazaru Mono
if !MD5!==f83e1fe73253a860301c5b67f7e67c48 set "dbtitle=Breath of Fire IV - Utsurowazaru Mono" & set gameid=SLPS_027.28

REM SLPS_012.32 Bust A Move (Disc 1)
if !MD5!==e84810d0f4db6e6658ee4208eb9f5415 set "dbtitle=Bust A Move (Disc 1) (Genteiban)" & set gameid=SLPG_012.32

REM SCUS_945.03 1Xtreme
if !MD5!==29c642b78b68cfff9a47fac51dd6d3c2 set "dbtitle=1Xtreme" & set gameid=SCUG_945.03

REM SCUS_945.03 ESPN Extreme Games
if !MD5!==c9395ccb9bb59e9cea9170bf44bd5578 set "dbtitle=ESPN Extreme Games" & set gameid=SCUS_945.03

REM SCUS_941.67 Jet Moto 2: Championship Edition
if !MD5!==ee9fc1cd31d1e2adf6230ffb8db64e0e set "dbtitle=Jet Moto 2: Championship Edition" & set gameid=SCUG_941.67

REM SLUS_005.94 Metal Gear Solid (Disc 1) (Demo)
if !MD5!==6c88d7b7f085257caba543c99cc37d1c set "dbtitle=Metal Gear Solid (Disc 1) (Demo)" & set gameid=SLUD_005.94

REM SCUS_941.61 PlayStation Underground Number 1 (Disc 2)
if !MD5!==a86a49cd948c4f9c5063fbc360459764 set "dbtitle=PlayStation Underground Number 1 (Disc 2)" & set gameid=SCUX_941.61

REM SLPS_017.22 Sougaku Toshi Osaka (Disc 2) (Object)
if !MD5!==7eb012b852c2b912fb02579d5b713770 set "dbtitle=Sougaku Toshi Osaka (Disc 2) (Object)" & set gameid=SLPS_017.23

REM SLUS_005.15 The Lost World: Jurassic Park: Special Edition
if !MD5!==31f7e4d4fd01718e0602cf2d795ca797 set "dbtitle=The Lost World: Jurassic Park: Special Edition" & set gameid=SLUG_005.15

)