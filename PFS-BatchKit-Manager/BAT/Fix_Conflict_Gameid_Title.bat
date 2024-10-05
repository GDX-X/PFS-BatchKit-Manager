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


REM ********** This game ID does not exist I created it to avoid a conflict with the some title **********
REM ** USA **
REM SLUD = Sony Licensed USA/Canada Demos
REM SLUG = Sony Licensed USA/Canada Greatest Hits
REM SLUX = Sony Licensed USA/Canada Multi Disc

REM ** ASIA **
REM SLPD = Sony Licensed PlayStation Demos
REM SLPG = Sony Licensed PlayStation Greatest Hits

REM ######################################################################################################################################################

if !FixGameInstall!==PS2 (

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

if !FixGameInstall!==PS1 (

"!rootpath!\BAT\busybox" md5sum "!filename!" | "!rootpath!\BAT\busybox" grep -o "[0-9a-f]\{32\}" > "!rootpath!\TMP\MD5.txt" & set /p MD5=<"!rootpath!\TMP\MD5.txt"

REM SLPS_015.27 Alive (Japan) (Disc 2)
if !MD5!==4a1f0b0c83af1f0b86c148d7fcbbd683 set "dbtitle=Alive (Disc 2)" & set gameid=SLPS_015.28

REM SLPS_015.27 Alive (Japan) (Disc 3)
if !MD5!==f9fc75f4c8b283f068de54ec2d20da6e set "dbtitle=Alive (Disc 3)" & set gameid=SLPS_015.29

REM SLPS_027.28 Breath of Fire IV (E3 Demo)
if !MD5!==e727685a14959bc599e290befa511351 set "dbtitle=Breath of Fire IV (E3 Demo)" & set gameid=SLPD_027.28

REM SLPS_027.28 Breath of Fire IV: Utsurowazaru Mono
if !MD5!==f83e1fe73253a860301c5b67f7e67c48 set "dbtitle=Breath of Fire IV: Utsurowazaru Mono" & set gameid=SLPS_027.28

REM SLPS_012.32 Bust A Move (Disc 1)
if !MD5!==e84810d0f4db6e6658ee4208eb9f5415 set "dbtitle=Bust A Move (Disc 1) (Genteiban)" & set gameid=SLPG_012.32

REM SCUS_945.03 1Xtreme
if !MD5!==29c642b78b68cfff9a47fac51dd6d3c2 set "dbtitle=1Xtreme" & set gameid=SCUG_945.03

REM SCUS_945.03 ESPN Extreme Games
if !MD5!==c9395ccb9bb59e9cea9170bf44bd5578 set "dbtitle=ESPN Extreme Games" & set gameid=SCUS_945.03

REM SCUS_941.67 Jet Moto 2: Championship Edition
if !MD5!==ee9fc1cd31d1e2adf6230ffb8db64e0e set "dbtitle=Jet Moto 2: Championship Edition" & set gameid=SCUG_941.67

REM SLPS_019.72 Kagayaku Kisetsu e
if !MD5!==8c0cce8b5742deddf7092c5a13152170 set "dbtitle=Kagayaku Kisetsu e" & set gameid=SLPS_019.75

REM SLPS_016.30 Kasei Monogatari (Genteiban)
if !MD5!==497273e71e0dcc7da728fe46bb920386 set "dbtitle=Kasei Monogatari (Genteiban)" & set gameid=SLPS_016.29

REM SLPS_024.56 Momotarou Dentetsu V
if !MD5!==29a392aae9b274e11198af10fead4709 set "dbtitle=Momotarou Dentetsu V" & set gameid=SLPS_024.58

REM SLPS_024.56 Momotarou Dentetsu V (Shokai Genteiban)
if !MD5!==58060b99f160b4f992550cce44541faf set "dbtitle=Momotarou Dentetsu V (Shokai Genteiban)" & set gameid=SLPS_024.56

REM SLUS_005.94 Metal Gear Solid (Disc 1) (Demo)
if !MD5!==6c88d7b7f085257caba543c99cc37d1c set "dbtitle=Metal Gear Solid (Disc 1) (Demo)" & set gameid=SLUD_005.94

REM SCUS_945.81 NBA ShootOut 2001 (Demo)
if !MD5!==af1ab5022b2cad063b692953cc4cfebf set "dbtitle=NBA ShootOut 2001 (Demo)" & set gameid=SCUS_945.82

REM SLPS_007.65 Namco Museum Encore
if !MD5!==3dace84a20e9ff6cd03644e6146bdbef set "dbtitle=Namco Museum Encore)" & set gameid=SLPS_911.63

REM SLPS_007.65 Namco Museum Encore (Shokai Gentei)
if !MD5!==ed216e8f219c0bebb9dc1b860eb8f880 set "dbtitle=Namco Museum Encore (Shokai Gentei)" & set gameid=SLPS_007.65

REM SLPS_012.06 Naniwa Wangan Battle: Tarzan Yamada & AutoSelect Sawa Kyoudai (Taikenban)
if !MD5!==b5175999b9fb7b2202e2e7b970efd5dd set "dbtitle=Naniwa Wangan Battle: Tarzan Yamada & AutoSelect Sawa Kyoudai (Taikenban)" & set gameid=SLPM_803.01

REM SLUS_001.90 Oddworld: Abe's Oddysee (Trade Demo)
if !MD5!==1ed0d19fbd5471947d445d276f34bf0c set "dbtitle=Oddworld: Abe's Oddysee (Trade Demo)" & set gameid=SLUD_001.90

REM SCUS_941.61 PlayStation Underground Number 1 (Disc 2)
if !MD5!==a86a49cd948c4f9c5063fbc360459764 set "dbtitle=PlayStation Underground Number 1 (Disc 2)" & set gameid=SCUX_941.61

REM SLPS_007.31 Sangoku Musou (Taikenban)
if !MD5!==deaabe0baa857ad7fda000cf4535087f set "dbtitle=Sangoku Musou (Taikenban)" & set gameid=SLPM_800.85

REM SLPS_029.00 SD Gundam: GGeneration-F (Disc 1) (Tokubetsu-ban)
if !MD5!==5b84b0ea98bd78f20c42d84dfde10fe8 set "dbtitle=SD Gundam: GGeneration-F (Disc 1) (Tokubetsu-ban)" & set gameid=SLPM_840.04

REM SLPS_029.01 SD Gundam: GGeneration-F (Disc 2) (Tokubetsu-ban)
if !MD5!==2d67bee7fc9ec69f73f43bbc9c778b4a set "dbtitle=SD Gundam: GGeneration-F (Disc 2) (Tokubetsu-ban)" & set gameid=SLPM_840.05

REM SLPS_029.02 SD Gundam: GGeneration-F (Disc 3) (Tokubetsu-ban)
if !MD5!==4858a5769c656b3d5de1ec486a194faa set "dbtitle=SD Gundam: GGeneration-F (Disc 3) (Tokubetsu-ban)" & set gameid=SLPM_840.06

REM SLPS_029.03 SD Gundam: GGeneration-F (Disc 4) (Premium Disc) (Tokubetsu-ban)
if !MD5!==98b11d483d537c9b441efc440d40534c set "dbtitle=SD Gundam: GGeneration-F (Disc 4) (Tokubetsu-ban)" & set gameid=SLPM_840.07

REM SLPS_017.22 Sougaku Toshi Osaka (Disc 2) (Object)
if !MD5!==7eb012b852c2b912fb02579d5b713770 set "dbtitle=Sougaku Toshi Osaka (Disc 2) (Object)" & set gameid=SLPS_017.23

REM SLPS_023.15 Soukou Kihei Votoms: Koutetsu no Gunzei (Shokai Seisan Genteiban)
if !MD5!==ec51a74b08aee3f8e3656833f8e71cb8 set "dbtitle=Soukou Kihei Votoms: Koutetsu no Gunzei (Shokai Seisan Genteiban)" & set gameid=SLPS_023.13

REM SLUS_005.15 The Lost World: Jurassic Park: Special Edition
if !MD5!==31f7e4d4fd01718e0602cf2d795ca797 set "dbtitle=The Lost World: Jurassic Park: Special Edition" & set gameid=SLUG_005.15

)

if !FixGameRegion!==Yes (
    
	REM PS2 Region
	if "!gameid!"=="PBPX_952.10" set region=NTSC-U/C
	if "!gameid!"=="PBPX_952.16" set region=NTSC-U/C
	if "!gameid!"=="PBPX_952.18" set region=NTSC-U/C
	if "!gameid!"=="PBPX_952.19" set region=PAL
	if "!gameid!"=="PBPX_952.23" set region=NTSC-U/C
	if "!gameid!"=="PBPX_952.47" set region=NTSC-U/C
	if "!gameid!"=="PBPX_952.48" set region=NTSC-U/C
	if "!gameid!"=="PBPX_955.17" set region=NTSC-U/C
	if "!gameid!"=="PBPX_952.04" set region=PAL
	if "!gameid!"=="PBPX_952.05" set region=PAL
	if "!gameid!"=="PBPX_952.08" set region=PAL
	if "!gameid!"=="PBPX_952.09" set region=PAL
	if "!gameid!"=="PBPX_952.20" set region=PAL
	if "!gameid!"=="PBPX_952.39" set region=NTSC-U/C
	if "!gameid!"=="PBPX_952.42" set region=NTSC-U/C
	if "!gameid!"=="PBPX_952.46" set region=NTSC-U/C
	if "!gameid!"=="PBPX_955.03" set region=NTSC-U/C
	if "!gameid!"=="PBPX_955.06" set region=PAL
	if "!gameid!"=="PBPX_955.14" set region=PAL
	if "!gameid!"=="PBPX_955.19" set region=NTSC-U/C
	if "!gameid!"=="PBPX_955.20" set region=PAL
	
	REM PS1 Region
    if "!gameid!"=="PAPX_900.44" set region=NTSC-A
    if "!gameid!"=="PBPX_950.02" set region=NTSC-U/C
    if "!gameid!"=="PBPX_950.01" set region=PAL
    if "!gameid!"=="PBPX_950.03" set region=NTSC-U/C
    if "!gameid!"=="PBPX_950.04" set region=NTSC-U/C
    if "!gameid!"=="PBPX_950.06" set region=NTSC-U/C
    if "!gameid!"=="PBPX_950.07" set region=PAL
    if "!gameid!"=="PBPX_950.08" set region=PAL
    if "!gameid!"=="PBPX_950.09" set region=NTSC-U/C
    if "!gameid!"=="PBPX_950.10" set region=NTSC-U/C
    if "!gameid!"=="PBPX_950.11" set region=NTSC-U/C
	
	if !PSBBN!==Yes (
	if "!region!"=="NTSC-A" set region=A
	if "!region!"=="NTSC-U/C" set region=U
	if "!region!"=="PAL" set region=E
	)
)

set "FixGameInstall="