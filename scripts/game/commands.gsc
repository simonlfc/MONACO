#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	self endon( "disconnect" );

	self thread register_command( "ax50" );
	self thread register_command( "hdr" );
	self thread register_command( "swiss" );
}

register_command( command, detail )
{
	self endon( "disconnect" );

	self notifyOnPlayerCommand( command, command );
	self setClientDvar( command, "[]" );
	for(;;)
	{
		self waittill( command );
		switch ( command )
		{
		case "ax50":			self giveweapon_cmd( "iw8_ax50_mp" );			break;
		case "hdr":				self giveweapon_cmd( "iw8_hdr_mp" );			break;
		case "swiss":			self giveweapon_cmd( "t9_swiss_mp" );			break;
		}
	}
}


giveweapon_cmd( weapon )
{
	foreach( item in level.weaponList )
	{
		if ( item == weapon )
		{
			current_weapons = self getWeaponsListPrimaries();
			if ( current_weapons.size > 1 )
			{
				self takeWeapon( self getCurrentWeapon() );
				waitframe();
			}

			self iPrintLn( "Giving weapon: ", weapon );
			self giveWeapon( weapon, 0, false );
			self switchToWeapon( weapon );
			return;
		}
	}

	self iPrintLn( weapon, " isn't precached, see init.gsc" );
}	