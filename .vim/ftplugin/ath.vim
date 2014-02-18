" Vim indent file
" Language:    Hercules/*Athena Script
" Maintainer:  Haru <haru@dotalux.com>
" Last Change: 2013-12-18


" Only load this indent file when no other was loaded.
if exists("b:did_indent")
   finish
endif

" Behaves just like Hercules
runtime! ftplugin/herc.vim ftplugin/herc_*.vim ftplugin/herc/*.vim

