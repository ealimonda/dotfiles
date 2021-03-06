"*******************************************************************************************************************
"* Config files                                                                                                    *
"*******************************************************************************************************************
"* File:             .vimrc                                                                                        *
"* Copyright:        (c) 2011-2012 alimonda.com; Emanuele Alimonda                                                 *
"*                   Public Domain                                                                                 *
"*******************************************************************************************************************

" Note: This file uses folding. If you don't know how to unfold, press zR or check :help folding.

" Pathogen
" {{{
" Import ~/.vim/bundle through Pathogen
execute pathogen#infect()
" }}}

" Base settings
" {{{

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Allow modelines
set modeline
set modelines=5

" Allow backspacing over everything in insert mode
set backspace=indent,eol,start

"if has("vms")
"	set nobackup		" do not keep a backup file, use versions instead
"else
"	set backup		" keep a backup file
"endif
" Don't write annoying *~ files
set nowritebackup " nowb
set nobackup " nobk

set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
	set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
if &t_Co > 2 || has("gui_running")
	syntax on
endif
" Set nice colors
if &t_Co >= 256 || has("gui_running")
	colorscheme skittles_berry
elseif &t_Co >= 88
	colorscheme torte
endif

" I like highlighting strings inside C comments
let c_comment_strings=1

" Line numbers
set number " nu

" Disable search highlight
set nohlsearch " nohls

" Folding for c files
set foldmethod=syntax
set foldnestmax=10
set nofoldenable

" Tab-completion mode
set wildmenu
set wildmode=longest:full,list,full

" prevent swapfiles in the current directory, since dropbox is broken
if has("mac")
	set directory=~/Library/Caches/org.vim.MacVim//,/var/tmp//,/tmp//,.
else
	set directory=/var/tmp//,/tmp//,.
endif

" highlight whitespace in a meaningful way
set listchars=eol:¶,tab:\|_,trail:·,extends:>,precedes:<,nbsp:•

" Set max number of tabs to 50
set tabpagemax=50

" Show cursor line/column
set cursorline
set nocursorcolumn

" }}}

" Various Mac-only settings (note: some of them would work on other platforms too)
" {{{
"if v:progname == "Vim"
if has("gui_macvim")
	" A nice font
	set gfn=Monaco:h11 " guifont
elseif has("gui_win32")
	" Windows compatbility
	set gfn=Consolas:h10:b " guifont
	"set guifontwide=Yu\ Gothic:h10 "For windows to display mixed character sets
	set encoding=utf-8
endif

if has("gui_running")
	set nowrap  " window word wrap
	"set mousem=popup_setpos " mousemodel
	" Ring the bell on error
	set eb " errorbell
	set sel=inclusive "selection mode
	set go+=b " guicursor
	set go-=T " Remove toolbar
	set go+=h " horizontal scrollbar sized on the current line only (snappier)
	set stal=2 " Force tab bar display
	" Use GUI vimpager
	let vimpager_use_gvim = 1
	" Confirm
	set confirm " cf
endif

" }}}

" Autocommands
" {{{
" Only do this part when compiled with support for autocommands.
if has("autocmd")
	" Enable file type detection.
	" Use the default filetype settings, so that mail gets 'tw' set to 72,
	" 'cindent' is on in C files, etc.
	" Also load indent files, to automatically do language-dependent indenting.
	filetype plugin indent on

	" Put these in an autocmd group, so that we can delete them easily.
	augroup vimrcEx
		au!

		" For all text files set 'textwidth' to 78 characters.
		autocmd FileType text setlocal textwidth=78

		" When editing a file, always jump to the last known cursor position.
		" Don't do it when the position is invalid or when inside an event handler
		" (happens when dropping a file on gvim).
		autocmd BufReadPost *
			\ if line("'\"") > 0 && line("'\"") <= line("$") |
			\   exe "normal g`\"" |
			\ endif
	augroup END
else
	set autoindent		" always set autoindenting on
endif " has("autocmd")
" }}}

" Mappings
" {{{
" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

nmap <leader>q :bdelete<CR>

