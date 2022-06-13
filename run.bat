rmdir /s /q demos
rmdir /s /q logs
del /q iw4x.stat
del /q missingasset.csv

if not exist data.iwd 7za a -tzip data.iwd G:\ZoneTool\IW4\main\monaco\images
if not exist mod.ff copy /Y G:\ZoneTool\IW4\zone\english\monaco.ff mod.ff

..\..\iw4x.exe -stdout +set fs_game mods/MONACO +set developer 2 +set developer_script 1 +set g_gametype dm +devmap iw4_credits