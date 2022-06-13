#define CREATE_SHADER( position, texture, colour ) \
		CREATE_SHADER_VIS( position, texture, colour, 1 )

#define CREATE_SHADER_VIS( position, texture, colour, visibility ) \
		CREATE_SHADER_EX( position, texture, colour, visibility, ; )

#define CREATE_SHADER_EX( position, texture, colour, visibility, extra ) \
		itemDef \
		{ \
			style 			WINDOW_STYLE_SHADER \
			rect 			position; \
			forecolor 		colour \
			exp 			material ( texture ) \
			visible 		when ( visibility ) \
			decoration 		\
			extra			\
		}

#define CREATE_SHADER_ALT( position, texture, colour, visibility, extra ) \
		itemDef \
		{ \
			style 			WINDOW_STYLE_FILLED \
			rect 			position; \
			backcolor 		colour \
			background		texture \
			visible 		when ( visibility ) \
			decoration 		\
			extra			\
		}

#define CREATE_TEXT( position, string, color, visibility, extras ) \
		itemDef \
		{ \
			rect 			position; \
			style 			1 \
			forecolor 		color \
			exp 			text ( string ) \
			visible 		when ( visibility ) \
			textfont		UI_FONT_DEFAULT \
			decoration \
			extras \
		}

#define FOOTER_COL( idx )			( ( idx - 0 - ( ( idx - 0 ) % 1 ) ) / 1 )
#define FOOTER_X( idx ) 			( -52 + 70 * FOOTER_COL( idx ) )
#define FOOTER_Y 					463
#define FOOTER_ORIGIN( idx )		FOOTER_X( idx ) FOOTER_Y

#define REDUX_FOOTER_BUTTON( idx, key_kb, key_xbox, key_ps, string, visibility ) \
		CREATE_SHADER_ALT( FOOTER_ORIGIN( idx ) 14 14 1 0, key_ps, 1 1 1 1, visibility && dvarBool( "gpad_enabled" ) && dvarInt( "gpad_style" ) == 1, origin 0 0 ) \
		CREATE_SHADER_ALT( FOOTER_ORIGIN( idx ) 14 14 1 0, key_xbox, 1 1 1 1, visibility && dvarBool( "gpad_enabled" ) && dvarInt( "gpad_style" ) == 0, origin 0 0 ) \
		CREATE_SHADER_ALT( FOOTER_ORIGIN( idx ) 20 10 1 0, "white", 1 1 1 0.65, visibility && !dvarBool( "gpad_enabled" ), origin -5 2 ) \
		CREATE_TEXT( FOOTER_ORIGIN( idx ) 20 10 1 0, key_kb, 0 0 0 1, visibility && !dvarBool( "gpad_enabled" ), textfont 6; textscale 0.2; textstyle 0; textalign ITEM_ALIGN_MIDDLE_CENTER; origin -5 2 ) \
		CREATE_TEXT( FOOTER_ORIGIN( idx ) 0 10 1 0, string, 1 1 1 1, visibility, textscale 0.275; textstyle 3; textalign ITEM_ALIGN_MIDDLE_LEFT; textaligny -0.5; origin 20 2 )

#define REDUX_BACK_WIDGET \
		CREATE_SHADER( -68.5 460 284 20 1 0, "white", 0 0 0 1 ) \
		REDUX_FOOTER_BUTTON( 0, "ESC", "button_b", "button_ps3_circle", "Back", 1 )

#define REDUX_INGAME_MENU \
		focuscolor 					1 1 1 1 \
		blurworld 					7 \
		execKey "f" \
		{ \
			open "popup_friends"; \
		} \
		CREATE_SHADER( 215 -4 -40 640 1 0, "gradient_fadein", 0 0 0 0.5 ) \
		CREATE_SHADER( -68 -4 284 640 1 0, "white", 0 0 0 0.8; border 1; bordersize 0.5; bordercolor 1 1 1 0.1 ) \
		CREATE_TEXT( -50 ( _CHOICE_Y_START - 17 ) 0 0 1 1, MENU_TITLE, 1 1 1 1, 1, textfont 9; textscale 0.35; textstyle 3; textalign ITEM_ALIGN_MIDDLE_LEFT ) \
		CREATE_SHADER( -50 ( _CHOICE_Y_START - 7 ) 250 0.25 1 1, "white", 1 1 1 0.1 ) \
		REDUX_BACK_WIDGET

