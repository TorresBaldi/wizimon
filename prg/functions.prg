//------------------------------------------------------------------------------------------------------------------
FUNCTION int check_savedata()
//
// comprueba si existe data guardada
//

PRIVATE

	string filename = "config.dat";

END

BEGIN

	// si existe archivo de datos
	if ( file_exists ( filename ) )
	
		// cargo datos a la struct global DATA
		load(filename, data);
	
		return true;
		
	else
	
		// guardo la struct global DATA
		save(filename, data);
	
		return false;
		
	end
	
END


//------------------------------------------------------------------------------------------------------------------
PROCESS screenchange()
//
// efecto para pasar de una pantalla a la otra
//

PRIVATE

	int i;
	
	original_screen;
	
	delta_angle;

END

BEGIN

	original_screen = screen_get();
	
	graph = original_screen;
	x = 160/2;
	y = 120/2;
	z = -999;
	
	delta_angle = 10 * rand(-200,200);

	LOOP
	
		alpha -= 12;
		size 	+= 50;
		angle 	-= delta_angle;
		
		IF ( alpha < 0 )
			
			BREAK;
			
		END
		
	
		frame;
		
	END

END

//------------------------------------------------------------------------------------------------------------------
FUNCTION int dialog(string message, string label_yes, string label_no)
//
// Muestra una ventana
//

PRIVATE

	int txt_id[3];

	int real_x;
	int real_y;
	
	int color;	
	int color_yes; // 30 45
	int color_no;  // 90 45
	
	int exit_flag;
	int return_value;
	
END

BEGIN

	while (GLOBAL_KEY_OK OR GLOBAL_KEY_CANCEL)
		frame;
	END
	
	graph = 90;
	x = 80;
	y = 60;
	z = -20;
	size = 10;
	alpha = 0;
	
	color_no = map_get_pixel( fpg, graph+1, 30, 45 );
	color_yes  = map_get_pixel( fpg, graph+1, 90, 45 );
	
	while ( size < 100 )
		size += 100/10;
		alpha += 255/10;
		frame;
	end
	
	txt_id[0] = write(fnt_large, 80, 50, 4, message);
	txt_id[1] = write(fnt_small, 50, 77, 4, label_yes);
	txt_id[2] = write(fnt_small, 110, 77, 4, label_no);
	
	// ejecuto mientras no se haya salido
	while ( size > 0 )
	
		// comienzo a achicar hasta salir
		IF (exit_flag)
				
			//al salir
			IF ( exit_flag == 1 )
				delete_text(txt_id[0]);
				delete_text(txt_id[1]);
				delete_text(txt_id[2]);
			END
		
			exit_flag++;
			
			size -= 100/20;
			alpha -= 255/20;
			
		ELSE
		
			// compruebo los botones
			IF ( !mouse.left AND GLOBAL_KEY_OK )
				exit_flag = true;
				return_value = true;
				continue;
			ELSEIF ( !mouse.left AND GLOBAL_KEY_CANCEL )
				exit_flag = true;
				return_value = false;
				continue;
			END
		
			// compruebo si el mouse esta presionado
			if ( collision ( type mouse ) AND mouse.left )
			
				// calculo las coordenadas del mouse sobre el dialog
				real_x = mouse.x - (x - 60);
				real_y = mouse.y - (y - 30);
				
				// compuebo si se presiono un boton
				color = map_get_pixel ( fpg, graph+1, real_x, real_y );
				IF ( color == color_yes )
					exit_flag = true;
					return_value = true;
				ELSEIF( color == color_no )
					exit_flag = true;
					return_value = false;
				END
			
			end
			
		END
		
		frame;
		
	end
	
	return return_value;

END

//------------------------------------------------------------------------------------------------------------------
FUNCTION alert(string message1, string message2, int x, int y)
//
// Muestra un aviso en pantalla
// Usado para records, y game over.
//


PRIVATE

	int txt1;
	int txt2;
	
	int exit_flag;
	
END

BEGIN

	while (GLOBAL_KEY_OK OR GLOBAL_KEY_CANCEL)
		frame;
	END
	
	graph = 92;
	//x = 80;
	//y = 60;
	z = -20;
	size = 10;
	alpha = 0;
	
	while ( size < 100 )
		size += 100/10;
		alpha += 255/10;
		frame;
	end
	
	txt1 = write(fnt_large, x, y-12, 4, message1);
	txt2 = write(fnt_large, x, y+12, 4, message2);
	
	// ejecuto mientras no se haya salido
	while ( size > 0 )
	
		// comienzo a achicar hasta salir
		IF (exit_flag)
			
			size -= 100/10;
			alpha -= 255/10;
			
		ELSE
		
			// compruebo los botones
			IF ( GLOBAL_KEY_OK OR GLOBAL_KEY_CANCEL )
			
				delete_text(txt1);
				delete_text(txt2);
				
				exit_flag = true;
			END
			
		END
		
		frame;
		
	end
	
END

//------------------------------------------------------------------------------------------------------------------
PROCESS volume_control()
//
// Se encarga de controlar el volumen
//

PRIVATE

	int delay;
	int delay_counter = 200;
	
	string volume_meter;
	int txt_id;

END

BEGIN

	set_wav_volume(beep, data.volume);

	LOOP
	
		delay_counter++;
		volume_change = false;
	
		IF ( jkeys_state[ _JKEY_VOLDOWN ] AND delay_counter > delay )
		
			delay_counter = 0;
			volume_change = true;
			
			IF ( delay > 1 )
				delay--;
			END
		
			IF ( data.volume > 0 )
				data.volume -= 8;
			END
			
			set_wav_volume(beep, data.volume);
		
		ELSEIF ( jkeys_state[ _JKEY_VOLUP ] AND delay_counter > delay )
		
			delay_counter = 0;
			volume_change = true;
			
			IF ( delay > 1 )
				delay--;
			END
		
			IF ( data.volume < 128 )
				data.volume += 8;
			END
			
			set_wav_volume(beep, data.volume);
		
		END
		
		IF ( !jkeys_state[ _JKEY_VOLDOWN ] AND !jkeys_state[ _JKEY_VOLUP ] )
			delay = 6;
		END
		
		// muestro volumen en pantalla
		IF ( delay_counter < 100 )
		
			volume_meter = "[";
			FOR (x=0;x<16;x++)
				IF ( x >= (data.volume/8) )
					volume_meter += ".";
				ELSE
					volume_meter += "|";
				END
			END
			volume_meter += "]";
			
			txt_id = write(fnt_small, 80, 0, 1, volume_meter);
		END
	
		frame;
		
		IF ( txt_id )
			delete_text ( txt_id );
			txt_id = 0;
		END
		
	END

END