" }}}

" Smart Home function http://vim.wikia.com/wiki/Smart_home
" {{{
function! SmartHome()
	let s:col = col(".")
	normal! ^
	if s:col == col(".")
		normal! 0
	endif
endfunction
nnoremap <silent> <Home> :call SmartHome()<CR>
inoremap <silent> <Home> <C-O>:call SmartHome()<CR>
" Smart Home Function end
" }}}

" Hex editor
" {{{
" ex command for toggling hex mode - define mapping if desired
command! -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function! ToggleHex()
	" hex mode should be considered a read-only operation
	" save values for modified and read-only for restoration later,
	" and clear the read-only flag for now
	let l:modified=&mod
	let l:oldreadonly=&readonly
	let &readonly=0
	let l:oldmodifiable=&modifiable
	let &modifiable=1
	if !exists("b:editHex") || !b:editHex
		" save old options
		let b:oldft=&ft
		let b:oldbin=&bin
		" set new options
		setlocal binary " make sure it overrides any textwidth, etc.
		let &ft="xxd"
		" set status
		let b:editHex=1
		" switch to hex editor
		%!xxd -g 1
	else
		" restore old options
		let &ft=b:oldft
		if !b:oldbin
			setlocal nobinary
		endif
		" set status
		let b:editHex=0
		" return to normal editing
		%!xxd -r
	endif
	" restore values for modified and read only state
	let &mod=l:modified
	let &readonly=l:oldreadonly
	let &modifiable=l:oldmodifiable
endfunction

nmap <leader>h :Hexmode<CR>
" }}}

" Macro expansion for C/C++
" http://vim.wikia.com/wiki/Macro_expansion_C/C%2B%2B
" {{{
function! ExpandCMacro()
	"get current info
	let l:macro_file_name = "__macroexpand__" . tabpagenr()
	let l:file_row = line(".")
	let l:file_name = expand("%")
	let l:file_window = winnr()
	"create mark
	execute "normal! Oint " . l:macro_file_name . ";"
	execute "w"
	"open tiny window ... check if we have already an open buffer for macro
	if bufwinnr( l:macro_file_name ) != -1
		execute bufwinnr( l:macro_file_name) . "wincmd w"
		setlocal modifiable
		execute "normal! ggdG"
	else
		execute "bot 10split " . l:macro_file_name
		execute "setlocal filetype=cpp"
		execute "setlocal buftype=nofile"
		nnoremap <buffer> q :q!<CR>
	endif
	"read file with gcc
	silent! execute "r!gcc -E " . l:file_name
	"keep specific macro line
	execute "normal! ggV/int " . l:macro_file_name . ";$\<CR>d"
	execute "normal! jdG"
	"indent
	"for GNU indent only:
	"execute "%!indent -st -kr"
	execute "%!indent -st"
	execute "normal! gg=G"
	"resize window
	execute "normal! G"
	let l:macro_end_row = line(".")
	execute "resize " . l:macro_end_row
	execute "normal! gg"
	"no modifiable
	setlocal nomodifiable
	"return to origin place
	execute l:file_window . "wincmd w"
	execute l:file_row
	execute "normal!u"
	execute "w"
	"highlight origin line
	let @/ = getline('.')
endfunction
autocmd FileType cpp nnoremap <leader>m :call ExpandCMacro()<CR>
autocmd FileType c nnoremap <leader>m :call ExpandCMacro()<CR>
" }}}

" -- TAGBAR --
" {{{
" map C-L to toggle the tagbar list
nmap <leader>l :TagbarToggle<CR>
"let g:tagbar_type_css = {
"\ 'ctagstype' : 'Css',
"	\ 'kinds' : [
"		\ 'c:classes',
"		\ 's:selectors',
"		\ 'i:identities'
"	\ ]
"\ }
let g:tagbar_type_markdown = {
	\ 'ctagstype' : 'markdown',
	\ 'kinds' : [
		\ 'h:Heading_L1',
		\ 'i:Heading_L2',
		\ 'k:Heading_L3'
	\ ]
\ }
" }}}