#define _CHOICE_GAMEPAD_Y			8 // getting lazy here :D
#define _CHOICE_X_START				-50
#define _CHOICE_Y_START				20
#define _CHOICE_X_SIZE				250
#define _CHOICE_Y_SIZE				32
#define _CHOICE_X_SPACING			( _CHOICE_X_SIZE + 4 )
#define _CHOICE_Y_SPACING			( _CHOICE_Y_SIZE + 4 )
#define _CHOICE_ROW( idx )			( ( idx - 0 ) % 24 )
#define _CHOICE_COL( idx )			( ( idx - 0 - ( ( idx - 0 ) % 24 ) ) / 24 )
#define _CHOICE_Y_TEXTALIGN			0

#define _CHOICE_X( idx ) 			( _CHOICE_X_START + _CHOICE_X_SPACING * _CHOICE_COL( idx ) )
#define _CHOICE_Y( idx ) 			( _CHOICE_Y_START + _CHOICE_Y_SPACING * _CHOICE_ROW( idx ) )
#define _CHOICE_ORIGIN( idx )		_CHOICE_X( idx ) _CHOICE_Y( idx )
#define _CHOICE_RECT( idx )			_CHOICE_ORIGIN( idx ) 250 _CHOICE_Y_SIZE 1 1

#define REDUX_BUTTON( idx, string, action_ ) \
		REDUX_BUTTON_VIS( idx, string, action_, 1 )

#define REDUX_BUTTON_VIS( idx, string, action_, visibility ) \
		REDUX_BUTTON_ALL( idx, string, action_, visibility, ;, ;, 0 )

#define REDUX_BUTTON_ALL( idx, string, action_, visibility, focus, leavefocus, disable_ ) \
		CREATE_SHADER_ALT( _CHOICE_ORIGIN( idx ) 32 _CHOICE_Y_SIZE 1 1, "white", 0 0 0 0, visibility && dvarBool( "gpad_enabled" ), origin 218 0; group idx ) \
		CREATE_SHADER_EX( _CHOICE_ORIGIN( idx ) 16 16 1 1, "button_ps3_cross", 1 1 1 0, visibility && dvarBool( "gpad_enabled" ) && dvarInt( "gpad_style" ) == 1, origin 226 _CHOICE_GAMEPAD_Y; group idx ) \
		CREATE_SHADER_EX( _CHOICE_ORIGIN( idx ) 16 16 1 1, "button_a", 1 1 1 0, visibility && dvarBool( "gpad_enabled" ) && dvarInt( "gpad_style" ) == 0, origin 226 _CHOICE_GAMEPAD_Y; group idx ) \
		itemDef \
		{ \
			rect 					_CHOICE_RECT( idx ) \
			type 					ITEM_TYPE_BUTTON \
			style					WINDOW_STYLE_FILLED \
			background      		"white" \
			visible 				when ( visibility ) \
			border					1 \
			bordercolor				1 1 1 0.05 \
			bordersize				0.25 \
			backcolor				1 1 1 0.01 \
			textfont 				0 \
			textaligny 				_CHOICE_Y_TEXTALIGN \
			textalignx 				8 \
			textscale 				0.275 \
			textstyle 				3 \
			textalign 				ITEM_ALIGN_MIDDLE_LEFT \
			exp text				( string ) \
			disabled				when ( disable_ ) \
			disablecolor			1 1 1 0.5 \
			onFocus \
			{ \
				if ( !( disable_ ) ) \
				{ \
					setItemColor 			self backcolor 1 1 1 0.09; \
					setItemColor 			self bordercolor 1 1 1 0.25; \
					setItemColor 			idx backcolor 0 0 0 0.9; \
					setItemColor 			idx forecolor 1 1 1 1; \
					focus; \
				} \
			} \
			leaveFocus \
			{ \
				setItemColor 			self backcolor 1 1 1 0.01; \
				setItemColor 			self bordercolor 1 1 1 0.05; \
				setItemColor 			idx backcolor 0 0 0 0; \
				setItemColor 			idx forecolor 0 0 0 0; \
				leavefocus; \
			} \
			action \
			{ \
				if ( !( disable_ ) ) \
				{ \
					action_; \
				} \
			} \
		}

#define REDUX_SEPARATOR( idx ) \
		REDUX_SEPARATOR_VIS( idx, 1 )

#define REDUX_SEPARATOR_VIS( idx, visibility ) \
		CREATE_SHADER_VIS( _CHOICE_ORIGIN( idx ) 250 4 1 1, "gradient_center", 1 1 1 0.05; origin 0 0, visibility )

