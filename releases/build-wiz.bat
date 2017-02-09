
:: copio binarios de bennu ( si no estoy contruyendo fuente )
xcopy %bennupath%\%platform% /E /D /I %root%\bgd-runtime

::copio archivos especificos de wiz
copy release-files\icon.png %url%\icon.png
copy release-files\script.gpe %url%\%gamename%.gpe

copy release-files\wiz.ini %root%\%gamename%.ini

::copio archivos del juego
CALL files.bat copy_files
CALL files.bat copy_extra_files

:: comprimo 
CALL files.bat zip_file