" -- UNDOTREE --
" {{{
nmap <leader>u :UndotreeToggle<CR>
" }}}

" -- BUFEXPLORER --
" {{{
let g:bufExplorerSortBy='fullpath' " Sort by full file path name.
nmap <leader>t :BufExplorer<CR>
" }}}

" -- CLANG_COMPLETE --
" {{{
"let g:clang_auto_select = 1
"let g:clang_snippets = 1
"let g:clang_trailing_placeholder = 1
"let g:clang_close_preview = 1
"let g:clang_complete_macros = 1
"let g:clang_use_library = 1
"if has("mac")
	"let g:clang_library_path = '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib'
"endif
"imap <M-Tab> <C-X><C-U>
" }}}

" -- SYNTASTIC --
" {{{
let g:syntastic_auto_loc_list = 1

let g:syntastic_c_config_file = '.clang_complete'
let g:syntastic_c_compiler = 'clang'
let g:syntastic_c_check_header = 1
let g:syntastic_c_auto_refresh_includes = 1
let g:syntastic_cpp_config_file = '.clang_complete'
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_check_header = 1
let g:syntastic_cpp_auto_refresh_includes = 1
let g:syntastic_java_javac_config_file_enabled = 1
let g:syntastic_perl_checkers = ['perl', 'perlcritic']
let g:syntastic_enable_perl_checker = 1
let g:syntastic_html_tidy_ignore_errors = [
	\"trimming empty <i>",
	\"trimming empty <span>",
	\"<iframe> proprietary attribute \"allowfullscreen\"",
	\"<textarea> proprietary attribute \"placeholder\"",
\]

if has("mac")
	let g:syntastic_ath_compiler = '/usr/local/OriginsRO-ath/script-checker'
	let g:syntastic_ath_compiler_options = '--no-color'
	let g:syntastic_herc_compiler = '/usr/local/Hercules/script-checker'
endif
" }}}

" hex2dec/dec2hex
" {{{
command! -nargs=? -range Dec2hex call s:Dec2hex(<line1>, <line2>, '<args>')
function! s:Dec2hex(line1, line2, arg) range
	if empty(a:arg)
		if histget(':', -1) =~# "^'<,'>" && visualmode() !=# 'V'
			let cmd = 's/\%V\<\d\+\>/\=printf("0x%x",submatch(0)+0)/g'
		else
			let cmd = 's/\<\d\+\>/\=printf("0x%x",submatch(0)+0)/g'
		endif
		try
			execute a:line1 . ',' . a:line2 . cmd
		catch
			echo 'Error: No decimal number found'
		endtry
	else
		echo printf('%x', a:arg + 0)
	endif
endfunction

command! -nargs=? -range Hex2dec call s:Hex2dec(<line1>, <line2>, '<args>')
function! s:Hex2dec(line1, line2, arg) range
	if empty(a:arg)
		if histget(':', -1) =~# "^'<,'>" && visualmode() !=# 'V'
			let cmd = 's/\%V0x\x\+/\=submatch(0)+0/g'
		else
			let cmd = 's/0x\x\+/\=submatch(0)+0/g'
		endif
		try
			execute a:line1 . ',' . a:line2 . cmd
		catch
			echo 'Error: No hex number starting "0x" found'
		endtry
	else
		echo (a:arg =~? '^0x') ? a:arg + 0 : ('0x'.a:arg) + 0
	endif
endfunction
" }}}

" Mojolicious
" {{{
let mojo_highlight_data = 1
" }}}

" vim-airline
" {{{
set laststatus=2
set noshowmode
let g:airline_mode_map = {
	\ '__' : '----',
	\ 'n'  : 'NORM',
	\ 'i'  : 'INS ',
	\ 'R'  : 'REPL',
	\ 'c'  : 'CMD ',
	\ 'v'  : 'VIS ',
	\ 'V'  : 'V-LN',
	\ '' : 'V-BL',
	\ 's'  : 'SEL ',
	\ 'S'  : 'S-LN',
	\ '' : 'S-BL',
\ }
if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif
" unicode symbols
if has("win32")
	let g:airline_left_sep = '»'
	let g:airline_right_sep = '«'
	let g:airline_symbols.paste = 'ρ'
	let g:airline_symbols.branch = 'µ'
