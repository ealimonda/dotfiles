"*******************************************************************************************************************
"* Config files                                                                                                    *
"*******************************************************************************************************************
"* File:             .vimrc                                                                                        *
"* Copyright:        (c) 2011-2012 alimonda.com; Emanuele Alimonda                                                 *
"*                   Public Domain                                                                                 *
"*******************************************************************************************************************

" Import ~/.vim/bundle through Pathogen
call pathogen#infect()

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

set modeline
set modelines=5

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
	set nobackup		" do not keep a backup file, use versions instead
else
	set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

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

" Don't write annoying *~ files
set nowritebackup " nowb
set nobackup " nobk

" Various Mac-only settings
"if v:progname == "Vim"
if has("gui_macvim")
	set nowrap  " window word wrap
	"set mousem=popup_setpos " mousemodel
	" A nice font
	set gfn=Monaco:h11
	" Ring the bell on error
	set eb " errorbell
	set sel=inclusive "selection mode
	set go+=b " guicursor
	" Use GUI vimpager
	let vimpager_use_gvim = 1
	" Confirm
	set confirm " cf
endif

" Smart Home function http://vim.wikia.com/wiki/Smart_home
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

" Tab-completion mode
set wildmenu
set wildmode=longest:full,list,full

" prevent swapfiles in the current directory, since dropbox is broken
set directory=~/Library/Caches/org.vim.MacVim//,.,/var/tmp//,/tmp//

nmap <leader>q :bdelete<CR>

" -- TAGBAR --
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
" -- UNDOTREE --
nmap <leader>u :UndotreeToggle<CR>

" -- BUFEXPLORER --
let g:bufExplorerSortBy='fullpath' " Sort by full file path name.
nmap <leader>t :BufExplorer<CR>

" -- CLANG_COMPLETE --
let g:clang_auto_select = 1
let g:clang_close_preview = 1
"let g:clang_use_library = 1
imap <M-Tab> <C-X><C-U>


