#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_damage;

// adjustable settings
ALWAYS_GHILLIE  	= 1;
PLUS_10 			= 1;
SKIP_PREMATCH		= 1;
STACK_TIMER			= 1;

init()
{
    replaceFunc( maps\mp\gametypes\_weapons::init, ::init_weapons_hook ); 												// Let's not precache stuff we don't need here
    replaceFunc( maps\mp\gametypes\_class::giveLoadout, ::give_loadout_hook ); 											// Set up our custom class
	replaceFunc( maps\mp\gametypes\_damage::Callback_PlayerDamage_internal, ::player_damage_hook ); 					// Add damage callback
	replaceFunc( maps\mp\gametypes\_menus::beginClassChoice, ::begin_class_choice_hook );								// Intercept initial class choice and set our local team var
	replaceFunc( maps\mp\gametypes\_rank::scorePopup, ::score_popup_hook );												// Allow for stack timer customisation
	replaceFunc( maps\mp\_events::updateRecentKills, ::update_recent_kills_hook );										// Allow for stack timer customisation

	if ( PLUS_10 == 1 )																									// +10, I think its a timing issue with using registerScoreInfo and _rank::init() being called so I'll shithouse it
		replaceFunc( maps\mp\gametypes\_rank::getScoreInfoValue, ::get_score_info_value_hook );
		
	if ( SKIP_PREMATCH == 1 )																							// Disable pre-match timer
		replaceFunc( maps\mp\gametypes\_gamelogic::matchStartTimerPC, maps\mp\gametypes\_gamelogic::matchStartTimerSkip );
}

update_recent_kills_hook( killId )
{
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	
	self notify ( "updateRecentKills" );
	self endon ( "updateRecentKills" );
	
	self.recentKillCount++;
	
	wait ( STACK_TIMER );
	
	if ( self.recentKillCount > 1 )
		self maps\mp\_events::multiKill( killId, self.recentKillCount );
	
	self.recentKillCount = 0;
}

score_popup_hook( amount, bonus, hudColor, glowAlpha )
{
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );

	if ( amount == 0 )
		return;

	self notify( "scorePopup" );
	self endon( "scorePopup" );

	self.xpUpdateTotal += amount;
	self.bonusUpdateTotal += bonus;

	wait ( 0.05 );

	if ( self.xpUpdateTotal < 0 )
		self.hud_scorePopup.label = &"";
	else
		self.hud_scorePopup.label = &"MP_PLUS";

	self.hud_scorePopup.color = hudColor;
	self.hud_scorePopup.glowColor = hudColor;
	self.hud_scorePopup.glowAlpha = glowAlpha;

	self.hud_scorePopup setValue( self.xpUpdateTotal );
	self.hud_scorePopup.alpha = 0.85;
	self.hud_scorePopup thread maps\mp\gametypes\_hud::fontPulse( self );

	increment = max( int( self.bonusUpdateTotal / 20 ), 1 );
		
	if ( self.bonusUpdateTotal )
	{
		while ( self.bonusUpdateTotal > 0 )
		{
			self.xpUpdateTotal += min( self.bonusUpdateTotal, increment );
			self.bonusUpdateTotal -= min( self.bonusUpdateTotal, increment );
			
			self.hud_scorePopup setValue( self.xpUpdateTotal );
			
			wait ( 0.05 );
		}
	}	
	else
	{
		wait ( STACK_TIMER );
	}

	self.hud_scorePopup fadeOverTime( 0.75 );
	self.hud_scorePopup.alpha = 0;
	
	self.xpUpdateTotal = 0;		
}

get_score_info_value_hook( type )
{
	switch( type )
	{
	case "assist":
		if ( level.teambased )
			return 2;
	case "headshot":
	case "kill":
		if ( level.teambased )
			return 10;
		else
			return 5;
	default:
		return level.scoreInfo[type]["value"];
	}
}

