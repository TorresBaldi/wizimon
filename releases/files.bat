IF "%1" == "copy_files" GOTO copy_files
IF "%1" == "copy_extra_files" GOTO copy_extra_files
IF "%1" == "copy_source" GOTO copy_source
IF "%1" == "zip_file" GOTO zip_file
GOTO end


::
:: COPIO ARCHIVOS DEL JUEGO
::
:copy_files

::archivos y carpetas de recursos
xcopy "..\audio" /E /D /I "%url%\audio"
xcopy "..\data" /E /D /I "%url%\data"
copy ..\%prgname%.dcb %url%\

GOTO end


::
:: COPIO ARCHIVOS DE DISTRUBUCION
::
:copy_extra_files

::archivos extra (tambien incluidos en release exe)
copy ..\leeme.txt %url%\

GOTO end


::
:: COPIO ARCHIVOS FUENTE
::
:copy_source

::archivos y carpetas de recursos
xcopy "..\audio" /E /D /I "%url%\audio"
xcopy "..\data" /E /D /I "%url%\data"
xcopy "..\fpg" /E /D /I "%url%\fpg"

:: codigo fuente
xcopy "..\prg" /E /D /I "%url%\prg"
copy ..\main.prg %url%\

GOTO end


::
:: COMPRIMO ARCHIVOS
::
:zip_file

::comprimo archivo
winRAR a -cl -m5 -r %ver%\%gamename%-%ver%-%platform%.zip %root%\*

:: borro carpeta 
rd /Q /s %root%

GOTO end


:end
