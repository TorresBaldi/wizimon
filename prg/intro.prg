//------------------------------------------------------------------------------------------------------------------
PROCESS intro()
//
// Reproduce la presentacion
// Se basa en tiempo y no en frames
//

PRIVATE

	// tiempo que se muestra cada logo
	int time_total = 400;
	
	// logos
	int logo_current;
	int logo_total = 2;
	
	// textos de debug
	int txt_id[2];
	
	//indica si la intro se puede saltear
	int skippable;
	int skip;

END

BEGIN

	// centro en pantalla
	x = 160/2;
	y = 120/2;
	graph = 100;
	
	// muestro textos
	IF( DEBUG_MODE )
		txt_id[0] = write_var(0, 0, 10, 0, logo_current);
		txt_id[1] = write_var(0, 0, 20, 0, timer[0]);
	END

	// empieza a punto de cambiar de fase
	timer[0] = time_total - 5;
	
	//comprueba si la intro se puede saltear
	skippable = check_savedata();
	
	LOOP
	
		// salteo la presentacion
		IF ( skippable )
			IF ( GLOBAL_KEY_OK AND timer[0] > 100 )
			
				skip++;
				
				IF ( skip == 1 )
					timer[0] = time_total;
				END
				
			ELSE
				skip = 0;
			END
		END
		
		IF ( timer[0] > time_total )
		
			// efecto de transision
			intro_fade(2);
			
			// reinicio el timer
			timer[0] = 0;
			
			//avanzo un logo
			logo_current++;
			graph++;
			
		END
		
		// termino la presentacion
		IF ( logo_current > logo_total )
			break;
		END
		
		FRAME;
		
	END

	
ONEXIT

	//borro los textos
	IF ( DEBUG_MODE )
		delete_text(txt_id[0]);
		delete_text(txt_id[1]);
	END
	
	// voy a la pantalla inicial
	splash_screen();
	
	// inicializo el cursor
	game.cursor_id = game_cursor();
	
END

//------------------------------------------------------------------------------------------------------------------
PROCESS intro_fade(speed)
//
// Toma un screenshot, oscurece la pantalla, y luego vuelve a aclararla
//

PRIVATE
	int aux_id;
END


Begin

	// sigo mostrando la pantalla anterior mientras hago el fade
	graph = get_screen();
	x = 160/2;
	y = 120/2;
	z = -999;
	
	// elimino a algun otro proceso fade
	if ( fading )
	
		aux_id = get_id(type intro_fade);
		while ( aux_id <> 0 )
			//say("aux_id:" + aux_id);
			IF ( aux_id <> id )
				signal(aux_id, s_kill);
				//say("ELIMINO OTRO INTRO");
			END
			aux_id = get_id(type intro_fade);
		end
		//say("aux_id:" + aux_id);
	end

	fade(0,0,0,speed); // Fade to black
	while(fading) frame; end // Wait for the fading to finish

	graph = 0;
	
	fade(100,100,100,speed); // Fade to normal
	while(fading) frame; end // Wait for the fading to finish
	
End

//------------------------------------------------------------------------------------------------------------------
PROCESS splash_screen()
//
// Muestra la pantalla de introduccion
//

PRIVATE

	int time;
	
	int graph1 = 70;
	int graph2 = 72;
	
	int txt_ver;

END

BEGIN

	file = fpg;

	graph = graph1;
	
	x = 160/2;
	y = 120/2;
	
	// escribo la version
	txt_ver = write(fnt_smaller, 159, 0, 2, "v" + GAME_VERSION);
	
	//inicio el conteo de tiempo
	timer[0] = 0;
	
	IF ( WIZ )
		graph2 = 71;
	END
	
	// hasta que no se sueltan teclas no arranca
	while ( GLOBAL_KEY_OK )
		frame;
	end

	LOOP
		
		// cambio de grafico
		IF ( timer[0] > 50 )
			timer[0] = 0;
			
			IF ( graph == graph1 )
				graph = graph2;
			ELSE
				graph = graph1;
			END

		END
		
		// al hacer click paso al menu principal
		IF ( GLOBAL_KEY_OK )
		
			main_menu();
			
			break;
			
		END
		
	
		frame;
		
	END
	
ONEXIT

	delete_text(txt_ver);

	screenchange();
	
END