begin_class_choice_hook()
{
	assert( self.pers["team"] == "axis" || self.pers["team"] == "allies" );

	if ( self.pers["team"] == "axis" )
		self openMenu( "initteam_opfor" );
	else if ( self.pers["team"] == "allies" )
		self openMenu( "initteam_marines" );
		
	self openPopupMenu( "changesniper" );
	
	if ( !isAlive( self ) )
		self thread maps\mp\gametypes\_playerlogic::predictAboutToSpawnPlayerOverTime( 0.1 );
}

player_damage_hook( eInflictor, eAttacker, victim, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{	
	if ( !isReallyAlive( victim ) )
		return;
	
	if ( isDefined( eAttacker ) && eAttacker.classname == "script_origin" && isDefined( eAttacker.type ) && eAttacker.type == "soft_landing" )
		return;
	
	if ( isDefined( level.hostMigrationTimer ) )
		return;
	
	if ( sMeansOfDeath == "MOD_FALLING" )
		victim thread emitFallDamage( iDamage );
		
	if ( sMeansOfDeath == "MOD_EXPLOSIVE_BULLET" && iDamage != 1 )
	{
		iDamage *= getDvarFloat( "scr_explBulletMod" );	
		iDamage = int( iDamage );
	}

	if ( isDefined( eAttacker ) && eAttacker.classname == "worldspawn" )
		eAttacker = undefined;
	
	if ( isDefined( eAttacker ) && isDefined( eAttacker.gunner ) )
		eAttacker = eAttacker.gunner;
	
	attackerIsNPC = isDefined( eAttacker ) && !isDefined( eAttacker.gunner ) && (eAttacker.classname == "script_vehicle" || eAttacker.classname == "misc_turret" || eAttacker.classname == "script_model");
	attackerIsHittingTeammate = level.teamBased && isDefined( eAttacker ) && ( victim != eAttacker ) && isDefined( eAttacker.team ) && ( victim.pers[ "team" ] == eAttacker.team );

	stunFraction = 0.0;

	if ( iDFlags & level.iDFLAGS_STUN )
	{
		stunFraction = 0.0;
		//victim StunPlayer( 1.0 );
		iDamage = 0.0;
	}
	else if ( sHitLoc == "shield" )
	{
		if ( attackerIsHittingTeammate && level.friendlyfire == 0 )
			return;
		
		if ( sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_EXPLOSIVE_BULLET" && !attackerIsHittingTeammate )
		{
			if ( isPlayer( eAttacker ) )
			{
				eAttacker.lastAttackedShieldPlayer = victim;
				eAttacker.lastAttackedShieldTime = getTime();
			}
			victim notify ( "shield_blocked" );

			// fix turret + shield challenge exploits
			if ( sWeapon == "turret_minigun_mp" )
				shieldDamage = 25;
			else
				shieldDamage = maps\mp\perks\_perks::cac_modified_damage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc );
						
			victim.shieldDamage += shieldDamage;

			// fix turret + shield challenge exploits
			if ( sWeapon != "turret_minigun_mp" || cointoss() )
				victim.shieldBulletHits++;

			if ( victim.shieldBulletHits >= level.riotShieldXPBullets )
			{
				if ( self.recentShieldXP > 4 )
					xpVal = int( 50 / self.recentShieldXP );
				else
					xpVal = 50;
				
				printLn( xpVal );
				
				victim thread maps\mp\gametypes\_rank::giveRankXP( "shield_damage", xpVal );
				victim thread giveRecentShieldXP();
				
				victim thread maps\mp\gametypes\_missions::genericChallenge( "shield_damage", victim.shieldDamage );

				victim thread maps\mp\gametypes\_missions::genericChallenge( "shield_bullet_hits", victim.shieldBulletHits );
				
				victim.shieldDamage = 0;
				victim.shieldBulletHits = 0;
			}
		}

		if ( iDFlags & level.iDFLAGS_SHIELD_EXPLOSIVE_IMPACT )
		{
			if (  !attackerIsHittingTeammate )
				victim thread maps\mp\gametypes\_missions::genericChallenge( "shield_explosive_hits", 1 );

			sHitLoc = "none";	// code ignores any damage to a "shield" bodypart.
			if ( !(iDFlags & level.iDFLAGS_SHIELD_EXPLOSIVE_IMPACT_HUGE) )
				iDamage *= 0.0;
		}
		else if ( iDFlags & level.iDFLAGS_SHIELD_EXPLOSIVE_SPLASH )
		{
			if ( isDefined( eInflictor ) && isDefined( eInflictor.stuckEnemyEntity ) && eInflictor.stuckEnemyEntity == victim ) //does enough damage to shield carrier to ensure death
				iDamage = 101;
			
			victim thread maps\mp\gametypes\_missions::genericChallenge( "shield_explosive_hits", 1 );
			sHitLoc = "none";	// code ignores any damage to a "shield" bodypart.
		}
		else
		{
			return;
		}
	}
	else if ( (smeansofdeath == "MOD_MELEE") && IsSubStr( sweapon, "riotshield" ) )
	{
		if ( !(attackerIsHittingTeammate && (level.friendlyfire == 0)) )
		{
			stunFraction = 0.0;
			victim StunPlayer( 0.0 );
		}
	}

	if ( !attackerIsHittingTeammate )
		iDamage = maps\mp\perks\_perks::cac_modified_damage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc );

	if ( isDefined( level.modifyPlayerDamage ) )	
		iDamage = [[level.modifyPlayerDamage]]( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc );
	
	if ( !iDamage )
		return false;
	
	victim.iDFlags = iDFlags;
	victim.iDFlagsTime = getTime();

	if ( game[ "state" ] == "postgame" )
		return;
	if ( victim.sessionteam == "spectator" )
		return;
	if ( isDefined( victim.canDoCombat ) && !victim.canDoCombat )
		return;
	if ( isDefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( eAttacker.canDoCombat ) && !eAttacker.canDoCombat )
		return;

	// handle vehicles/turrets and friendly fire
	if ( attackerIsNPC && attackerIsHittingTeammate )
	{
		if ( sMeansOfDeath == "MOD_CRUSH" )
		{
			victim _suicide();
			return;
		}
		
		if ( !level.friendlyfire )
			return;
	}

	prof_begin( "PlayerDamage flags/tweaks" );

	// Don't do knockback if the damage direction was not specified
	if ( !isDefined( vDir ) )
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	friendly = false;

	if ( ( victim.health == victim.maxhealth && ( !isDefined( victim.lastStand ) || !victim.lastStand )  ) || !isDefined( victim.attackers ) && !isDefined( victim.lastStand )  )
	{
		victim.attackers = [];
		victim.attackerData = [];
	}

	if ( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath, eAttacker ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	if ( maps\mp\gametypes\_tweakables::getTweakableValue( "game", "onlyheadshots" ) )
	{
		if ( sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_EXPLOSIVE_BULLET" )
			return;
		else if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
			iDamage = 150;
	}

	// explosive barrel/car detection
	if ( sWeapon == "none" && isDefined( eInflictor ) )
	{
		if ( isDefined( eInflictor.destructible_type ) && isSubStr( eInflictor.destructible_type, "vehicle_" ) )
			sWeapon = "destructible_car";
	}

	prof_end( "PlayerDamage flags/tweaks" );

	// check for completely getting out of the damage
	if ( !(iDFlags & level.iDFLAGS_NO_PROTECTION) )
	{
		// items you own don't damage you in FFA
		if ( !level.teamBased && attackerIsNPC && isDefined( eAttacker.owner ) && eAttacker.owner == victim )
		{
			prof_end( "PlayerDamage player" );

			if ( sMeansOfDeath == "MOD_CRUSH" )
				victim _suicide();

			return;
		}

		if ( ( isSubStr( sMeansOfDeath, "MOD_GRENADE" ) || isSubStr( sMeansOfDeath, "MOD_EXPLOSIVE" ) || isSubStr( sMeansOfDeath, "MOD_PROJECTILE" ) ) && isDefined( eInflictor ) && isDefined( eAttacker ) )
		{
			// protect players from spawnkill grenades
			if ( eInflictor.classname == "grenade" && ( victim.lastSpawnTime + 3500 ) > getTime() && isDefined( victim.lastSpawnPoint ) && distance( eInflictor.origin, victim.lastSpawnPoint.origin ) < 250 )
			{
				prof_end( "PlayerDamage player" );
				return;
			}

			victim.explosiveInfo = [];
			victim.explosiveInfo[ "damageTime" ] = getTime();
			victim.explosiveInfo[ "damageId" ] = eInflictor getEntityNumber();
			victim.explosiveInfo[ "returnToSender" ] = false;
			victim.explosiveInfo[ "counterKill" ] = false;
			victim.explosiveInfo[ "chainKill" ] = false;
			victim.explosiveInfo[ "cookedKill" ] = false;
			victim.explosiveInfo[ "throwbackKill" ] = false;
			victim.explosiveInfo[ "suicideGrenadeKill" ] = false;
			victim.explosiveInfo[ "weapon" ] = sWeapon;

			isFrag = isSubStr( sWeapon, "frag_" );

			if ( eAttacker != victim )
			{
				if ( ( isSubStr( sWeapon, "c4_" ) || isSubStr( sWeapon, "claymore_" ) ) && isDefined( eAttacker ) && isDefined( eInflictor.owner ) )
				{
					victim.explosiveInfo[ "returnToSender" ] = ( eInflictor.owner == victim );
					victim.explosiveInfo[ "counterKill" ] = isDefined( eInflictor.wasDamaged );
					victim.explosiveInfo[ "chainKill" ] = isDefined( eInflictor.wasChained );
					victim.explosiveInfo[ "bulletPenetrationKill" ] = isDefined( eInflictor.wasDamagedFromBulletPenetration );
					victim.explosiveInfo[ "cookedKill" ] = false;
				}

				if ( isDefined( eAttacker.lastGrenadeSuicideTime ) && eAttacker.lastGrenadeSuicideTime >= gettime() - 50 && isFrag )
					victim.explosiveInfo[ "suicideGrenadeKill" ] = true;
			}

			if ( isFrag )
			{
				victim.explosiveInfo[ "cookedKill" ] = isDefined( eInflictor.isCooked );
				victim.explosiveInfo[ "throwbackKill" ] = isDefined( eInflictor.threwBack );
			}
			
			victim.explosiveInfo[ "stickKill" ] = isDefined( eInflictor.isStuck ) && eInflictor.isStuck == "enemy";
			victim.explosiveInfo[ "stickFriendlyKill" ] = isDefined( eInflictor.isStuck ) && eInflictor.isStuck == "friendly";
		}
	
		if ( isPlayer( eAttacker ) )
			eAttacker.pers[ "participation" ]++ ;

		prevHealthRatio = victim.health / victim.maxhealth;

		if ( attackerIsHittingTeammate )
		{
			if ( !matchMakingGame() && isPlayer(eAttacker) )
				eAttacker incPlayerStat( "mostff", 1 );
			
			prof_begin( "PlayerDamage player" );// profs automatically end when the function returns
			if ( level.friendlyfire == 0 || ( !isPlayer(eAttacker) && level.friendlyfire != 1 ) )// no one takes damage
			{
				if ( sWeapon == "artillery_mp" || sWeapon == "stealth_bomb_mp" )
					victim damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage, iDFlags, eAttacker );
				return;
			}
			else if ( level.friendlyfire == 1 )// the friendly takes damage
			{
				if ( iDamage < 1 )
					iDamage = 1;

				victim.lastDamageWasFromEnemy = false;

				victim finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction );
			}
			else if ( ( level.friendlyfire == 2 ) && isReallyAlive( eAttacker ) )// only the attacker takes damage
			{
				iDamage = int( iDamage * .5 );
				if ( iDamage < 1 )
					iDamage = 1;

				eAttacker.lastDamageWasFromEnemy = false;

				eAttacker.friendlydamage = true;
				eAttacker finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction );
				eAttacker.friendlydamage = undefined;
			}
			else if ( level.friendlyfire == 3 && isReallyAlive( eAttacker ) )// both friendly and attacker take damage
			{
				iDamage = int( iDamage * .5 );
				if ( iDamage < 1 )
					iDamage = 1;

				victim.lastDamageWasFromEnemy = false;
				eAttacker.lastDamageWasFromEnemy = false;

				victim finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction );
				if ( isReallyAlive( eAttacker ) )// may have died due to friendly fire punishment
				{
					eAttacker.friendlydamage = true;
					eAttacker finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction );
					eAttacker.friendlydamage = undefined;
				}
			}

			friendly = true;
			
		}
		else// not hitting teammate
		{
			prof_begin( "PlayerDamage world" );

			if ( iDamage < 1 )
				iDamage = 1;

			if ( isDefined( eAttacker ) && isPlayer( eAttacker ) )
				addAttacker( victim, eAttacker, eInflictor, sWeapon, iDamage, vPoint, vDir, sHitLoc, psOffsetTime, sMeansOfDeath );
			
			if ( sMeansOfDeath == "MOD_EXPLOSIVE" || sMeansOfDeath == "MOD_GRENADE_SPLASH" && iDamage < victim.health )
				victim notify( "survived_explosion" );

			if ( isdefined( eAttacker ) )
				level.lastLegitimateAttacker = eAttacker;

			if ( isdefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( sWeapon ) )
				eAttacker thread maps\mp\gametypes\_weapons::checkHit( sWeapon, victim );

			if ( isdefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( sWeapon ) && eAttacker != victim )
			{
				eAttacker thread maps\mp\_events::damagedPlayer( self, iDamage, sWeapon );
				victim.attackerPosition = eAttacker.origin;
			}
			else
			{
				victim.attackerPosition = undefined;
			}

			if ( issubstr( sMeansOfDeath, "MOD_GRENADE" ) && isDefined( eInflictor.isCooked ) )
				victim.wasCooked = getTime();
			else
				victim.wasCooked = undefined;

			victim.lastDamageWasFromEnemy = ( isDefined( eAttacker ) && ( eAttacker != victim ) );

			if ( victim.lastDamageWasFromEnemy )
				eAttacker.damagedPlayers[ victim.guid ] = getTime();

			victim finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction );

			if ( isDefined( level.ac130player ) && isDefined( eAttacker ) && ( level.ac130player == eAttacker ) )
				level notify( "ai_pain", victim );

			victim thread maps\mp\gametypes\_missions::playerDamaged( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, sHitLoc );

			prof_end( "PlayerDamage world" );
			
		}

		if ( attackerIsNPC && isDefined( eAttacker.gunner ) )
			damager = eAttacker.gunner;
		else
			damager = eAttacker;

		if ( isDefined( damager) && damager != victim && iDamage > 0 )
		{
			if ( iDFlags & level.iDFLAGS_STUN )
				typeHit = "stun";
			else if ( victim hasPerk( "specialty_armorvest", true ) || (isExplosiveDamage( sMeansOfDeath ) && victim _hasPerk( "_specialty_blastshield" )) )
				typeHit = "hitBodyArmor";
			else if ( victim _hasPerk( "specialty_combathigh") )
				typeHit = "hitEndGame";
			else
				typeHit = "standard";
				
			damager thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( typeHit );
		}

		victim.hasDoneCombat = true;
	}

	if ( isdefined( eAttacker ) && ( eAttacker != victim ) && !friendly )
		level.useStartSpawns = false;


	//=================
	// Damage Logging
	//=================

	prof_begin( "PlayerDamage log" );

	// why getEntityNumber() for victim and .clientid for attacker?
	if ( getDvarInt( "g_debugDamage" ) )
		println( "client:" + victim getEntityNumber() + " health:" + victim.health + " attacker:" + eAttacker.clientid + " inflictor is player:" + isPlayer( eInflictor ) + " damage:" + iDamage + " hitLoc:" + sHitLoc );

	if ( victim.sessionstate != "dead" )
	{
		lpselfnum = victim getEntityNumber();
		lpselfname = victim.name;
		lpselfteam = victim.pers[ "team" ];
		lpselfGuid = victim.guid;
		lpattackerteam = "";

		if ( isPlayer( eAttacker ) )
		{
			lpattacknum = eAttacker getEntityNumber();
			lpattackGuid = eAttacker.guid;
			lpattackname = eAttacker.name;
			lpattackerteam = eAttacker.pers[ "team" ];
		}
		else
		{
			lpattacknum = -1;
			lpattackGuid = "";
			lpattackname = "";
			lpattackerteam = "world";
		}

		logPrint( "D;" + lpselfGuid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackGuid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n" );
	}

	HitlocDebug( eAttacker, victim, iDamage, sHitLoc, iDFlags );

	/*if( isDefined( eAttacker ) && eAttacker != victim )
	{
		if ( isPlayer( eAttacker ) )
			eAttacker incPlayerStat( "damagedone", iDamage );
		
		victim incPlayerStat( "damagetaken", iDamage );
	}*/

	prof_end( "PlayerDamage log" );
}

