"""" Dependencies
" * nerd-fonts-complete (AUR)
" * alexanderjeurissen/ranger_devicons (for ranger... dev icons)

if has('unix')
	let s:uname = substitute(system('uname -s'), '\n', '', '')
endif

" {{{ stock options
"scriptencoding utf-8
set mouse=a
set encoding=utf-8
" source .vimrc or .exrc from any directory vim is run from
set exrc
set secure
" display whitespace characters
setlocal listchars=tab:»·,trail:·,eol:¬,space:␣
set list
" font
"set guifont=Inconsolata\ for\ Powerline:h15
"set guifont=Droid\ Sans\ Mono\ for\ Powerline\ Nerd\ Font\ Complete\ 12
" tabs and shit
set softtabstop=2
set tabstop=2
set noexpandtab
set shiftwidth=2
set autoindent
" keep three lines below and above the cursor
set scrolloff=3
" buffers keep change history
set hidden
" new splits will be focused on bottom
set splitbelow
" new vsplits will be focused on right
set splitright
" Disable Background Color Erase (BCE) so that color schemes
" work properly when vim is used inside tmux and screen.
if &term =~ 'screen'
	set t_ut=
endif 
" ignores
set wildignore+=virtualenv/**,node_modules/**,static/js/lib/**
" filetype plugins
filetype on
filetype plugin on
filetype plugin indent on
" display
set number
syntax on
hi clear SpellBad
hi SpellBad cterm=underline,bold ctermfg=magenta
set foldmethod=indent
set foldlevel=100
set nowrap
set hlsearch
set cursorline
" sytles the omnicomplete popup
highlight Pmenu ctermbg=235 cterm=NONE
highlight PmenuSel ctermbg=130 ctermfg=232 cterm=bold
" set current buffer as window title
set title
" autocomplete vim commands
set wildmenu
" displays the statusline always
set laststatus=2
" paste mode toggle
nnoremap <F12> :set invpaste paste?<CR>
set pastetoggle=<F12>
set showmode
" refresh syntax highlighting
autocmd BufEnter,InsertLeave * :syntax sync fromstart
"""" completion menu tweaks
" vim's popup menu doesn't select the first completion item, but rather just
" inserts the longest common text of all matches
set completeopt=longest,menuone,preview
" changes behavior of the <Enter> key when the popup is visible in that the
" Enter key will simply select the highlighted menu item, just as <C-Y> does
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Makes <C-N> work the way it normally does, however when the menu appears the
" <Down> key is simulated. Keeps a menu item always highlighted which results
" in the ability to keep typing characters to narrow the matches and the
" nearest match will be selected so that Enter can be hit at anytime to insert
" it.
inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

inoremap <expr> <M-,> pumvisible() ? '<C-n>' :
  \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
"inoremap <expr> <s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>" -- error
set background=dark
" }}}

" {{{ key bindings
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
if s:uname != 'Darwin'
	map <silent> <A-h> <C-w>>
	map <silent> <A-j> <C-w>-
	map <silent> <A-k> <C-w>+
	map <silent> <A-l> <C-w><
else 
	" yay mac, same keys as non-mac bindings but mac alt+X 
	" produces an actual character we need to bind to
	map <silent> ˙ <C-w>>
	map <silent> ∆ <C-w>-
	map <silent> ˚ <C-w>+
	map <silent> ¬ <C-w><
