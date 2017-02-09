import "mod_string";
import "mod_draw";

//------------------------------------------------------------------------------------------------------------------
CONST
	
	// variedad de teclado activada
	WIZKEYBOARD_MIN	= 0;
	WIZKEYBOARD_MAY	= 1;
	WIZKEYBOARD_NUM	= 2;

END

GLOBAL

	// datos globales usados por el teclado
	STRUCT wiz_kb
	
		// tabla de valores de las teclas
		string keyvalue[27];
		
		// valor de la tecla presionada
		int key = -1;
		
		// id de graficos
		int fpg;
		
	END

END

//------------------------------------------------------------------------------------------------------------------
FUNCTION string wizkeyboard(string fpg_src, string message, int max_len)
//
// Inicia el teclado que devolvera un string con el texto ingresado.
//

PRIVATE

	// graficos
	png[3];
	
	// estado del teclado
	keyboard_mode;
	
	string le_string;
	
	int le_string_count;
	
	txt_id;
	txt_message;
	txt_count;

END

BEGIN

	// inicializo los valores
	png[WIZKEYBOARD_MIN] = 11;
	png[WIZKEYBOARD_MAY] = 10;
	png[WIZKEYBOARD_NUM] = 12;

	// cargo los recursos
	wiz_kb.fpg = load_fpg(fpg_src);
	file = wiz_kb.fpg;
	
	// centro en pantalla
	x = 160/2;
	y = 120 - 40;
	
	wizkeyboard_setupkeys(keyboard_mode);
	wizkeyboard_keydetect();
	
	wizkeyboard_frame();
	
	LOOP
		
		// si se presiona una tecla
		IF ( wiz_kb.key >= 0 )
		
			// TECLAS COMUNES
			IF ( wiz_kb.key < 100 )
			
				// agrego la tecla al string
				le_string += wiz_kb.keyvalue[ wiz_kb.key ];
			
			// TECLAS ESPECIALES
			ELSE
			
				SWITCH ( wiz_kb.key )
				
					// MODO SIMBOLOS
					CASE 100:
					
						IF ( keyboard_mode == WIZKEYBOARD_NUM )
							keyboard_mode = WIZKEYBOARD_MIN;
							wizkeyboard_setupkeys(keyboard_mode);
						ELSE
							keyboard_mode = WIZKEYBOARD_NUM;
							wizkeyboard_setupkeys(keyboard_mode);
						END
						
					END
					
					// OK
					CASE 101:
					
						return le_string;
					
					END
					
					// MODO SHIFT
					CASE 102:
					
						IF ( keyboard_mode == WIZKEYBOARD_MAY )
							keyboard_mode = WIZKEYBOARD_MIN;
							wizkeyboard_setupkeys(keyboard_mode);
						ELSE
							keyboard_mode = WIZKEYBOARD_MAY;
							wizkeyboard_setupkeys(keyboard_mode);
						END
						
					END
					
					// SPACE
					CASE 103:
					
						le_string += " ";
						
					END
					
					// DEL
					CASE 104:
					
						// recorto el string
						IF ( len(le_string) )
							le_string = substr( le_string, 0, len(le_string)-1 );
						END
						
					END
					
				END
				
			
			END
			
		END

		// limito el string a la cantidad maxima
		le_string_count = len(le_string);
		WHILE ( le_string_count > max_len )
			le_string = substr( le_string, 0, len(le_string)-1 );
			le_string_count = len(le_string);
		END
		
		// muestro el grafico del teclado que corresponda
		graph = png[keyboard_mode];
		
		//muestro strings
		text_z = -400;
		txt_message = write(fnt_small,80,10,4,message);
		txt_id = write(fnt_large,80,24,4,le_string);
		txt_count = write(fnt_smaller,3,3,0,le_string_count + "/" + max_len );
		text_z = -255;
	
		FRAME;
		
		delete_text(txt_id);
		delete_text(txt_message);
		delete_text(txt_count);
		
	END

END

//------------------------------------------------------------------------------------------------------------------
PROCESS wizkeyboard_keydetect()
//
// Detecta la tecla presionada (mediante durezas) y traduce el valor a un valor de la tabla de teclas
//

PRIVATE

	// coordenadas del mouse sobre el teclado
	int inkeyboard_x;
	int inkeyboard_y;
	
	// durezas
	int color;
	int last_color;

	// contador de frames
	// (para ejecutar solo una vez)
	int aux;

END