give_loadout_hook( team, class, allowCopycat )
{
	self takeAllWeapons();
	
	// initialize specialty array
	self.specialty  = [];
	self.class_num 	= 0;
	
	// Action Slots
	self _setActionSlot( 1, "" );
	self _setActionSlot( 1, "nightvision" );
	self _setActionSlot( 3, "altMode" );
	self _setActionSlot( 4, "" );

	// Perks
	self setOffhandPrimaryClass( "other" );
	self _clearPerks();
	self maps\mp\gametypes\_class::_detachAll();
	self maps\mp\gametypes\_class::loadoutAllPerks( "specialty_tacticalinsertion", 
													"specialty_fastreload", 
													"specialty_lightweight", 
													"specialty_bulletaccuracy" );

	// Primary Weapon
	primaryName = self.pers["sniper"];
	self _giveWeapon( primaryName + "_mp" );
	self giveMaxAmmo( primaryName + "_mp" );
	self setSpawnWeapon( primaryName + "_mp" );

	// Secondary Weapon
	secondaryName = "deserteagle";
	self _giveWeapon( secondaryName + "_mp" );
		
	// Tactical Equipment
	self setOffhandSecondaryClass( "smoke" );
	self giveWeapon( "smoke_grenade_mp" );
	self setWeaponAmmoClip( "smoke_grenade_mp", 1 );
	
	self.loadoutPrimary 	= primaryName;
	self.loadoutSecondary 	= secondaryName;
	self.primaryWeapon 		= primaryName;
	self.secondaryWeapon 	= secondaryName;
	self.isSniper 			= true;

	if ( ALWAYS_GHILLIE == 1 )
		self maps\mp\gametypes\_teams::playerModelForWeapon( "cheytac", secondaryName );
	else
		self maps\mp\gametypes\_teams::playerModelForWeapon( self.pers["sniper"], secondaryName );

	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );

	// cac specialties that require loop threads
	self maps\mp\perks\_perks::cac_selector();
	
	self notify( "changed_kit" );
	self notify( "giveLoadout" );
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
	
	foreach ( weapon in level.weaponList )
	{
		stow_model = tableLookup( "mp/statsTable.csv", 4, weapon, 9 );
		
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