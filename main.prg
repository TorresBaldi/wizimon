import "mod_map";
import "mod_proc";
import "mod_file";
import "mod_grproc";
import "mod_rand";
import "mod_say";
import "mod_screen";
import "mod_sound";
import "mod_text";
import "mod_timers";
import "mod_video";
import "mod_time";
import "mod_wm";
import "mod_math";
import "mod_debug";

//------------------------------------------------------------------------------------------------------------------

// variables
include "prg/globals.prg";

// librerias externas
include "prg/jkeys.lib";
include "prg/keyboard.prg";

// codigo del juego
include "prg/functions.prg";
include "prg/buttons.prg";
include "prg/sequencer.prg";
include "prg/display.prg";
include "prg/intro.prg";
include "prg/records.prg";
include "prg/game.prg";
include "prg/menu.prg";

//------------------------------------------------------------------------------------------------------------------

BEGIN

	// detecto si se ejecuta en WIZ
	IF ( OS_ID == OS_GP2X_WIZ OR OS_ID == OS_CAANOO )
	
		// inicializo video WIZ
		scale_resolution = 03200240;
		set_mode(160,120,16,mode_fullscreen);
		set_fps(60,0);

		wiz = TRUE;
		
	ELSE
	
		// inicializo video PC
		set_title("WIZimon (" + GAME_VERSION + ")");
		
		scale_resolution = 06400480;
		set_mode(160,120,16,mode_window + mode_waitvsync);
		set_fps(60,0);

		wiz = FALSE;
		
	END
	
	// cargo recursos
	fpg 		= load_fpg("data/fpg.fpg");
	fnt_smaller	= load_fnt("data/04b03.fnt");
	fnt_small	= load_fnt("data/04b03-outline.fnt");
	fnt_medium	= load_fnt("data/pftempesta.fnt");
	fnt_medium2	= load_fnt("data/pftempesta-outline.fnt");
	fnt_large	= load_fnt("data/pftempesta-2x-outline.fnt");
	fnt_display	= load_fnt("data/display-numbers.fnt");
	song		= load_song("audio/wallpaper.ogg");
	beep		= load_wav("audio/beep.wav");
	
	IF ( DEBUG_MODE ) write_var(fnt_smaller,0,0,0,fps); END

	
	//inicializo deteccion de teclas
	jkeys_set_default_keys();
	jkeys_init();
	global_keys();

	// inicializo la pantalla de presentacion
	intro();
	
	//manejo de musica y volumen
	music_manager();
	volume_control();

	LOOP
	
		// en DEBUG_MODE sale con ESC
		IF ( ( DEBUG_MODE AND JKEYS_STATE[_JKEY_MENU] ) )
			exit();
		END
	
		frame;		
		
	END
	

END

//------------------------------------------------------------------------------------------------------------------
PROCESS global_keys()
//
// Compruebo teclas basicas
//

BEGIN

	priority = 999998;	// se ejecuta justo despues de jkeys

	LOOP
	
		// BOTONES ACEPTAR
		IF ( mouse.left OR JKEYS_STATE[_JKEY_SELECT] OR JKEYS_STATE[_JKEY_B] )
			GLOBAL_KEY_OK = TRUE;
		ELSE
			GLOBAL_KEY_OK = FALSE;
		END
	
		// BOTONES CANCELAR
		IF ( JKEYS_STATE[_JKEY_MENU] OR JKEYS_STATE[_JKEY_X] )
			GLOBAL_KEY_CANCEL = TRUE;
		ELSE
			GLOBAL_KEY_CANCEL = FALSE;
		END
		
		frame;
		
	END

END

//------------------------------------------------------------------------------------------------------------------
PROCESS music_manager()
//
// Inicia y detiene la musica al terminar/comenzar una partida
//

PRIVATE

	// opciones
	int fade_time = 800;
	
	int playing;
END

BEGIN

	// cargo el volumen de las opciones
	set_song_volume( data.volume );

	// play inicial
	fade_music_in(song, -1, fade_time);
	
	playing = true;

	LOOP
	
		// detengo durante el juego
		IF ( game.id )
		
			IF ( playing )
			
				fade_music_off( fade_time );
				playing = false;
				
			END
		
		// enciendo fuera del juego
		ELSE
		
			IF ( !playing )
				
				fade_music_in( song, -1, fade_time );
				playing = true;
				
			END
		
		END
		
		// ajusto el volumen
		IF ( volume_change )
			set_song_volume( data.volume );
		END
	
		frame;
		
	END

END


