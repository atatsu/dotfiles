"""" Dependencies
" * nerd-fonts-complete (AUR)
" * alexanderjeurissen/ranger_devicons (for ranger... dev icons) 

" {{{ General shit
set encoding=utf-8 
set t_Co=256 " enable mouse support set mouse=a

" display whitespace characters
setlocal listchars=tab:»·,trail:·,eol:¬,space:␣
set list

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
j
" new vsplits will be focused on right
set splitright
j
" Disable Background Color Erase (BCE) so that color schemes
" work properly when vim is used inside tmux and screen.
if &term =~ 'screen'
	set t_ut=
endif 

" filetype plugins
filetype on
filetype plugin on
filetype plugin indent on
" FIXME: move these all to `ftplugin`
" remove trailing whitespace from various filetypes
autocmd BufWritePre *.js :%s/\s\+$//e
autocmd BufWritePre *.vue :%s/\s\+$//e
autocmd BufWritePre *.html :%s/\s\+$//e
autocmd BufWritePre *.css :%s/\s\+$//e
autocmd BufWritePre *.py :call flake8#Flake8()
autocmd FileType dockerfile autocmd BufWritePre <buffer> :%s/\s\+$//e
"autocmd FileType html autocmd BufWritePre <buffer> call HtmlBeautify()

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
" changes behavior of the <Enter> key when the popup is visible in that the
" Enter key will simply select the highlighted menu item, just as <C-Y> does
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" set current buffer as window title
set title

" autocomplete vim commands
set wildmenu

" displays the statusline always
set laststatus=2

set showmode

" refresh syntax highlighting
autocmd BufEnter,InsertLeave * :syntax sync fromstart

" use ag over grep
if executable('ag')
	set grepprg=ag\ --nogroup\ --nocolor
endif
" }}}

" {{{ File associations (that ain't standard)

autocmd BufRead,BufNewFile *.vue set filetype=html

" }}}



" {{{ Mappings

" copy register easy mode
noremap <leader>y "+y
vnoremap <leader>y "+y

" ag prompt
command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!  
nnoremap <leader>G :Ag<space> 
" grep for word under cursor 
nnoremap <leader>K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR> 

" display a list of buffers prompting for the number to switch to 
nnoremap <F5> :buffers<CR>:buffer<Space>

" code folding toggle
nmap <CR> za
" the following prevents the mapped <CR> from interfering
" with selection of history items and jumping to errors
"":autocmd CmdwinEnter * nnoremap <CR> <CR>
:autocmd BufReadPost quickfix nnoremap <CR> <CR>

" provide a way to remind neovim wtf the whitespace chars are supposed to be
nnoremap <leader><F10> :setlocal listchars=tab:»·,trail:·,eol:¬,space:␣<CR>
" toggle whitespace
nnoremap <F10> :<C-U>setlocal list! list? <CR>
" I don't know wtf is going on but if I load one file type (like a js file)
" and then load a different file type (like a py file) the whitespace for the
" latter file is completely fucked. Remind neovim what whitespace chars should
" be whenever a file is opened
autocmd BufNewFile,BufRead * setlocal listchars=tab:»·,trail:·,eol:¬,space:␣


" paste mode toggle
nnoremap <F12> :set invpaste paste?<CR>
set pastetoggle=<F12>

" vim-bufkill
cabbrev bd :BD!
" when in terminal Ctrl-d calls :BD! rather than doing a normal shell exit
" (which preserves splits)
tnoremap <C-d> <C-\><C-n>:BD!<CR>

" buffer sizing
map <silent> <A-h> <C-w>>
map <silent> <A-j> <C-w>-
map <silent> <A-k> <C-w>+
map <silent> <A-l> <C-w><

" buffer navigation
"map <silent> <C-h> <C-w>h <C-w>_
"map <silent> <C-k> <C-w>k <C-w>_
"map <silent> <C-l> <C-w>l <C-w>_
"map <silent> <C-j> <C-w>j <C-w>_
map <silent> <C-h> <C-w>h
map <silent> <C-k> <C-w>k
map <silent> <C-l> <C-w>l
map <silent> <C-j> <C-w>j

" nvim specific
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
	autocmd BufWinEnter,WinEnter term://* set nolist
	" need this so that whitespace chars are displayed if a file is opened
	" via ranger
	autocmd BufAdd * set list
	" don't show whitespace for vim-fugitive windows
	autocmd BufWinEnter,WinEnter */.git/* set nolist
	" remove whitespace chars from NERDTree
	autocmd BufWinEnter,WinEnter *NERD* set nolist
	" exclude terminal from buffer list autocmd TermOpen * set nobuflisted zsh 
	" nnoremap <silent> <F3> :terminal zsh<CR> 
	noremap <silent> <F3> :terminal zsh<CR>i
	" zsh - but split the window first
	nnoremap <silent> <leader><F3> :split<CR> :terminal zsh<CR>
	" ranger
	nnoremap <silent> <F4> :terminal ranger<CR>i
endif

" }}}



" {{{ plugin options
"
" airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" buffergator
"map <leader>bn :BuffergatorMruCycleNext<CR>
"map <leader>bp :BuffergatorMruCyclePrev<CR>
let g:buffergator_viewport_split_policy = "T"
let g:buffergator_hsplit_size = 15
let g:buffergator_show_full_directory_path = 0
let g:buffergator_sort_regime = "basename"
let g:buffergator_suppress_keymaps = 1

" NERDCommenter
let g:NERDDefaultAlign = 'left'

" nerdtree
let NERDTreeQuitOnOpen = 1
let NERDTreeWinSize = 50
let NERDTreeIgnore=['\.pyc$', '\.vim$', '\~$']
let NERDTreeHijackNetrw=1

" devicons
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFolderOpenClose = 1
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {}
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['vue'] = ''

" pymode
let g:pymode_options_max_line_length = 120
let g:pymode_options_colorcolumn = 1
"let g:pymode_virtualenv = 1
"let g:pymode_virtualenv_path = './virtualenv'
let g:pymode_rope = 0
" let g:pymode_lint_checkers = ['pylint', 'pyflakes', 'mccabe']
" pyflakes doesn't seem respect `from __future__ import annotations`
let g:pymode_lint_checkers = ['pylint', 'mccabe']
let g:pymode_lint_options_pep8 = {'max_line_length': g:pymode_options_max_line_length}
let g:pymode_lint_options_pylint = {'max-line-length': g:pymode_options_max_line_length}
let g:pymode_lint_ignore = ['W191']

" supertab
let g:SuperTabDefaultCompletionType = '<c-x><c-o>'
"let g:SuperTabDefaultCompletionType = "context"
"let g:SuperTabContextDefaultCompletionType = "<c-p>"
"let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
"let g:SuperTabContextDiscoverDiscovery = ["&omnifunc:<c-x><c-o>"]

" vim-colors-pencil 
let g:pencil_higher_contrast_ui = 1 

" vim-flake8
let g:flake8_cmd="/usr/bin/flake8"
let g:flake8_show_in_gutter=1
"let g:flake8_show_in_file=1

" ale
"nmap <silent> <C-n> <Plug>(ale_next_wrap)
"nmap <silent> <C-p> <Plug>(ale_previous_wrap)

" }}}



" {{{ plugin mappings

" buffergator
map <F2> :BuffergatorToggle<CR>
map <leader><F2> :BuffergatorTabsOpen<CR>

" fzf
map <leader>f :FZF<CR>

" goyo / limelight
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" nerdtree
map <leader>N :NERDTreeToggle<CR>
"
" tagbar
"map <leader>tb :TagbarToggle<CR>
map <leader>tb :TagbarOpenAutoClose<CR>
map <leader>Tb :TagbarToggle<CR>

" supertab autocmd FileType * \ if &omnifunc != '' |
"  \   call SuperTabChain(&omnifunc, "<c-p>") |
"  \   call SuperTabSetDefaultCompletionType("<c-x><c-u>") |
"  \ endif

" semantic-highlight
"let g:semanticTermColors = [28,1,2,3,4,5,6,7,25,9,10,34,12,13,14,15,16,125,124,19]
"let g:semanticGUIColors = ['#d52ble', '#859900', '#cb4b16', '#268bd2', '#a3e9a4','#ac206f', '#306860', '#c54b8c', '#3e3e3e', '#5b2527', '#03396c','#005b96', '#008744', '#d62d20']

" python-syntax
"let python_highlight_all = 1
" }}}



" {{{ plugin overrides
" pymode and it's fuckin' spaces only shit
autocmd FileType python call overrides#pymode()

" }}}




" {{{ vim-plug
call plug#begin('~/.local/share/nvim/plugged')

" --------------------------------------------
" -- Colors
" color scheme collection
Plug 'flazz/vim-colorschemes'

" --------------------------------------------
" -- Navigation
" tree explorer 
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
" cli fuzzy finder
" note: don't forget to also install `the_silver_searcher`
"Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" preserves splits when closing buffers
Plug 'qpkorr/vim-bufkill'
" buffergator
Plug 'jeetsukumaran/vim-buffergator'
" plugin to toggle, display and navigate marks
Plug 'kshenoy/vim-signature'

" --------------------------------------------
" -- VCS
" git wrapper 
Plug 'tpope/vim-fugitive'
" shows git diff in the gutter
Plug 'airblade/vim-gitgutter'
" nerdtree git status
Plug 'Xuyuanp/nerdtree-git-plugin'
" a git commit browser `:GV` to open commit browser `:GV!` only commits pertaining to current file
" `:GV?` fills location list with revisions of current file
" `:GV` or :GV? can be used in visual mode to track selected lines
" `o` or `<cr>` on commit to display contents
" `o` or `<cr>` on commits to display diff
" `O` opens new tab
" `gb` for `:Gbrowse`
" `]]` and `[[` to move between commits
" `.` to start command-line with `:Git [CURSOR] SHA`
" `q` to close
Plug 'junegunn/gv.vim'

" --------------------------------------------
" -- Bells and whistles
" powerline variant
Plug 'vim-airline/vim-airline'
" fancy start screen for vim
Plug 'mhinz/vim-startify'
" tagbar
Plug 'majutsushi/tagbar'
" distraction-free writing in vim
Plug 'junegunn/goyo.vim'
" hyperfocus-writing in vim
Plug 'junegunn/limelight.vim'

" --------------------------------------------
" -- General coding utilities
" A Vim plugin that manages your tag files
Plug 'ludovicchabant/vim-gutentags'
" automatically closes quotes, parens, brackets, etc.
Plug 'Raimondi/delimitMate'
" pairs of handy bracket mappings
Plug 'tpope/vim-unimpaired'
" semantic highlighting for vim
"Plug 'jaxbot/semantic-highlight.vim'
" plugin for intensely orgasmic commenting
Plug 'scrooloose/nerdcommenter'
" tab completion
Plug 'ervandew/supertab'
" surround
Plug 'tpope/vim-surround'
" asynchronous keyword completion 
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Check syntax in Vim asynchronously and fix files,
" with Language Server Protocol (LSP) support
Plug 'dense-analysis/ale'

" --------------------------------------------
" -- Language specific shit
" - Python
" Python syntax highlighting for Vim
"Plug 'hdima/python-syntax'
" Semantic Highlighting for Python in Neovim
Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' }
" pymode
Plug 'klen/python-mode', { 'branch': 'develop' }
" linter
Plug 'nvie/vim-flake8'
" jedi
Plug 'davidhalter/jedi-vim'
" deoplete and jedi
Plug 'zchee/deoplete-jedi' 

" - Web
" automatically closes html tags (and positions cursor center of tags
Plug 'vim-scripts/HTML-AutoCloseTag'
" vastly improved javascript indentation and syntax support
Plug 'pangloss/vim-javascript'
" html5 omnicomplete, indent, and syntax 
Plug 'othree/html5.vim'
" syntax highlighting for a number of popular js libraries
Plug 'othree/javascript-libraries-syntax.vim'
" syntax highlighting for Vue.js components
Plug 'posva/vim-vue'
" preview colors (hex)
Plug 'ap/vim-css-color'
" TODO: don't forget to learn this one
Plug 'mattn/emmet-vim'
" vim plugin which formats javascript files by js-beautify
"Plug 'maksimr/vim-jsbeautify'
" edit code that's embedded within other code
Plug 'AndrewRadev/inline_edit.vim'
" A Vim plugin that provides GraphQL file detection, 
" syntax highlighting, and indentation.
Plug 'jparise/vim-graphql'
" Tern-based javascript editing support
" XXX: Assumes you've ran `npm install -g tern` first!
Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }

" - Docker
" vim syntax file & snippets for Docker's Dockerfile
Plug 'ekalinin/Dockerfile.vim'

" --------------------------------------------
" Make sure this one loads last so that all plugins it
" supports have already been loaded
" Adds file type glyphs/icons to many popular vim plugins
Plug 'ryanoasis/vim-devicons'

call plug#end()
" }}}

set background=dark
colorscheme Benokai

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
