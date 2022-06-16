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

    makeDvarServerInfo("monaco_version", 4);

    thread scripts\game\hooks::init();
    thread scripts\game\common::init();
    check_for_updates();
}

check_for_updates()
{
    console_print("MONACO Updater", "Checking for updates...");
    download = httpGet("https://raw.githubusercontent.com/simonlfc/MONACO/master/version.txt");
    download waittill("done", success, data);
    if (!success)
    {
        console_print("Updater", "Failed to check for updates. -scriptablehttp might be disabled, or GitHub is unavailable.");
        return;
    }

    remote_version = int(data);
    if (getDvarInt("monaco_version") == remote_version)
        console_print("MONACO Updater", "Up to date.");
    else if (getDvarInt("monaco_version") > remote_version)
        console_print("MONACO Updater", "^3Current version is higher than the latest available version.");
    else if (getDvarInt("monaco_version") < remote_version)
        console_print("MONACO Updater", "^1An update is available, head to github.com/simonlfc/MONACO to download the latest version.");
}

console_print(head, msg)
{
    printConsole("^6[" + head + "] ^7" + msg + "\n");
}