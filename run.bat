rmdir /s /q demos
rmdir /s /q logs

copy /Y G:\ZoneTool\IW4\zone\english\monaco.ff mod.ff
..\..\iw4x.exe -stdout -scriptablehttp +set fs_game mods/MONACO +set g_gametype war +devmap mp_rust