#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	self endon( "disconnect" );
	
	self thread register_command( "giveweapon" );
}

register_command( command, detail )
{
	self endon( "disconnect" );

	self notifyOnPlayerCommand( command, command );
	self setClientDvar( command, "[]" );
	for ( ;; )
	{
		self waittill( command );
		switch ( command )
		{
		case "giveweapon": 
			self giveweapon_cmd( getDvar( "giveweapon" ) ); 
			break;
		}
	}
}


giveweapon_cmd( weapon )
{
	foreach ( item in level.weaponList )
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

	self iPrintLn( "Weapon not found." );
}	