#define INGAME_FACTION_ICON( pos, alpha ) \
		CREATE_SHADER_VIS( pos, dvarstring( "g_TeamIcon_Allies" ), 1 1 1 alpha, localvarstring( "ui_team" ) == "marines" ) \
		CREATE_SHADER_VIS( pos, dvarstring( "g_TeamIcon_Axis" ), 1 1 1 alpha, localvarstring( "ui_team" ) == "opfor" ) \
		CREATE_SHADER_VIS( pos, dvarstring( "g_TeamIcon_Allies" ), 1 1 1 alpha, team( "name" ) == "TEAM_FREE" && localvarstring( "ui_team" ) == "marines" ) \
		CREATE_SHADER_VIS( pos, dvarstring( "g_TeamIcon_Axis" ), 1 1 1 alpha, team( "name" ) == "TEAM_FREE" && localvarstring( "ui_team" ) == "opfor" )

// yikes
#define REDUX_GAME_WIDGET \
		itemDef \
		{ \
			name "fullmap_border" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			border 1 \
			bordersize 0.666667 \
			forecolor 1 1 1 1 \
			bordercolor 1 1 1 0.35 \
			textscale 0.55 \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 0.89 0.98 0.95 0.05 \
			background "minimap_scanlines" \
			textscale 0.55 \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			name "fullmap_map" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			ownerdraw 181 \
			forecolor 1 1 1 1 \
			background "compass_map_default" \
			type 8 \
			textscale 0.55 \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			name "fullmap_friendlies" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			ownerdraw 185 \
			forecolor 1 1 1 1 \
			type 8 \
			textscale 0.55 \
			exp forecolor a ( 1 - radarJamIntensity() ) \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			name "fullmap_enemies" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			ownerdraw 188 \
			forecolor 1 1 1 1 \
			type 8 \
			textscale 0.55 \
			exp forecolor a ( 1 - radarJamIntensity() ) \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			name "fullmap_objectives" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			ownerdraw 182 \
			forecolor 1 1 1 1 \
			background "objective_line" \
			type 8 \
			textscale 0.55 \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			name "fullmap_sentries" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			ownerdraw 189 \
			forecolor 1 1 1 1 \
			type 8 \
			textscale 0.55 \
			exp forecolor a ( 1 - radarJamIntensity() ) \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			name "fullmap_player" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			ownerdraw 183 \
			forecolor 1 1 1 1 \
			background "compassping_player" \
			type 8 \
			textscale 0.55 \
			exp forecolor a ( 1 - radarJamIntensity() ) \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 0.64 0.74 0.71 1 \
			background "white" \
			textscale 0.55 \
			exp forecolor a ( radarJamIntensity() ) \
			visible when ( radarIsJammed() && !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 0.89 0.98 0.95 1 \
			background "ac130_overlay_grain" \
			textscale 0.55 \
			exp forecolor a ( radarJamIntensity() ) \
			visible when ( radarIsJammed() && !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 1 1 1 1 \
			background "stencil_base" \
			textscale 0.55 \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 1 1 1 1 \
			background "scanlines_stencil" \
			textscale 0.55 \
			exp rect y ( ( 135 - 240 ) + ( ( 240 * 2 ) * ( 1 - ( ( milliseconds() ) % 4000 ) / 4000 ) ) ) \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 0.89 0.98 0.95 1 \
			background "stencil_fill" \
			textscale 0.55 \
			visible when ( !isEMPJammed() ) \
		} \
		INGAME_FACTION_ICON( -90 -20 96 96 3 1, 0.2 ) \
		CREATE_TEXT( 0 0 0 20 3 1, getMapName(), 1 1 1 1, 1, textfont 9; textalignx 8; textscale 0.35; textstyle 3; textalign ITEM_ALIGN_TOP_RIGHT ) \
		CREATE_TEXT( 0 20 0 20 3 1, gametypeName(), 1 1 1 0.85, 1, textfont 6; textalignx 8; textscale 0.2; textstyle 3; textalign ITEM_ALIGN_TOP_RIGHT ) \
		CREATE_TEXT( -150 35 150 40 3 1, gametypeDescription(), 1 1 1 0.65, 1, textfont 0; textalignx 8; textscale 0.275; textstyle 3; textalign ITEM_ALIGN_TOP_RIGHT )

#define CHANGE_CLASS_ACTION	\
		if ( localvarstring( "ui_team" ) == "marines" ) \
		{ \
			scriptmenuresponse "changeclass_marines"; \
		} \
		if ( localvarstring( "ui_team" ) == "opfor" ) \
		{ \
			scriptmenuresponse "changeclass_opfor"; \
		}