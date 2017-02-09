
:: creo el exe
cd ..
bgdc.exe -a "%prgname%.prg" -s bgdi.exe -o "%gamename%.exe"
cd releases\
MOVE "..\%gamename%.exe" "%url%\%gamename%.exe"

:: copio los binarios de windows
::copio todas las dll y las escondo
copy %bennupath%\windows\*.dll %url%\
attrib +h %url%\*.dll

:: copio archivos extra
CALL files.bat copy_extra_files

:: comprimo 
CALL files.bat zip_file