BEGIN

	LOOP
	
		// salgo al eliminar al padre
		IF ( !exists(father) )
			break;
		END
	
		// calculo las coordenadas del mouse sobre el teclado
		inkeyboard_x = mouse.x - (father.x - 80);
		inkeyboard_y = mouse.y - (father.y - 40);
	
		// detecto el color de la tecla
		color = map_get_pixel(wiz_kb.fpg, 1, inkeyboard_x, inkeyboard_y );
		
		//si esta sobre alguna tecla
		IF ( color > 0 )
		
			//si es una tecla nueva o solte el boton
			IF ( last_color <> color OR !mouse.left)
				aux = 0;	// se puede volver a ejecutar
			END
		
			// presiono la tecla
			IF ( mouse.left )
			
				aux++;
				IF ( aux == 1 )	// ejecuto solo el 1er frame
				
					//say( "X" + inkeyboard_x + "	Y" + inkeyboard_y + ": 	" + color );
					
					// traduzco el color de la dureza
					// al valor del array de teclas
					SWITCH ( color )
					
						CASE map_get_pixel(wiz_kb.fpg, 1, 010, 10 ):		wiz_kb.key = 00; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 025, 10 ):		wiz_kb.key = 01; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 040, 10 ):		wiz_kb.key = 02; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 055, 10 ):		wiz_kb.key = 03; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 070, 10 ):		wiz_kb.key = 04; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 090, 10 ):		wiz_kb.key = 05; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 106, 10 ):		wiz_kb.key = 06; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 120, 10 ):		wiz_kb.key = 07; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 140, 10 ):		wiz_kb.key = 08; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 150, 10 ):		wiz_kb.key = 09; END
						
						CASE map_get_pixel(wiz_kb.fpg, 1, 010, 30 ):		wiz_kb.key = 10; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 025, 30 ):		wiz_kb.key = 11; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 040, 30 ):		wiz_kb.key = 12; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 055, 30 ):		wiz_kb.key = 13; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 070, 30 ):		wiz_kb.key = 14; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 090, 30 ):		wiz_kb.key = 15; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 106, 30 ):		wiz_kb.key = 16; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 120, 30 ):		wiz_kb.key = 17; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 140, 30 ):		wiz_kb.key = 18; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 150, 30 ):		wiz_kb.key = 19; END
						
						CASE map_get_pixel(wiz_kb.fpg, 1, 010, 50 ):		wiz_kb.key = 20; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 025, 50 ):		wiz_kb.key = 21; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 040, 50 ):		wiz_kb.key = 22; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 055, 50 ):		wiz_kb.key = 23; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 070, 50 ):		wiz_kb.key = 24; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 090, 50 ):		wiz_kb.key = 25; END
						CASE map_get_pixel(wiz_kb.fpg, 1, 106, 50 ):		wiz_kb.key = 26; END
						
						//teclas especiales
						CASE map_get_pixel(wiz_kb.fpg, 1, 120, 50 ): 	wiz_kb.key = 100; END	// simbolos
						CASE map_get_pixel(wiz_kb.fpg, 1, 140, 50 ): 	wiz_kb.key = 101; END	// enter
						CASE map_get_pixel(wiz_kb.fpg, 1, 010, 70 ): 	wiz_kb.key = 102; END	// shift
						CASE map_get_pixel(wiz_kb.fpg, 1, 040, 70 ): 	wiz_kb.key = 103; END	// space
						CASE map_get_pixel(wiz_kb.fpg, 1, 100, 70 ): 	wiz_kb.key = 104; END	// del
						
						DEFAULT: wiz_kb.key = -1; END
						
					END
					
				END
			END
			
			//if (wiz_kb.key >= 0) say("wizkey:" + wiz_kb.key ); end
			
		END
	
		frame;
		
		wiz_kb.key = -1;
		last_color = color;
		
	END

END

//------------------------------------------------------------------------------------------------------------------
FUNCTION wizkeyboard_setupkeys(int keyboard_mode)
//
// Descripcion de la funcion
//

