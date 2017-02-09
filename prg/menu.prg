//------------------------------------------------------------------------------------------------------------------
CONST

	MENU_CLASSIC	= 0;
	MENU_SPRINT		= 1;
	MENU_SHUFFLE	= 2;
	MENU_OPTIONS	= 3;
	MENU_EXIT		= 4;

END

//------------------------------------------------------------------------------------------------------------------
PROCESS main_menu()
//
// Menu Principal del juego
//

PRIVATE

	int time;
	
	int button[5];

END

BEGIN

	clear_screen();
	put_screen(fpg, 61);
	
	while( GLOBAL_KEY_OK )
		frame;
	end
	
	// inicia el cursor si todavia no existe
	if ( !game.cursor_id ) 
		game.cursor_id = game_cursor();
	end

	button[MENU_CLASSIC] = main_menu_button(40, 40, 100, "CLASSIC", "MODE");
	button[MENU_SPRINT] = main_menu_button(120, 40, 100, "SPRINT", "MODE");
	button[MENU_SHUFFLE] = main_menu_button(80, 75, 100, "SHUFFLE", "MODE");
	
	//button[MENU_OPTIONS] = main_menu_button(40, 110, 80,  "options", "");
	button[MENU_EXIT] = main_menu_button(130, 110, 60, "EXIT", "");

	LOOP
	
		// si se selecciono un boton
		SWITCH ( menu_button_id )
		
			CASE button[MENU_CLASSIC]:
			
				game( GAMEMODE_CLASSIC );
				break;
			
			END
			
			CASE button[MENU_SHUFFLE]:
			
				game( GAMEMODE_SHUFFLE );
				break;
			
			END
			
			CASE button[MENU_SPRINT]:
			
				game( GAMEMODE_SPRINT );
				break;
			
			END
			
			CASE button[MENU_EXIT]:
			
				// guardo los records y la data
				save("config.dat", data);
			
				// salgo del juego
				exit();
			
			END
			
		END
	
		frame;
		
	END
	
ONEXIT

	menu_button_id = 0;

	screenchange();
	
END


//------------------------------------------------------------------------------------------------------------------
PROCESS main_menu_button(x, y, original_size, string line1, string line2)
//
// Descripcion del Proceso
//

PRIVATE

	int txt1_id;
	int txt2_id;
	
	int normal_alpha = 160;

	int val;

END

BEGIN

	file = fpg;
	graph = 80;
	alpha = 0;
	size = original_size;
	
	IF ( line2 <> "")
		txt1_id = write(fnt_medium,x,y-5,4,line1);
		txt2_id = write(fnt_medium,x,y+5,4,line2);
	else
		txt1_id = write(fnt_medium,x,y,4,line1);
	end	

	LOOP
	
		// hago aparecer los botones
		if (alpha < normal_alpha)
			alpha += 8;
		else
			alpha = normal_alpha;
		end
		
		
		IF ( collision ( type mouse ) )

			// activo el boton al hacerle clic
			IF ( mouse.left )
				menu_button_id = id;
			END
			
			// resalto el boton seleccionado
			IF ( !WIZ )
				size = original_size + 10;
				alpha = 255;
			END
			
		ELSE
		
			// dejo de resaltar boton
			size = original_size;
			alpha = normal_alpha;
			
		END
		
		// elimino el boton al salir del menu
		if ( !exists(father) )
			break;
		end
	
		frame;
		
	END
	
ONEXIT

	// borro los textos al salir
	delete_text(txt1_id);
	if( txt2_id ) delete_text(txt2_id); end
	
END
