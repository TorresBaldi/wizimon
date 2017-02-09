//------------------------------------------------------------------------------------------------------------------
PROCESS game(int game_mode)
//
// inicializa y controla el juego
// Controla los cambios de turnos
//

PRIVATE
	int i;
	
	int id_button[4];
	int id_display;
	
	//dialogos
	int pausa;
	int salir;
	int respuesta;
	
END

BEGIN

	// reinicio parametros para una nueva partida
	game_reset();
	
	// inicio los procesos
	game_turns(game_mode);
	game_logic(game_mode);
	game_display(game_mode);
	
	button(BTN_GREEN);
	button(BTN_RED);
	button(BTN_YELL);
	button(BTN_BLUE);
	
	// espero a que se suelten botones para iniciar el juego
	while ( GLOBAL_KEY_OK )
		frame;
	end

	LOOP
	
		// MUESTRO DIALOGO DE SALIR
		IF ( GLOBAL_KEY_CANCEL AND !salir )
		
			salir = true;
			
			signal_action(S_FREEZE_TREE, S_IGN);
			signal(id, S_FREEZE_TREE);
			
			respuesta = dialog("EXIT?", "Return", "EXIT");
			
			IF ( respuesta )
			
				splash_screen();
				signal(ID, S_WAKEUP_TREE);
				signal(id, S_KILL);
				
			ELSE
				salir = false;
				
				signal(ID, S_WAKEUP_TREE);
				signal_action(S_FREEZE_TREE, S_DFL);
				
			END
			
		END		
	
		frame;
		
	END

ONEXIT

	screenchange();
	game.id = 0;

END

//------------------------------------------------------------------------------------------------------------------
PROCESS game_cursor()
//
// flechita del cursor
// usado para detectar colisiones
//

BEGIN

	file = fpg;
	graph = 50;
	
	z = -999;
	
	// oculto el cursor en WIZ
	IF ( WIZ )
		alpha = 0;
	END
	

	LOOP
	
		x = mouse.x;
		y = mouse.y;
	
		frame;
		
	END

END

//------------------------------------------------------------------------------------------------------------------
FUNCTION game_reset()
//
// Engloba todas las tareas a realizar cuando se inicia una partida
//

PRIVATE

	int i;
	
END

BEGIN

	// informo que se inicia una nueva partida
	IF ( DEBUG_MODE ) say("iniciado nuevo juego"); END
	
	// indico la id del proceso GAME
	game.id = father.id;
	
	//cargo el fondo de la pantalla
	clear_screen();
	put_screen(fpg, 1);
	
	// inicializo los turnos
	game.turn = PLAYER;
	game.turn_last = PLAYER;
	game.turn_change = TRUE;
	
	// vacio la secuencia de botones
	game.seq_size = 0;
	game.seq_pos = 0;
	
	game.shuffle = false;
	
	game.score = 0;
	
	//indico que el juego no termino
	game.over = false;
	
	// para generar nuevos aleatorios siempre
	rand_seed( time() );
	
END

//------------------------------------------------------------------------------------------------------------------
PROCESS game_turns(int game_mode)
//
// Descripcion del Proceso
//

PRIVATE
	int i;
	
	int display_time = 80;
	
END

BEGIN

	// acelero los turnos de display en el modo sprint
	IF ( game_mode == GAMEMODE_SPRINT )
		display_time = 50;
	END

	LOOP
	
		// salgo cuando termina la partida
		IF ( !exists(father) )
			signal(id, S_KILL);
		END

		game.turn_time++;
	
		// cambio de turno si corresponde
		// DISPLAY - CPU - DISPLAY - PLAYER
		IF ( game.turn_change )
		
			game.turn_change = FALSE;
			game.turn_time = 0;
			
			IF ( game.turn == DISPLAY )
			
				IF ( game.turn_last == PLAYER )
				
					game.turn = CPU;
					
				ELSE
					
					game.turn = PLAYER;
					
				END
				
				
			ELSE
			
				game.turn_last = game.turn;
				game.turn = DISPLAY;
				
			END
			
			
		END
		
		//reacciono de acuerdo al turno
		SWITCH ( game.turn )
		
			CASE DISPLAY:
				
				IF ( game.turn_time == 0 )	// si recien empieza el turno
					IF ( DEBUG_MODE ) say("---- Turno Display ----"); END
				END
				
				// si termino el turno, cambia de turno
				IF ( game.turn_time > display_time AND !game.over)
					game.turn_change = true;
				END
						
				// si perdio, termina el proceso game
				// y pasa a la pantalla de records				
				IF ( game.over)
				
					IF ( GLOBAL_KEY_OK OR game.turn_time > 100  )
						
						// me voy a records
						records( game_mode );
						
						// y termino el juego
						signal(father, S_KILL);
						
					END
					
				END
				
			END
			
			CASE CPU:
				
				IF ( game.turn_time == 0 )	// si recien empieza el turno
					IF ( DEBUG_MODE ) say("---- Turno CPU ----"); END
					
					sequencer(game_mode);
					
				END
				
			END
			
			CASE PLAYER:
				
				IF ( game.turn_time == 0 )	// si recien empieza el turno
					IF ( DEBUG_MODE ) say("---- Turno JUGADOR ----"); END
					
					// reinicio tiempos de botones
					game.button_time = 0;
					
					///*
					IF ( DEBUG_MODE )
						// muestro secuencia
						FOR (i=0;i<game.seq_size;i++)
							say("game.seq["+i+"] = " + game.seq[i]);
						END	
					END
					//*/
					
				END
				
			END
			
		END

	
		frame;
		
	END