BEGIN

	// inicializo las teclas
	SWITCH ( keyboard_mode )
	
		// minusculas
		CASE WIZKEYBOARD_MIN:
		
			wiz_kb.keyvalue[00] = "q";
			wiz_kb.keyvalue[01] = "w";
			wiz_kb.keyvalue[02] = "e";
			wiz_kb.keyvalue[03] = "r";
			wiz_kb.keyvalue[04] = "t";
			wiz_kb.keyvalue[05] = "y";
			wiz_kb.keyvalue[06] = "u";
			wiz_kb.keyvalue[07] = "i";
			wiz_kb.keyvalue[08] = "o";
			wiz_kb.keyvalue[09] = "p";
			
			wiz_kb.keyvalue[10] = "a";
			wiz_kb.keyvalue[11] = "s";
			wiz_kb.keyvalue[12] = "d";
			wiz_kb.keyvalue[13] = "f";
			wiz_kb.keyvalue[14] = "g";
			wiz_kb.keyvalue[15] = "h";
			wiz_kb.keyvalue[16] = "j";
			wiz_kb.keyvalue[17] = "k";
			wiz_kb.keyvalue[18] = "l";
			wiz_kb.keyvalue[19] = ".";
			
			wiz_kb.keyvalue[20] = "z";
			wiz_kb.keyvalue[21] = "x";
			wiz_kb.keyvalue[22] = "c";
			wiz_kb.keyvalue[23] = "v";
			wiz_kb.keyvalue[24] = "b";
			wiz_kb.keyvalue[25] = "n";
			wiz_kb.keyvalue[26] = "m";
			
		END
		// mayusculas
		CASE WIZKEYBOARD_MAY:
		
			wiz_kb.keyvalue[00] = "Q";
			wiz_kb.keyvalue[01] = "W";
			wiz_kb.keyvalue[02] = "E";
			wiz_kb.keyvalue[03] = "R";
			wiz_kb.keyvalue[04] = "T";
			wiz_kb.keyvalue[05] = "Y";
			wiz_kb.keyvalue[06] = "U";
			wiz_kb.keyvalue[07] = "I";
			wiz_kb.keyvalue[08] = "O";
			wiz_kb.keyvalue[09] = "P";
			
			wiz_kb.keyvalue[10] = "A";
			wiz_kb.keyvalue[11] = "S";
			wiz_kb.keyvalue[12] = "D";
			wiz_kb.keyvalue[13] = "F";
			wiz_kb.keyvalue[14] = "G";
			wiz_kb.keyvalue[15] = "H";
			wiz_kb.keyvalue[16] = "J";
			wiz_kb.keyvalue[17] = "K";
			wiz_kb.keyvalue[18] = "L";
			wiz_kb.keyvalue[19] = "!";
			
			wiz_kb.keyvalue[20] = "Z";
			wiz_kb.keyvalue[21] = "X";
			wiz_kb.keyvalue[22] = "C";
			wiz_kb.keyvalue[23] = "V";
			wiz_kb.keyvalue[24] = "B";
			wiz_kb.keyvalue[25] = "N";
			wiz_kb.keyvalue[26] = "M";
		
		END
		
		CASE WIZKEYBOARD_NUM:
		
			wiz_kb.keyvalue[00] = "1";
			wiz_kb.keyvalue[01] = "2";
			wiz_kb.keyvalue[02] = "3";
			wiz_kb.keyvalue[03] = "4";
			wiz_kb.keyvalue[04] = "5";
			wiz_kb.keyvalue[05] = "6";
			wiz_kb.keyvalue[06] = "7";
			wiz_kb.keyvalue[07] = "8";
			wiz_kb.keyvalue[08] = "9";
			wiz_kb.keyvalue[09] = "0";
			
			wiz_kb.keyvalue[10] = "!";
			wiz_kb.keyvalue[11] = "_";
			wiz_kb.keyvalue[12] = ",";
			wiz_kb.keyvalue[13] = "-";
			wiz_kb.keyvalue[14] = "@";
			wiz_kb.keyvalue[15] = "&";
			wiz_kb.keyvalue[16] = "/";
			wiz_kb.keyvalue[17] = "(";
			wiz_kb.keyvalue[18] = ")";
			wiz_kb.keyvalue[19] = "|";
			
			wiz_kb.keyvalue[20] = "?";
			wiz_kb.keyvalue[21] = "º";
			wiz_kb.keyvalue[22] = ";";
			wiz_kb.keyvalue[23] = ":";
			wiz_kb.keyvalue[24] = "'";
			wiz_kb.keyvalue[25] = "<";
			wiz_kb.keyvalue[26] = ">";
		
		END
		
	END
	
END

//------------------------------------------------------------------------------------------------------------------
PROCESS wizkeyboard_frame()
//
// Descripcion del Proceso
//

PRIVATE

END

BEGIN

	file = father.file;
	graph = 2;
	x = 80;
	y = 20;
	z = -300;

	LOOP
	
		if ( ! exists(father) )
			
			break;
		
		end
	
		frame;
		
	END

END

