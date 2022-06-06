#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

select_sniper( sniper )
{    
    foreach ( item in level.weaponList )
	{
		if ( item == sniper )
		{
            self closepopupMenu();
	        self closeInGameMenu();

            self.pers["loadout_sniper"] = sniper;
	        self [[level.class]]( "class0", true );
			return;
		}
	}
}

on_script_menu_response()
{
    self endon( "disconnect" );
    
    for(;;)
    {
        self waittill( "menuresponse", menu, response );

        if ( isSubStr( response, "select_sniper" ) )
            self thread select_sniper( strTok( response, ":" )[1] );
    }
}