rmdir /s /q demos
rmdir /s /q logs
del /q iw4x.stat

copy /Y G:\ZoneTool\IW4\zone\english\monaco.ff mod.ff
if not exist data.iwd 7za a -tzip data.iwd G:\ZoneTool\IW4\main\monaco\images
..\..\iw4x.exe -stdout -scriptablehttp +set developer 2 +set developer_script 1 +set fs_game mods/MONACO +set g_gametype dm +devmap iw4_credits