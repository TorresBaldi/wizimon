//------------------------------------------------------------------------------------------------------------------

CONST

	// variables de desarrollo
	DEBUG_MODE = FALSE;
	GAME_VERSION = "0.6.1";

	// game_mode
	GAMEMODE_CLASSIC 	= 0;
	GAMEMODE_SPRINT 	= 1;
	GAMEMODE_SHUFFLE 	= 2;
	
	// game_turn
	DISPLAY	= 0;
	PLAYER	= 1;
	CPU 	= 2;

END

//------------------------------------------------------------------------------------------------------------------

GLOBAL
	
	// recursos
	int fpg;
	int fnt_smaller;
	int fnt_small;
	int fnt_medium;
	int fnt_medium2;
	int fnt_large;
	int fnt_display;
	int song;
	int beep;
	
	// modo wiz
	int wiz;	// flag true/false
	
	// control del juego/partida
	STRUCT game
	
		// id del proceso game
		int id;
	
		// secuencia de botones
		int seq[50];
		int seq_size;
		int seq_pos;
		
		int shuffle;	// indica si debo mezclar
		
		// administracion de turnos
		int turn;
		int turn_change;
		int turn_last;
		int turn_time;
		int turn_time_left;
		
		// estados de botones
		int button_active = FALSE;
		int button_time;
		
		int score;
		int over; //game over
		
		int cursor_id;	// id del cursor
	
	END
	
	// archivo de datos
	STRUCT data
		
		// records para los 3 modos de juegos
		STRUCT record[3]
		
			// guardo los 3 mejores jugadores
			int score[3] = 9, 6, 3;
			string name[3] = "Flore", "Stella", "Gecko";
		
		END
		
		// configuraciones del juego	
		int volume = 90;
		int play_music = TRUE;
		
	END
	
	song_id;
	beep_id;
	
	//menu principal
	menu_button_id;		// boton seleccionado
	
	// indica si se ajusto el volumen
	volume_change;
	
	// teclas globales
	GLOBAL_KEY_OK;		// si se presiono alguno de los botones de aceptar
	GLOBAL_KEY_CANCEL;	// botones de cancelar

END
