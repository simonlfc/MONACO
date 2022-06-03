#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
	replaceFunc( maps\mp\gametypes\_gamelogic::matchStartTimerPC, maps\mp\gametypes\_gamelogic::matchStartTimerSkip ); 	// Disable pre-match timer
    replaceFunc( maps\mp\gametypes\_weapons::init, ::init_weapons_hook ); // let's not precache stuff we don't need here.
}

init_weapons_hook()
{
	level.scavenger_altmode = true;
	level.scavenger_secondary = true;
	
	// 0 is not valid
	level.maxPerPlayerExplosives = max( getIntProperty( "scr_maxPerPlayerExplosives", 2 ), 1 );
	level.riotShieldXPBullets = getIntProperty( "scr_riotShieldXPBullets", 15 );

	switch ( getIntProperty( "perk_scavengerMode", 0 ) )
	{
		case 1: // disable altmode
			level.scavenger_altmode = false;
			break;

		case 2: // disable secondary
			level.scavenger_secondary = false;
			break;
			
		case 3: // disable altmode and secondary
			level.scavenger_altmode = false;
			level.scavenger_secondary = false;
			break;		
	}

	precacheItem( "flare_mp" );
	precacheItem( "scavenger_bag_mp" );
	precacheItem( "frag_grenade_short_mp" );	
	precacheItem( "destructible_car" );
	
	precacheShellShock( "default" );
	precacheShellShock( "concussion_grenade_mp" );
	thread maps\mp\_flashgrenades::main();
	thread maps\mp\_entityheadicons::init();

	claymoreDetectionConeAngle = 70;
	level.claymoreDetectionDot = cos( claymoreDetectionConeAngle );
	level.claymoreDetectionMinDist = 20;
	level.claymoreDetectionGracePeriod = .75;
	level.claymoreDetonateRadius = 192;
	
	// this should move to _stinger.gsc
	level.stingerFXid = loadFX( "explosions/aerial_explosion_large" );

	// generating weapon type arrays which classifies the weapon as primary (back stow), pistol, or inventory (side pack stow)
	// using mp/statstable.csv's weapon grouping data ( numbering 0 - 149 )
	level.primary_weapon_array = [];
	level.side_arm_array = [];
	level.grenade_array = [];
	level.inventory_array = [];
	level.stow_priority_model_array = [];
	level.stow_offset_array = [];
	
	max_weapon_num = 149;
	for( i = 0; i < max_weapon_num; i++ )
	{
		weapon = tableLookup( "mp/statsTable.csv", 0, i, 4 );
		stow_model = tableLookup( "mp/statsTable.csv", 0, i, 9 );
		
		if ( stow_model == "" )
			continue;

		precacheModel( stow_model );		

		if ( isSubStr( stow_model, "weapon_stow_" ) )
			level.stow_offset_array[ weapon ] = stow_model;
		else
			level.stow_priority_model_array[ weapon + "_mp" ] = stow_model;
	}
	
	precacheModel( "weapon_claymore_bombsquad" );
	precacheModel( "weapon_c4_bombsquad" );
	precacheModel( "projectile_m67fraggrenade_bombsquad" );
	precacheModel( "projectile_semtex_grenade_bombsquad" );
	precacheModel( "weapon_light_stick_tactical_bombsquad" );
	
	level.killStreakSpecialCaseWeapons = [];
	level.killStreakSpecialCaseWeapons["cobra_player_minigun_mp"] = true;
	level.killStreakSpecialCaseWeapons["artillery_mp"] = true;
	level.killStreakSpecialCaseWeapons["stealth_bomb_mp"] = true;
	level.killStreakSpecialCaseWeapons["pavelow_minigun_mp"] = true;
	level.killStreakSpecialCaseWeapons["sentry_minigun_mp"] = true;
	level.killStreakSpecialCaseWeapons["harrier_20mm_mp"] = true;
	level.killStreakSpecialCaseWeapons["ac130_105mm_mp"] = true;
	level.killStreakSpecialCaseWeapons["ac130_40mm_mp"] = true;
	level.killStreakSpecialCaseWeapons["ac130_25mm_mp"] = true;
	level.killStreakSpecialCaseWeapons["remotemissile_projectile_mp"] = true;
	level.killStreakSpecialCaseWeapons["cobra_20mm_mp"] = true;
	level.killStreakSpecialCaseWeapons["sentry_minigun_mp"] = true;

	level thread maps\mp\gametypes\_weapons::onPlayerConnect();
	
	level.c4explodethisframe = false;

	array_thread( getEntArray( "misc_turret", "classname" ), maps\mp\gametypes\_weapons::turret_monitorUse );
}