@echo off
Title BUILDBOT

::
:::::: CONFIGURACIONES
::

set gamename=wizimon
set prgname=main
set bennupath=D:\bennu\bin

::
:::::: VERSIONES A CREAR
::

set windows=1
set wiz=1
set caanoo=1
set source=1
set linux=0

::
:::::: PREGUNTO VERSION
::
echo Version:
set /p ver=
mkdir %ver%

:: agrego winrar y bennu windows al path
set path=%path%;"C:\Archivos de programa\WinRAR";%bennupath%\windows\




:bot_begin

:: WINDOWS
IF %windows% == 0 GOTO skip_windows

	SET windows=0

	SET platform=windows
	SET ROOT=%gamename%-%platform%
	SET URL=%root%

	MKDIR %url%
	
	CALL build-windows.bat
	
:skip_windows


:: SOURCE CODE
IF %source% == 0 GOTO skip_source

	SET source=0

	SET platform=source
	SET ROOT=%gamename%-%platform%
	SET URL=%root%

	MKDIR %url%
	
	CALL build-source.bat
	
:skip_source


:: WIZ
IF %wiz% == 0 GOTO skip_wiz

	SET wiz=0

	SET platform=wiz
	SET ROOT=%gamename%-%platform%
	SET URL=%root%\%gamename%

	MKDIR %url%
	
	CALL build-wiz.bat
	
:skip_wiz


:: CAANOO
IF %caanoo% == 0 GOTO skip_wiz

	SET caanoo=0

	SET platform=caanoo
	SET ROOT=%gamename%-%platform%
	SET URL=%root%\%gamename%

	MKDIR %url%
	
	CALL build-caanoo.bat
	
:skip_caanoo



:: si ya no quedan plataformas, termino
GOTO bot_end



:bot_end
