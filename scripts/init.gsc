init()
{
    level.weaponList = [];
    level.weaponList[level.weaponList.size] = "iw8_ax50_mp";
    level.weaponList[level.weaponList.size] = "t9_swiss_mp";
    
    foreach ( weapon in level.weaponList )
        precacheItem( weapon );

	thread scripts\game\hooks::init();
	thread scripts\game\common::init();
}