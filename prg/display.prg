//------------------------------------------------------------------------------------------------------------------
CONST

	// numeros dentro del fpg
	SCREEN_OFF 			= 2;
	SCREEN_MYTURN 		= 3;
	SCREEN_YOURTURN 	= 4;
	SCREEN_GAMEOVER 	= 5;
	SCREEN_TIME 		= 6;
	SCREEN_ERROR		= 7;
	

END

//------------------------------------------------------------------------------------------------------------------
PROCESS game_display(int game_mode)
//
// Proceso controlador del display central
//

PRIVATE

	png_cpu;
	png_player;
	png_off;
	
	txt_id;

END

BEGIN
	
	// posiciono el display
	x = 160/2 +1;
	y = 120/2;
	z = -5;

	LOOP
	
		// se destruye cuando se acaba el juego
		IF ( !game.id )
			break;
		END
	
		graph = SCREEN_OFF;
		
		//cambia el grafico si el turno es del display
		IF ( game.turn == DISPLAY )
			
			IF ( game.turn_last == CPU )
				
				// anuncia turno del jugador
				graph = SCREEN_YOURTURN;
				
				// se puede cortar el turno del display y empezar a jugar
				IF ( mouse.left )
					game.turn_change = true;
				END
				
			ELSE
			
				// anuncia turno CPU
				graph = SCREEN_MYTURN;
				
			END
			
			// ejecuto el game over
			IF ( game.over )
				
				graph = SCREEN_GAMEOVER;
				
				
			END
			
		ELSE

			// indica que se presiono el boton incorrecto
			IF ( game.over )
				graph = SCREEN_ERROR;
			END
			
			IF ( game_mode == GAMEMODE_SPRINT )
				graph = SCREEN_TIME;
				text_z = z-1;
				txt_id = write(fnt_display, 82, 64, 4, game.turn_time_left / 10);
				text_z = -256;
			END
			
		END
		
	
		frame;
		
		IF ( game_mode == GAMEMODE_SPRINT AND txt_id)
			delete_text(txt_id);
			txt_id = FALSE;
		END

		
	END

END