END


//------------------------------------------------------------------------------------------------------------------
PROCESS game_logic(int game_mode)
//
// Comprueba si las pulsaciones del usuario son correctas
//

PRIVATE

	// "eventos" de botones
	int button_active;
	int button_down;
	int button_up;
	
	// tiempo
	int button_time = 20;

	// info de debug
	int txt[10];
	string turn;
	string button;

END

BEGIN

	// justo despues de los botones
	priority = 40;

	LOOP
	
		// se destruye cuando se acaba el juego
		IF ( !game.id )
			break;
		END
		
		// genero los "eventos" de los botones
		IF ( game.button_active )
			IF ( game.button_time == 1 )
				button_down = true;
				button_active = true;
			ELSE
				button_down = false;
			END
		ELSE
			IF ( button_up )
				button_up = false;
			ELSEIF ( button_active )
				button_active = false;
				button_up = true;
			END
		END
		
		// testeo eventeos
		IF ( DEBUG_MODE )
			IF ( button_down )
				say("APRETO " + game.button_active + "!");
			ELSEIF ( button_up )
				say("suelto");
			END
		END
		
		
		// calculo tiempos en modo sprint
		IF ( game_mode == GAMEMODE_SPRINT AND game.turn_time == 1 )
		
			game.turn_time_left = game.seq_size * button_time;
			
			// bonus
			IF ( game.seq_size < 3 )
				game.turn_time_left += 15;
			END
			
		END
		
		
		// compruebo las teclas del jugador
		IF ( game.turn == PLAYER )
			
			// compruebo tiempos en modo sprint
			IF ( game_mode == GAMEMODE_SPRINT  )
			
				game.turn_time_left--;
				
				IF ( game.turn_time_left < 0 )
					game.over = true;
					game.turn_change = true;
				END
				
			END
			
			IF ( game.seq_pos < game.seq_size )	// si todavia no termino de recorrer la secuencia
			
				// al presionar boton, compruebo si es correcto
				IF ( button_down AND game.seq[game.seq_pos] <> game.button_active )
				
					game.over = true;
					
					// reproduzco sonido
					play_wav( beep, 0 );
					
					
				END
				
				// al soltar boton
				IF ( button_up )
				
					// si el boton fue el correcto, sigo con la secuencia
					IF ( !game.over )
					
						game.seq_pos++;
					
					// si fue incorrecto, termina el turno y el juego
					ELSE
					
						game.over = true;
						game.turn_change = true;
						
					END
				
				END
			
			ELSE	// si ya termino la secuencia
							
				// aumento puntaje del jugador
				IF ( DEBUG_MODE ) say("score++"); END
				game.score++;
				
				// reinicio cursor de secuencia y termino el turno
				game.seq_pos = 0;
				game.turn_change = true;
				
			END
		
		END
		
		// muestro informacion de la partdida
		IF ( DEBUG_MODE )
		
			// traduzco la constante turn
			SWITCH ( game.turn )
				CASE CPU:		turn = "CPU"; END
				CASE PLAYER:	turn = "PLAYER"; END
				CASE DISPLAY:	turn = "DISPLAY"; END
			END
			
			// traduzco la constante button
			SWITCH ( game.button_active )
				CASE BTN_GREEN:	button = "VERDE"; END
				CASE BTN_RED:	button = "ROJO"; END
				CASE BTN_YELL:	button = "AMARILLO"; END
				CASE BTN_BLUE:	button = "AZUL"; END
				DEFAULT:		button = NULL; END
			END
			
			txt[0] = write(fnt_smaller, 0, 20, 0, turn);
			txt[1] = write(fnt_smaller, 0, 30, 0, "Score:" + game.score);
			txt[2] = write(fnt_smaller, 0, 40, 0, button );
			txt[3] = write(fnt_smaller, 0, 50, 0, game.button_time );
			txt[4] = write(fnt_smaller, 0, 70, 0, "turn time:" + game.turn_time );
			txt[5] = write(fnt_large, 120, -5, 0, game.turn_time_left );
		
		END
		
	
		frame;
		
		// borro textos
		IF ( DEBUG_MODE )
			delete_text (txt[0]);
			delete_text (txt[1]);
			delete_text (txt[2]);
			delete_text (txt[3]);
			delete_text (txt[4]);
			delete_text (txt[5]);
		END
		
	END

END




