init()
{
    level.weaponList = [];
    level.weaponList[level.weaponList.size] = "s4_mosin";
    level.weaponList[level.weaponList.size] = "iw8_ax50";
    level.weaponList[level.weaponList.size] = "iw8_hdr";
    level.weaponList[level.weaponList.size] = "iw8_kar98";
    level.weaponList[level.weaponList.size] = "t9_tundra";
    level.weaponList[level.weaponList.size] = "t9_pellington";
    level.weaponList[level.weaponList.size] = "iw8_spr";
    level.weaponList[level.weaponList.size] = "t9_swiss";
    level.weaponList[level.weaponList.size] = "s4_type99";
    level.weaponList[level.weaponList.size] = "t9_zrg";
    level.weaponList[level.weaponList.size] = "usp";
    
    foreach ( weapon in level.weaponList )
        precacheItem( weapon + "_mp" );

	thread scripts\game\hooks::init();
	thread scripts\game\common::init();
}