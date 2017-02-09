//------------------------------------------------------------------------------------------------------------------
PROCESS sequencer(int game_mode)
//
// Proceso que genera y reproduce la secuencia de botones
//

PRIVATE

	int i;

	int counter;
	
	// dificultad
	int button_delay 	= 10;	// tiempo entre botones
	int button_time 	= 25;	// tiempo que se presiona boton
	
	int button_end;	// indica si paso al siguiente boton
	
	int random_number;
	int random_pos;
	
END

BEGIN

	IF ( game_mode == GAMEMODE_CLASSIC OR game_mode == GAMEMODE_SPRINT )
	
		// agrego un valor a la secuencia
		game.seq[game.seq_size] = rand(BTN_GREEN,BTN_BLUE);
		game.seq_size++;
		
		// si es sprint los muestro mas rapido
		IF ( game_mode == GAMEMODE_SPRINT )
			button_delay = 8;
			button_time = 20;
		END
		
	ELSEIF ( game_mode == GAMEMODE_SHUFFLE )
	
		game.shuffle++;
			
		// en 1 de cada 3 turnos mezclo
		IF ( game.shuffle % 3 == 0 )

			IF ( DEBUG_MODE ) say("Shuffle!"); END
		
			// eligo un numero y un valor
			random_number = rand(BTN_GREEN,BTN_BLUE);
			random_pos = rand(0,game.seq_size-1);
			
			IF ( DEBUG_MODE ) say("original: numero: "+random_number+", pos: "+random_pos); END
			
			// si se repite, elijo otro
			while ( game.seq[random_pos] == random_number )
				say("cambio de numero");
				random_number = rand(BTN_GREEN,BTN_BLUE);
				random_pos = rand(0,game.seq_size-1);
			end

			IF ( DEBUG_MODE ) say("final: numero: "+random_number+", pos: "+random_pos); END
			
			// y finalmente lo cambio
			game.seq[random_pos] = random_number;
		
		// para los otros 2
		ELSE
		
			// agrego un valor a la secuencia
			game.seq[game.seq_size] = rand(BTN_GREEN,BTN_BLUE);
			game.seq_size++;
			
		END
		
	
	END
	
	
	IF ( DEBUG_MODE ) say("seq_size: " + game.seq_size); END
	
	//reproduzco la secuencia nueva
	FOR ( i=0; i<game.seq_size; i++ )
	
		//say("Reproduzco secuencia, lugar: " + i);
		
		button_end = false;
		counter = 0;
		
		WHILE ( !button_end )
			
			counter++;

			// depediendo el valor de counter
			IF ( counter < button_time )
			
				// activo el boton
				game.button_active = game.seq[i];
				
			ELSEIF ( counter < button_time+button_delay )
			
				// espero el delay (desactivado)
				game.button_active 	= FALSE;
				game.button_time 	= FALSE;
				
			ELSE
				// paso al siguente boton en la secuencia
				button_end = true;
			END

			frame;
			
		END
		
	END
	
	// al terminar la secuencia paso al siguiente turno
	game.turn_change = true;
	
END
