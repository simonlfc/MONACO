#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    level.modifyPlayerDamage     = ::modify_player_damage;

    setDvar("player_sprintUnlimited", true);

    level thread on_player_connect();
}

on_player_connect()
{
    for(;;)
    {
        level waittill("connected", player);

        if (!isDefined(player.pers["sniper"]))
            player.pers["sniper"] = level.weaponList[randomInt(level.weaponList.size)];

        player thread scripts\game\ui_callbacks::on_script_menu_response();
        player thread on_player_spawned();
    }
}

on_player_spawned()
{
    self endon("disconnect");

    for(;;)
    {
        self waittill("spawned_player");
        self thread ammo_regen();
    }
}

ammo_regen()
{
    self endon("death");
    self endon("disconnect");

    for(;;)
    {
        self waittill("reload");
        weapon = self getCurrentWeapon();

        if (weaponClass(weapon) != "sniper")
            continue;

        self setWeaponAmmoStock(weapon, weaponMaxAmmo(weapon));
    }
}

modify_player_damage(victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
    if (isPlayer(eAttacker))
    {
        if (sWeapon == "deserteagle_mp")
            return iDamage;

        if (weaponClass(sWeapon) == "sniper" || sWeapon == "throwingknife_mp")
            iDamage = 99999;
        else
            iDamage = 1;
    }

    return int(iDamage);
}
