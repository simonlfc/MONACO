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
			decoration \
			extras \
		}
		
#define REDUX_BACK_WIDGET \
		CREATE_SHADER( -68.5 460 284 20 1 0, "white", 0 0 0 1 ) \
		CREATE_SHADER_VIS( -52 463 14 14 1 0, "button_ps3_circle", 1 1 1 1, dvarBool( "gpad_enabled" ) && dvarInt( "gpad_style" ) == 1 ) \
		CREATE_SHADER_VIS( -52 463 14 14 1 0, "button_b", 1 1 1 1, dvarBool( "gpad_enabled" ) && dvarInt( "gpad_style" ) == 0 ) \
		CREATE_SHADER_VIS( -57 465 20 10 1 0, "white", 1 1 1 0.65, !dvarBool( "gpad_enabled" ) ) \
		CREATE_TEXT( -57 465 20 10 1 0, "ESC", 0 0 0 1, !dvarBool( "gpad_enabled" ), textfont 6; textscale 0.2; textstyle 0; textalign ITEM_ALIGN_MIDDLE_CENTER ) \
		CREATE_TEXT( -68.5 460 284 20 1 0, "Back", 1 1 1 1, 1, textfont 0; textscale 0.275; textstyle 3; textalign ITEM_ALIGN_MIDDLE_LEFT; textalignx 36 )

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
		CREATE_TEXT( 0 -2 640 480 2 0, getmapname(), 1 1 1 1, 1, textfont 0; textalignx 8; textscale 0.275; textstyle 3; textalign ITEM_ALIGN_MIDDLE_LEFT ) \
		CREATE_TEXT( 0 0 640 480 2 0, gametypename(), 1 1 1 1, 1, textfont 0; textalignx 8; textscale 0.275; textstyle 3; textalign ITEM_ALIGN_MIDDLE_LEFT ) \
		CREATE_TEXT( 0 20 640 480 2 0, gametypedescription(), 1 1 1 1, 1, textfont 0; textalignx 8; textscale 0.275; textstyle 3; textalign ITEM_ALIGN_MIDDLE_LEFT )

#define CHANGE_CLASS_ACTION	\
		if ( localvarstring( "ui_team" ) == "marines" ) \
		{ \
			scriptmenuresponse "changeclass_marines"; \
		} \
		if ( localvarstring( "ui_team" ) == "opfor" ) \
		{ \
			scriptmenuresponse "changeclass_opfor"; \
		}