#!/bin/sh

# genero los paths
CURDIR=$(dirname 0)
BENNUBIN=$CURDIR/bin
BENNULIB=$CURDIR/lib

# copia de seguridad de paths
PATH_BACKUP=$PATH
LD_LIBRARY_PATH_BACKUP=$LD_LIBRARY_PATH

# cambio los paths
export PATH=$BENNUBIN:$PATH
export LD_LIBRARY_PATH=$BENNULIB:$LD_LIBRARY_PATH

#ejecuto el juego
bgdi main.dcb

# restauro paths anteriores
#PATH=$PATH_BACKUP
#LD_LIBRARY_PATH=$LD_LIBRARY_PATH_BACKUP


