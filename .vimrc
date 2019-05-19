" Sam Lock's .vimrc

" remove all existing autocmds
autocmd!

""""""""""""""""""""""""""""""""""""""""""""""""""
" BASIC CONFIGURATION
""""""""""""""""""""""""""""""""""""""""""""""""""

" disable vi compatibility (emulation of old bugs)
set nocompatible

set tabstop=4        " tab width is 4 spaces
set shiftwidth=4     " indent also with 4 spaces
set expandtab        " expand tabs to spaces
set smarttab         " auto tab to appropriate location
set softtabstop=4
set autoindent
set laststatus=2
set showmatch
set cursorline
set cmdheight=1
" Hide the sign column (this hides gitgutter output)
set signcolumn=no
set hlsearch
" Disable tab line up top (2 enables)
set showtabline=2
" No backups
set nobackup
set nowritebackup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
" Allow backspacing over everything in insert mode
set backspace=indent,eol,start
" turn syntax highlighting on
syntax on
" Allow use of different filetypes (i.e. for different language types)
filetype plugin indent on
" Fix slow O inserts
:set timeout timeoutlen=1000 ttimeoutlen=100
" Normally, Vim messes with iskeyword when you open a shell file. This can
" leak out, polluting other file types even after a 'set ft=' change. This
" variable prevents the iskeyword change so it can't hurt anyone.
let g:sh_noisk=1
" Insert only one space when joining lines that contain sentence-terminating
" punctuation like `.`.
set nojoinspaces
" If a file is changed outside of vim, automatically reload it without asking
set autoread
" Diffs are shown side-by-side not above/below
set diffopt=vertical
" Turn folding off for real, hopefully
set foldmethod=manual
set nofoldenable
" Copy to system clipboard by default
set clipboard=unnamed

""""""""""""""""""""""""""""""""""""""""""""""""""
" COLOURS
""""""""""""""""""""""""""""""""""""""""""""""""""
" True color mode! (Requires a fancy modern terminal, but iTerm works.)
" Ensure colors work inside tmux
" See :h xterm-true-color, https://github.com/tmux/tmux/issues/1246
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
set t_Co=256 " 256 colors
set background=dark
" Toggle between light and dark background
map <Leader>bg :let &background = ( &background == "dark"? "light" : "dark" )<CR>
colo grb24bit
"color PaperColor

""""""""""""""""""""""""""""""""""""""""""""""""""
" CUSTOM MAPPINGS
""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <F3> :Files<enter>
nmap <F4> :F<enter>
nmap <F5> :Buffers<enter>
nmap <F6> :Lines<enter>
" Set NERDtree to open on Ctrl-n
map <C-n> :NERDTreeToggle<CR>
" Insert pdb break point on next line
nmap <F9> oimport pdb; pdb.set_trace()<ESC>
" Additional functionality for tag functions
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" Incorporate ripgrep for uber fast text searches
let g:rg_command = '
  \ rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always"
  \ -g "*.{js,json,php,md,styl,jade,html,config,py,cpp,c,go,hs,rb,conf}"
  \ -g "!{.git,node_modules,vendor}/*" '
command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)

""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGINS
""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.vim/plugged')

Plug 'w0rp/ale'
Plug 'valloric/youcompleteme'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
"Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdcommenter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-surround'
" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
" Javascripty plugins that I don't use often enough anymore
" Plug 'pangloss/vim-javascript'
" Plug 'mxw/vim-jsx'
" Plug 'posva/vim-vue'

call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""
" STATUS LINE
""""""""""""""""""""""""""""""""""""""""""""""""""
:set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

""""""""""""""""""""""""""""""""""""""""""""""""""
" CUSTOM AUTOCMDS
""""""""""""""""""""""""""""""""""""""""""""""""""

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
\ if line("'\"") > 1 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif

" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

""""""""""""""""""""""""""""""""""""""""""""""""""
" PYTHON SPECIFC CONFIG
""""""""""""""""""""""""""""""""""""""""""""""""""
" Set max line width indicator for python files
autocmd Filetype python set colorcolumn=121
" Set max line width indicator colour to light green
autocmd Filetype python highlight ColorColumn ctermbg = 10

""""""""""""""""""""""""""""""""""""""""""""""""""
" FILE TYPE SPECIFIC CONFIG
""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd Filetype javascript setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd Filetype html setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd Filetype css setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd BufRead,BufNewFile *.vue set filetype=vue
autocmd Filetype vue setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

""""""""""""""""""""""""""""""""""""""""""""""""""
" MISC CONFIG
""""""""""""""""""""""""""""""""""""""""""""""""""

" Set mouse scroll even in iterm (which didn't work when normal terminal did)
set mouse=a
if has("mouse_sgr")
    set ttymouse=sgr
elseif !has("nvim")
    set ttymouse=xterm2
end
