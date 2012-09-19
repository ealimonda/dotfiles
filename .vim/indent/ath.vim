" Vim indent file
" Language:	eAthena Script
" Maintainer:	Syaoran <syao@dotalux.com>
" Last Change:	2008 Oct 30

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

" C indenting is built-in, thus this is very simple
setlocal cindent

let b:undo_indent = "setl cin<"
