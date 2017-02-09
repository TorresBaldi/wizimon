CONST

	BTN_GREEN	= 1;
	BTN_RED		= 2;
	BTN_YELL	= 3;
	BTN_BLUE	= 4;

END

//------------------------------------------------------------------------------------------------------------------
PROCESS button(index)
//
// Botones de colores
// Funcionan controlados por CPU y por JUGADOR
//

PRIVATE

	int i;

	// id de recursos
	int png_normal;
	int png_active;
	
	int wav_id;
	
	// indico si el boton esta activo
	int is_active;
	
	// sonidos
	int is_playing;
	int play_channel;

END

BEGIN

	priority = 50;

	file = fpg;

	// configuro los 4 botones
	SWITCH ( index )
	
		CASE BTN_GREEN:	// boton verde
			png_normal = 10;
			png_active = 11;
			x = 28 + 25;
			y = 28 + 4;
			wav_id = load_wav("audio/500.wav");
		END
		
		CASE BTN_RED:	//boton rojo
			png_normal = 20;
			png_active = 21;
			x = 28 + 81;
			y = 28 + 4;
			wav_id = load_wav("audio/600.wav");
		END
		
		CASE BTN_YELL:	// boton amarillo
			png_normal = 30;
			png_active = 31;
			x = 28 + 25;
			y = 28 + 60;
			wav_id = load_wav("audio/700.wav");
		END
		
		CASE BTN_BLUE:	// boton azul
			png_normal = 40;
			png_active = 41;
			x = 28 + 81;
			y = 28 + 60;
			wav_id = load_wav("audio/800.wav");
		END
		
	END
	
	graph = png_normal;
	
	set_wav_volume(wav_id, data.volume);
	

	LOOP
	
		// se destruye cuando se acaba el juego
		IF ( !game.id )
			break;
		END
		
		// ajusto el volumen
		IF ( volume_change )
			set_wav_volume(wav_id, data.volume);
		END
	
		// CONTROLADOS POR LA CPU
		IF ( game.turn == CPU )
		
			IF ( game.button_active == index )	// boton activado
			
				is_active = true;
				
			ELSE	// boton normal
			
				is_active = false;
				
			END
		
		// CONTROLADOS POR EL JUGADOR
		ELSEIF ( game.turn == PLAYER )
		
			// si presiono con el mouse
			IF ( collision ( type mouse ) AND mouse.left )
				
				IF ( !game.button_active OR game.button_active == index )
				
					is_active = TRUE;

					game.button_active = index;
					
				END
			
			END
			
			// si se suelta el boton del mouse
			IF ( !mouse.left AND game.button_active == index AND game.button_time > 1 )
			
				say("tiempo: " + game.button_time);
				
				is_active = FALSE;
			
				game.button_active = FALSE;
				game.button_time = FALSE;
				
			END
		
		END
		
		
		// activo y desactivo el boton
		IF ( is_active )
		
			game.button_time++;
			
			//say("game.btime: " + game.button_time);
			
			graph = png_active;
			IF ( !is_playing and !game.over )
				is_playing = true;
				play_channel = play_wav(wav_id, -1);
			END
			
		ELSE
			
			graph = png_normal;
			IF ( is_playing )
				is_playing = stop_wav(play_channel);
			END

		END
	
		frame;
		
		// detengo sonido en game.over
		IF ( is_playing AND game.over )
			is_playing = stop_wav(play_channel);
		END
		
	END
	
ONEXIT

	// por las dudas
	stop_wav(play_channel);

END

