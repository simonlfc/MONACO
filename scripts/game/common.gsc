#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{    
    level.onlineGame             = true;
    level.rankedMatch            = true;
    level.modifyPlayerDamage     = ::modify_player_damage;

    level thread on_player_connect();
}

on_player_connect()
{
    for(;;)
    {
        level waittill( "connected", player );
        
        if ( player isTestClient() )
            return;

        player thread scripts\game\commands::init(); // REMOVE AFTER KEK
        player thread on_player_spawned();
    }
}

on_player_spawned()
{
    self endon( "disconnect" );

    for(;;)
    {
        self waittill( "spawned_player" );
        self thread ammo_regen();
    }
}

ammo_regen()
{
    self endon( "death" );
    self endon( "disconnect" );

    for(;;)
    {
        self waittill( "reload" );
        weapon = self getCurrentWeapon();
        self setWeaponAmmoStock( weapon, weaponMaxAmmo( weapon ) );
    }
}

modify_player_damage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc )
{
	if ( weaponClass( sWeapon ) == "sniper" || sWeapon == "throwingknife_mp" )
		iDamage = 99999;
    else
        iDamage = 0;

	return int( iDamage );
}