endif 
" buffer navigation
map <silent> <C-h> <C-w>h <C-w>_
map <silent> <C-k> <C-w>k <C-w>_
map <silent> <C-l> <C-w>l <C-w>_
map <silent> <C-j> <C-w>j <C-w>_
" reformat file
map <F7> mzgg=G`z
" display a list of buffers prompting for the number to switch to
nnoremap <F5> :buffers<CR>:buffer<Space>
" }}}

" {{{ nvim specific
if has('nvim')
	let g:python2_host_prog='/usr/bin/python2'
	"let g:python3_host_prog='/usr/bin/python'
	let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
	"let g:loaded_python_provider = 1
" allows navigating out of the terminal
	tnoremap <C-h> <C-\><C-n><C-w>h
	tnoremap <C-j> <C-\><C-n><C-w>j
	tnoremap <C-k> <C-\><C-n><C-w>k
	tnoremap <C-l> <C-\><C-n><C-w>l
	let $NVIM_TUI_ENABLE_TRUE_COLOR=1
	" automatically enter insert mode when switching to a terminal buffer
	autocmd BufWinEnter,WinEnter term://* startinsert
	" don't display whitespace characters in the terminal
	autocmd TermOpen term://* set nolist
	" need this so that whitespace chars are displayed if a file is opened
	" via ranger
	autocmd BufAdd * set list
	" don't show whitespace for vim-fugitive windows
	autocmd BufWinEnter,WinEnter */.git/* set nolist
	" remove whitespace chars from NERDTree
	autocmd BufWinEnter,WinEnter *NERD* set nolist
	" exclude terminal from buffer list
	autocmd TermOpen * set nobuflisted
	" zsh
	nnoremap <silent> <F3> :terminal zsh<CR>
	" zsh - but split the window first
	nnoremap <silent> <leader><F3> :split<CR> :terminal zsh<CR>
	" ranger
	nnoremap <silent> <F4> :terminal ranger<CR>
endif
" }}}

" {{{ plugins
" SuperTab
"let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabDefaultCompletionType = '<c-x><c-o>'

" tagbar
"map <leader>tb :TagbarToggle<CR>
map <leader>tb :TagbarOpenAutoClose<CR>
map <leader>Tb :TagbarToggle<CR>


" fzf
map <leader>c :FZF<CR>

"NERDTree
let NERDTreeQuitOnOpen = 1
let NERDTreeWinSize = 50
let NERDTreeIgnore=['\.pyc$', '\.vim$', '\~$']
map <leader>N :NERDTreeToggle<CR>

" NERDCommenter
let g:NERDDefaultAlign = 'left'

" rope
map <leader>j :RopeGotoDefinition<CR>
map <leader>r :RopeRename<CR>

" pymode
let g:pymode_options_max_line_length = 120
let g:pymode_options_colorcolumn = 1
"let g:pymode_virtualenv = 1
"let g:pymode_virtualenv_path = './virtualenv'
let g:pymode_rope = 0
let g:pymode_lint_checkers = ['pylint', 'pyflakes', 'mccabe']
let g:pymode_lint_options_pep8 = {'max_line_length': g:pymode_options_max_line_length}
let g:pymode_lint_options_pylint = {'max-line-length': g:pymode_options_max_line_length}
let g:pymode_lint_ignore = 'W191'

" buffergator
map <F2> :BuffergatorToggle<CR>
map <leader><F2> :BuffergatorTabsOpen<CR>
"map <leader>bn :BuffergatorMruCycleNext<CR>
"map <leader>bp :BuffergatorMruCyclePrev<CR>
let g:buffergator_viewport_split_policy = "T"
let g:buffergator_hsplit_size = 15
let g:buffergator_show_full_directory_path = 0
let g:buffergator_sort_regime = "basename"
let g:buffergator_suppress_keymaps = 1

" syntastic
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1
let g:syntastic_javascript_checkers = ["jshint", "jscs"]
let g:syntastic_quiet_messages = {"level": []}
"let g:syntastic_python_checkers = ['pylint', 'pyflakes', 'pep8']
let g:syntastic_python_checkers = []
let g:syntastic_html_checkers = []

" vim-javascript
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_ngdoc = 1

" vim-jasmine
autocmd BufReadPost,BufNewFile *.spec.js set filetype=jasmine.javascript syntax=jasmine
" javascript-libraries-syntax
let g:used_javascript_libs = 'angularjs'

" deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#sources = {}
let g:deoplete#sources._ = ['buffer', 'tag', 'file', 'ultisnips']

" ultisnips
let g:UltiSnipsExpandTrigger = "<c-j>"

" airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" YCM
"let g:ycm_global_ycm_extra_conf = "~/.vim/ycm_extra_conf.py"

" vCooler (color picker)
" alt-c activates
let g:vcoolor_lowercase = 1
if s:uname != 'Darwin'
	let g:vcoolor_custom_picker = 'yad --color --center --init-color '
endif

" vim-bufkill
cabbrev bd :BD!
" when in terminal Ctrl-d calls :BD! rather than doing a normal shell exit
" (which preserves splits)
tnoremap <C-d> <C-\><C-n>:BD!<CR>

" vim-cpp-enhanced-highlight
let g:cpp_class_scope_highlight = 1
" }}}

" {{{ plugin overrides
" pymode and it's fuckin' spaces only shit
autocmd FileType python call overrides#pymode()
" }}}

" {{{ vim-plug
call plug#begin('~/.vim/plugged')
" html5 omnicomplete, indent, and syntax
Plug 'othree/html5.vim'
" pairs of handy bracket mappings
Plug 'tpope/vim-unimpaired'
" plugin to toggle, display and navigate marks
Plug 'kshenoy/vim-signature'
" shows git diff in the gutter
Plug 'airblade/vim-gitgutter'
" preserves splits when closing buffers
Plug 'qpkorr/vim-bufkill'
" preview colors (hex)
Plug 'ap/vim-css-color'
" color picker
Plug 'KabbAmine/vCoolor.vim'
" Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
" additional c++ syntax highlighting
Plug 'octol/vim-cpp-enhanced-highlight'
" vastly improved javascript indentation and syntax support
Plug 'pangloss/vim-javascript'
" TypeScript syntax files
Plug 'leafgarland/typescript-vim'
" needed by *tsuquyomi*
Plug 'Shougo/vimproc.vim'
" works as a client for a TSServer
Plug 'Quramy/tsuquyomi'
" automatically closes quotes, parens, brackets, etc.
Plug 'Raimondi/delimitMate'
" automatically closes html tags (and positions cursor center of tags
Plug 'vim-scripts/HTML-AutoCloseTag'
" asynchronous keyword completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" deoplete and jedi
Plug 'zchee/deoplete-jedi'
" snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
" git wrapper
Plug 'tpope/vim-fugitive'
" syntax checking
Plug 'scrooloose/syntastic'
" tab completion
Plug 'ervandew/supertab'
Plug 'klen/python-mode', { 'branch': 'develop' }
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'tpope/vim-surround'
Plug 'davidhalter/jedi-vim'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'majutsushi/tagbar'
" plugin for intensely orgasmic commenting
Plug 'scrooloose/nerdcommenter'
" tree explorer 
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
" nerdtree git status
Plug 'Xuyuanp/nerdtree-git-plugin'
" cli fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" TODO: don't forget to learn this one
Plug 'mattn/emmet-vim'
" powerline variant
Plug 'vim-airline/vim-airline'

" Themes
Plug 'sheerun/vim-wombat-scheme'
Plug 'morhetz/gruvbox'
Plug 'dracula/vim'
Plug 'reewr/vim-monokai-phoenix'
" generates and changes colorschemes on the fly
Plug 'dylanaraps/wal'
" Adds file type glyphs/icons to many popular vim plugins
Plug 'ryanoasis/vim-devicons'
" fancy start screen for vim
Plug 'mhinz/vim-startify'
" TODO: https://github.com/sjl/gundo.vim
" -- visualize vim undo tree
call plug#end()
" }}}

colorscheme monokai-phoenix

" {{{ vim-signature keybindings
" mx           Toggle mark 'x' and display it in the leftmost column
" dmx          Remove mark 'x' where x is a-zA-Z
" 
" m,           Place the next available mark
" m.           If no mark on line, place the next available mark. Otherwise, remove (first) existing mark.
" m-           Delete all marks from the current line
" m<Space>     Delete all marks from the current buffer
" ]`           Jump to next mark
" [`           Jump to prev mark
" ]'           Jump to start of next line containing a mark
" ['           Jump to start of prev line containing a mark
" `]           Jump by alphabetical order to next mark
" `[           Jump by alphabetical order to prev mark
" ']           Jump by alphabetical order to start of next line having a mark
" '[           Jump by alphabetical order to start of prev line having a mark
" m/           Open location list and display marks from current buffer
" 
" m[0-9]       Toggle the corresponding marker !@#$%^&*()
" m<S-[0-9]>   Remove all markers of the same type
" ]-           Jump to next line having a marker of the same type
" [-           Jump to prev line having a marker of the same type
" ]=           Jump to next line having a marker of any type
" [=           Jump to prev line having a marker of any type
" m?           Open location list and display markers from current buffer
" m<BS>        Remove all markers
" }}}

" {{{ Resources
" deoplete and ultisnips - https://gregjs.com/vim/2016/neovim-deoplete-jspc-ultisnips-and-tern-a-config-for-kickass-autocompletion/
" }}}
