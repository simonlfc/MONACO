init()
{
    level.weaponList = [];
    level.weaponList[level.weaponList.size] = "3line";
    level.weaponList[level.weaponList.size] = "ax50";
    level.weaponList[level.weaponList.size] = "hdr";
    level.weaponList[level.weaponList.size] = "kar98";
    level.weaponList[level.weaponList.size] = "tundra";
    level.weaponList[level.weaponList.size] = "mk2";
    level.weaponList[level.weaponList.size] = "pelington";
    level.weaponList[level.weaponList.size] = "spr";
    level.weaponList[level.weaponList.size] = "swiss";
    level.weaponList[level.weaponList.size] = "type99";
    level.weaponList[level.weaponList.size] = "zrg";
    level.weaponList[level.weaponList.size] = "flare";
    level.weaponList[level.weaponList.size] = "smoke_grenade";
    level.weaponList[level.weaponList.size] = "deserteagle";

    foreach (weaponName in level.weaponList)
        precacheItem(weaponName + "_mp");

    precacheMenu("changesniper");

    thread scripts\game\hooks::init();
    thread scripts\game\common::init();
}