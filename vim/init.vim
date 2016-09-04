scriptencoding utf-8
set encoding=utf-8

setlocal lcs=tab:»·,trail:·,eol:$
"set termguicolors
set list
set bs=2
set t_Co=256
set nocp

set softtabstop=2
set tabstop=2
set noexpandtab
set shiftwidth=2
set autoindent
set hidden	    "buffers keep change history
set scrolloff=3	    "keep 3 lines below and above cursor
set splitbelow  "new splits will be focused on bottom
set splitright  "new vsplits will be focused on right

if &term =~ 'screen'
    " Disable Background Color Erase (BCE) so that color schemes
    " work properly when Vim is used inside tmux and GNU screen.
    " http://snk.tuxfamily.org/log/vim-256color-bce.html
    set t_ut=
endif

" ignores
set wildignore+=virtualenv/**,node_modules/**,static/js/lib/**

" filetype plugins
filetype on
filetype plugin on
filetype plugin indent on

" Display
set number
syntax on
set background=dark
colorscheme BusyBee
hi clear SpellBad
hi SpellBad cterm=underline,bold ctermfg=magenta
set foldmethod=indent
set foldlevel=100
set nowrap
set hlsearch
set cursorline
highlight Pmenu ctermbg=235 cterm=NONE
highlight PmenuSel ctermbg=130 ctermfg=232 cterm=bold

"""" nvim
if has('nvim')
	nmap <BS> <C-w>h
endif
let g:python2_host_prog='/usr/bin/python2'
"let g:python3_host_prog='/usr/bin/python'
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
"let g:loaded_python_provider = 1
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
" zsh
nnoremap <silent> <F3> :terminal zsh<CR>
" ranger
nnoremap <silent> <F4> :terminal ranger<CR>

" Autocomplete features in the status bar
set wildmenu

"""" statusline
"set statusline=%t[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%m%r%y%=%c,%l/%L\ %P\ %{fugitive#statusline()}
set laststatus=2

"""" Paste mode toggle
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

"""" Djagno snippets
"autocmd FileType python set ft=python.django
autocmd FileType html set ft=htmldjango.html

"""" PySmell
"autocmd FileType python setlocal omnifunc=pysmell#Complete

"""" MiniBufExplorer
"let g:miniBufExplMapWindowNavVim = 1
"let g:miniBufExplMapWindowNavArrows = 1
"let g:miniBufExplMapCTabSwitchBufs = 1
"let g:miniBufExplModSelTarget = 1 

"""" SuperTab
let g:SuperTabDefaultCompletionType = 'context'
"let g:SuperTabDefaultCompletionType = "<C-x><C-o>"

"""" completion menu tweaks
set completeopt=longest,menuone

"""" Tagbar
map <leader>t :TagbarToggle<CR>

"""" fzf
map <leader>c :FZF<CR>

"""" TaskList
"map T :TaskList<CR>

"""" NERDTree
let NERDTreeQuitOnOpen = 1
let NERDTreeWinSize = 50
let NERDTreeIgnore=['\.pyc$', '\.vim$', '\~$']
map <leader>N :NERDTreeToggle<CR>
"map ob :NERDTreeFromBookmark 

"""" Rope
map <leader>j :RopeGotoDefinition<CR>
map <leader>r :RopeRename<CR>

"""" Pymode
let g:pymode_options_max_line_length = 95
"let g:pymode_virtualenv = 1
"let g:pymode_virtualenv_path = './virtualenv'
let g:pymode_rope = 0

"""" BufExplorer
"map <leader>b :BufExplorer<CR>

"""" Buffergator
map <leader>be :BuffergatorToggle<CR>
map <leader>bn :BuffergatorMruCycleNext<CR>
map <leader>bp :BuffergatorMruCyclePrev<CR>
let g:buffergator_viewport_split_policy = "L"
let g:buffergator_split_size = 60
let g:buffergator_show_full_directory_path = 0

"""" Syntastic
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1
let g:syntastic_javascript_checkers = ["jshint", "jscs"]
let g:syntastic_quiet_messages = {"level": []}

"""" vim-jasmine
autocmd BufReadPost,BufNewFile *.spec.js set filetype=jasmine.javascript syntax=jasmine
"""" javascript-libraries-syntax
let g:used_javascript_libs = 'angularjs'

"""" deoplete
let g:deoplete#enable_at_startup = 1

"""" GoldenView
let g:goldenview__enable_default_mapping=0
nmap <silent> <leader>l <Plug>GoldenViewSplit

"""" airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

"""" Key Mappings
" bind ctrl+space for omnicompletion
inoremap <Nul> <C-x><C-o>
" Code folding toggle
nmap <CR> za 
" the following prevents the mapped <CR> from interfering
" with selection of history items and jumping to errors
:autocmd CmdwinEnter * nnoremap <CR> <CR>
:autocmd BufReadPost quickfix nnoremap <CR> <CR>
" show whitespace
nnoremap <F10> :<C-U>setlocal list! list? <CR>
"nnoremap <F10> :<C-U>setlocal lcs=tab:»·,trail:·,eol:$ list! list? <CR>
" remove trailing whitespace
nnoremap <Leader>rtw :%s/\s\+$//e<CR>
" buffer sizing
map <silent> <A-h> <C-w><
map <silent> <A-j> <C-w>-
map <silent> <A-k> <C-w>+
map <silent> <A-l> <C-w>>
" buffer navigation
map <silent> <C-h> <C-w>h
map <silent> <C-k> <C-w>k
map <silent> <C-l> <C-w>l
map <silent> <C-j> <C-w>j
" reformat file
map <F7> mzgg=G`z

"""" Virtualenv
if !empty($VIRTUAL_ENV_PY)
	let g:python3_host_prog=$VIRTUAL_ENV_PY
endif

call plug#begin('~/.vim/plugged')
" automatically closes quotes, parens, brackets, etc.
Plug 'Raimondi/delimitMate'
" automatically closes html tags (and positions cursor center of tags
Plug 'vim-scripts/HTML-AutoCloseTag'
" asynchronous keyword completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" deoplete and jedi
Plug 'zchee/deoplete-jedi'
" git wrapper
Plug 'tpope/vim-fugitive'
" syntax checking
Plug 'scrooloose/syntastic'
" tab completion
Plug 'ervandew/supertab'
Plug 'klen/python-mode'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'tpope/vim-surround'
Plug 'davidhalter/jedi-vim'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'majutsushi/tagbar'
" plugin for intensely orgasmic commenting
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
" nerdtree git status
Plug 'Xuyuanp/nerdtree-git-plugin'
" cli fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" TODO: don't forget to learn this one
Plug 'mattn/emmet-vim'
Plug 'vim-airline/vim-airline'
" TODO: https://github.com/sjl/gundo.vim
" -- visualize vim undo tree

" At once time active but replacements are being tried out or dropping
" entirely
"Plug 'jlanzarotta/bufexplorer'
"Plug 'fholgado/minibufexpl.vim'
" always have a nice view for split windows
"Plug 'zhaocai/GoldenView.Vim'
call plug#end()
