" Sam Lock's .vimrc

" remove all existing autocmds
autocmd!

""""""""""""""""""""""""""""""""""""""""""""""""""
" BASIC CONFIGURATION
""""""""""""""""""""""""""""""""""""""""""""""""""

" Change leader from "\" to SPACE
map <Space> <Leader>

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
set nonu
" Hide the sign column (this hides gitgutter output)
set winwidth=99
set winminwidth=29
set winheight=29
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

" Omni-completion configuration
"set omnifunc=syntaxcomplete#Complete
"set completeopt=menu,preview

" Enable persistent undo history. Requires .vim/undo/ to be pre-existing
set undofile
set undodir=$HOME/.vim/undo

set undolevels=1000
set undoreload=10000

""""""""""""""""""""""""""""""""""""""""""""""""""
" ALE config
""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_completion_enabled = 1
let g:ale_linters = {'python': ['pyls'], 'go': ['gofmt', 'golint', 'govet']}
"let g:ale_linters = {'python': ['pyls'], 'go': ['gofmt', 'golint', 'govet', 'golangserver']}
"let g:ale_linters = {'python': ['flake8', 'pyls', 'jedils']}

set omnifunc=ale#completion#OmniFunc
set completeopt=menu,preview
"set completeopt=longest,menu

nmap <C-]> <Plug>(ale_go_to_definition)
" Override tag mapping to map standard jump-motion back to ctrl-t
"map <C-t> <C-o>

""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
""""""""""""""""""""""""""""""""""""""""""""""""""
" Indent if we're at the beginning of a line. Else, do completion.
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <expr> <tab> InsertTabWrapper()
inoremap <s-tab> <c-n>

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
"colo grb24bit
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

" Incorporate ripgrep for uber fast text searches
let g:rg_command = '
  \ rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always"
  \ -g "*.{js,json,php,md,styl,jade,html,config,py,cpp,c,go,hs,rb,conf}"
  \ -g "!{.git,node_modules,vendor}/*" '
command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)

" Scratch buffer shortcuts
map <Leader>ss :Scratch<enter>

" Regen ctags file
"map <Leader>T :AsyncRun !ctags -R .<enter>

""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGINS
""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.vim/plugged')

"Plug 'w0rp/ale'
Plug 'dense-analysis/ale'
"Plug 'prabirshrestha/vim-lsp'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fugitive'
"For vim-fugitive github integration
Plug 'tpope/vim-rhubarb'
Plug 'airblade/vim-gitgutter'
"Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdcommenter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-surround'
" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'fatih/vim-go'
" Writing tool
Plug 'reedes/vim-pencil'

call plug#end()

" Increase default window width for nerdtree
let g:NERDTreeWinSize=40

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

""""""""""""""""""""""""""""""""""""""""""""""""""
" STATUS LINE
""""""""""""""""""""""""""""""""""""""""""""""""""
set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

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
" PYTHON SPECIFIC CONFIG
""""""""""""""""""""""""""""""""""""""""""""""""""
" Set max line width indicator for python files
"autocmd Filetype python set colorcolumn=121
" Set max line width indicator colour to light green
"autocmd Filetype python highlight ColorColumn ctermbg = 10

" Run pytest for current buffer
map <Leader>tt :!source env/bin/activate.fish && pytest -p no:warnings % <enter>

""""""""""""""""""""""""""""""""""""""""""""""""""
" FILE TYPE SPECIFIC CONFIG
""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd Filetype javascript setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd Filetype html setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd Filetype css setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd BufRead,BufNewFile *.vue set filetype=vue
autocmd Filetype vue setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd BufRead,BufNewFile *yaml.gotmpl set filetype=yaml

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
