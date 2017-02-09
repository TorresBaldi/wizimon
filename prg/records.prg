//------------------------------------------------------------------------------------------------------------------
PROCESS records(int game_mode)
//
// Muestra la pantalla de records
//

PRIVATE

	txt_id[20];
	
	int i;
	
	string game_mode_string;
	
	int delay = 20;
	
	int score = 0;
	int score_delay = 3;
	
	// sobre records
	int record;
	int record_id = -1;
	int record_font;
	string record_name;

END

BEGIN
	
	put_screen(fpg,62);
	
	txt_id[0] = write(fnt_medium2, 160/2, 8, 1, "Score");
	
	while ( GLOBAL_KEY_OK or DELAY > 0)
		delay--;
		frame;
	end

	txt_id[1] = write_var(fnt_large, 160/2, 17, 1, score);

	delay = 0;
	
	LOOP
	
		//acelero con teclas
		IF ( GLOBAL_KEY_OK )
			delay++;
		END
	
		// aumento los puntos del juegador
		IF ( score < game.score )
		
			delay++;
			IF ( delay > score_delay )
				score++;
				delay = 0;
			END
			
		//cuando termino, muestro los records
		ELSE		
			
			// compruebo si el puntaje fue record
			IF ( is_record(game_mode, game.score) and !record )
			
				// para evitar que se siga preguntando
				record = true;				
				IF ( DEBUG_MODE ) say("Nuevo Record"); END
				
				alert("NEW", "RECORD", 80, 82);
				// ingreso el nombre
				record_name = wizkeyboard("data/keyboard.fpg", "Enter your name",10);
				
				// guardo el record si se ingreso
				IF ( record_name <> "" )
					//guardo el record
					record_id = record_save(game_mode, game.score, record_name);
					IF ( DEBUG_MODE ) say(record_name + ", id: " + record_id); END
				END
				
			END
			
			
			delay++;

			IF ( delay == 20 )
			
				SWITCH ( game_mode )
					CASE GAMEMODE_CLASSIC:
						game_mode_string = "CLASSIC MODE";
					END
					CASE GAMEMODE_SHUFFLE:
						game_mode_String = "SHUFFLE MODE";
					END
				END
				
				txt_id[2] = write(fnt_medium2, 160/2, 53, 1, game_mode_string);
			END

			
			// imprimo la lista de puntajes
			IF ( delay == 60 AND i<3)
				delay = 40;
				
				// si es el record del jugador
				IF ( record_id == i )
					record_font = fnt_medium2;
				ELSE
					record_font = fnt_medium;
				END
				
				txt_id[ 3 + (i*3) ] = write(record_font, 10, (i*14) + 75, 3, "["+(i+1)+"]");
				txt_id[ 4 + (i*3) ] = write(record_font, 30, (i*14) + 75, 3, data.record[game_mode].name[i]);
				txt_id[ 5 + (i*3) ] = write(record_font, 140,(i*14) + 75, 5, data.record[game_mode].score[i]);
				i++;
			END			
		
		END
	
		IF ( GLOBAL_KEY_OK AND delay > 70 )
			break;
		END
	
		frame;
	END
	
	clear_screen();	
	splash_screen();
	
ONEXIT

	FOR (i=0; i<20; i++)
		IF ( txt_id[i] )
			delete_text( txt_id[i] );
		END
	END
	

	screenchange();

END

//------------------------------------------------------------------------------------------------------------------
FUNCTION is_record( int game_mode, int score)
//
// Comprueba si el puntaje es un record
//

PRIVATE
	i;
END

BEGIN

	// compruebo la lista de puntajes
	for (i=0; i<3; i++)
	
		if ( score > data.record[game_mode].score[i] )
			return TRUE;
		end
	
	end
	
	// si no se supero ningun puntaje, devuelve false
	return FALSE;

END

//------------------------------------------------------------------------------------------------------------------
FUNCTION int record_save(int game_mode, int score, string name)
//
// Guardo el record en la tabla de puntajes
//

PRIVATE

	int i;
	int j;
	
	int aux_score;
	string aux_name;

END

BEGIN

	// recorro la lista de puntajes
	for (i=0; i<3; i++)	
	
		// busco el primer valor que supero
		if ( score > data.record[game_mode].score[i] )
			// salgo del for
			break;
		end
	end
	
	// desplazo la lista un lugar hacia abajo
	for ( j=2; j>i; j-- )
		
		data.record[game_mode].score[j] = data.record[game_mode].score[j-1];
		data.record[game_mode].name[j] = data.record[game_mode].name[j-1];
	
	end
	
	// agrego el valor nuevo a la lista
	data.record[game_mode].score[i] = score;
	data.record[game_mode].name[i] = name;
	
	save("config.dat", data);
	
	return i;

END