else
	"let g:airline_left_sep = '»'
	"let g:airline_left_sep = '▶'
	"let g:airline_left_sep = '⡷'
	let g:airline_left_sep = '》'
	"let g:airline_right_sep = '«'
	"let g:airline_right_sep = '◀'
	"let g:airline_right_sep = '⢾'
	let g:airline_right_sep = '《'
	let g:airline_symbols.branch = '⎇'
	"let g:airline_symbols.paste = 'ρ'
	"let g:airline_symbols.paste = 'Þ'
	let g:airline_symbols.paste = '∥'
endif
"let g:airline_symbols.linenr = '␊'
"let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_theme='wombat'
let g:airline#extensions#whitespace#mixed_indent_algo = 2
let g:airline#extensions#whitespace#trailing_format = 'trail[%s]'
let g:airline#extensions#whitespace#mixed_indent_format = 'mix-ind[%s]'
let g:airline#extensions#whitespace#mixed_indent_file_format = 'mix-ind-file[%s]'
" let g:airline#extensions#ycm#enabled = 1 (currently using syntastic)
let g:airline#extensions#c_like_langs = [ 'c', 'cpp', 'cuda', 'javascript', 'ld', 'php', 'c.doxygen', 'cpp.doxygen', 'ath', 'herc' ]
" }}}

" Gitv
" {{{
let g:Gitv_OpenPreviewOnLaunch = 1

set lazyredraw
" }}}

" vim-signify
" {{{
let g:signify_vcs_list = [ 'git' ]
" }}}

" scratch
" {{{
nmap <leader>s :Scratch<CR>
" }}}

" UltiSnips
" {{{
" " Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
"let g:UltiSnipsExpandTrigger="<S-Enter>"
let g:UltiSnipsExpandTrigger="<F4>"
"let g:UltiSnipsJumpForwardTrigger="<tab>"
"let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
"let g:UltiSnipsExpandTrigger="<None>"
let g:UltiSnipsJumpForwardTrigger="<None>"
let g:UltiSnipsJumpBackwardTrigger="<None>"
" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"
" }}}

" YouCompleteMe
" {{{
let g:ycm_key_invoke_completion="<C-Tab>"
let g:ycm_always_populate_location_list=1
nnoremap <C-F5> :YcmForceCompileAndDiagnostics<CR>
nnoremap <C-S> :YcmDiag<CR>
map <leader>? :YcmCompleter GetDoc<CR>
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_auto_start_csharp_server = 0
let g:ycm_key_detailed_diagnostics = '<F5>'
let g:ycm_confirm_extra_conf = 0
" Use syntastic instead
let g:ycm_show_diagnostics_ui = 0
let g:ycm_register_as_syntastic_checker = 0
" UltiSnips compatibility (through supertab)
let g:ycm_key_list_select_completion = ['<C-N>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-P>', '<Up>']
" }}}

" Supertab
" {{{
" For YouCompleteMe+UltiSnips
let g:SuperTabDefaultCompletionType = '<C-N>'
let g:SuperTabMappingForward = '<M-Tab>'
" }}}

" netrw :Explore
" {{{
noremap <leader>n :Lexplore<CR>
let g:netrw_liststyle = 3 " Tree style
" }}}

" EasyAlign
" {{{
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" }}}

" QuickHL
" {{{
" Toggle QuickHL current word
nmap <leader>w :QuickhlCwordToggle<CR>
" }}}

" Incsearch
" {{{
map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
" }}}

"nnoremap <silent> <leader>DD :exe ":profile start profile.log"<cr>:exe ":profile func *"<cr>:exe ":profile file *"<cr>
"nnoremap <silent> <leader>DQ :exe ":profile pause"<cr>:noautocmd qall!<cr>

" vim: set ft=vim foldmethod=marker foldenable :
