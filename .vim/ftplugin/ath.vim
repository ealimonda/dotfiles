" Vim filetype plugin file
" Language:    Hercules/*Athena Script
" Maintainer:  Haru <haru@dotalux.com>
" Last Change: 2014-06-28


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Behaves just like Hercules
runtime! ftplugin/herc.vim ftplugin/herc_*.vim ftplugin/herc/*.vim

