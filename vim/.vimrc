" ----------------------------------------------------------------------------
" vim config by mkaz
" http://github.com/mkaz/dotfiles/vim-files
"
" hat tips
"
"   * Derek Wyatt, http://derekwyatt.org/
"
"   * Vimcasts, http://vimcasts.org/
"
"   * Damien Conway, More Instantly Better Vim
"     http://www.youtube.com/watch?v=aHm36-na4-4
"
"   * Doug Black
"     https://dougblack.io/words/a-good-vimrc.html
"
" ----------------------------------------------------------------------------

set nocompatible
filetype off

" use vim-plug to manage plugins
call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go'
Plug 'junegunn/fzf',  { 'dir': '~/.fzf' }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'SirVer/ultisnips'
Plug 'tpope/vim-surround'
call plug#end()


" Settings {{{

" Characters {{{
set encoding=utf-8

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" hidden characters
set listchars=tab:▸\ ,eol:¬
" }}}

" Colors {{{
syntax on
set t_Co=256
set background=dark
colorscheme Tomorrow-Night
highlight Normal ctermbg=NONE
highlight nonText ctermbg=NONE
" }}}

" Whitespace stuff {{{
set nowrap
set autoindent
set smartindent
set smarttab
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
" }}}

" Display {{{
set number            " show line numbers
set ruler			  " show ruler
set laststatus=2	  " show status
set showcmd			  " show command in bottom bar
" }}}

" Operation {{{
set scrolloff=2       " scroll 2 lines top/bottom
set hidden            " allows to switch to/from unsaved buffers
set ttyfast
set nobackup
set noswapfile

set modeline			" use modeline override
set modelines=2			" check last two lines
" }}}

" shhhh {{{
set visualbell
set novisualbell
set nobackup
set noerrorbells
autocmd VimEnter * set vb t_vb=
" }}}

" }}}

" Folding {{{
set foldenable    			" enable folding
set foldlevelstart=10		" start with expanded
set foldnestmax=10			" max number of nested folds

" space open/close folds
nnoremap <space> za
" }}}

" Searching {{{

set hlsearch		" highlight matches
set incsearch		" search as typing
set ignorecase
set smartcase

set history=1000
set undolevels=1000

set wildmenu
set wildmode=longest,list,full
set wildignore+=.hg,.git,.svn         "version control
set wildignore+=*.rbc,*.class,*.pyc   "compiled formats
set wildignore+=*.DS_Store            "OSX files

" }}}

" File Specific {{{

" load the plugin and indent settings for the detected filetype
filetype plugin indent on

augroup configgroup

	autocmd!

	" Thorfile, Rakefile, Vagrantfile and Gemfile are Ruby
	autocmd BufRead,BufNewFile {Gemfile,Rakefile,Vagrantfile,Thorfile,config.ru} set ft=ruby

	" md, markdown, and mk are markdown and define buffer-local preview
	autocmd BufRead,BufNewFile *.md set tw=80 wrap linebreak nolist

	" Python File Types (use spaces)
	autocmd FileType python set expandtab
	autocmd FileType python map <Leader>r :w<CR>:!python %<CR>

	" PHP File Types (WordPress, use tabs)
	autocmd FileType php set expandtab

	" golang
	autocmd BufRead,BufNewFile *.go set filetype=go
	autocmd FileType go nmap <leader>r <Plug>(go-run)
	autocmd FileType go nmap <leader>b <Plug>(go-build)
	autocmd FileType go nmap <leader>t <Plug>(go-test)
	let g:go_fmt_command = "goimports"

	" Apache
	autocmd FileType apache set expandtab

	" Templates
	autocmd BufRead,BufNewFile *.{tpl,eco}    set ft=html

	" load skeleton if exists
  	autocmd! BufNewFile * silent! 0r ~/.vim/skel/tmpl.%:e

	" auto strip whitespace for filetypes
	autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

	" Remember last location in file
	au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif

augroup END

" }}}

" Key Bindings {{{

let mapleader=","

" :w!! to save with sudo
ca w!! w !sudo tee >/dev/null "%"

" Unhighlight Search using ,SPC
nmap <silent> <Leader><Space> :nohlsearch<CR>

" Explore File menu
let g:netrw_liststyle=3
map <F2> :Explore<CR>


" Command-/ to toggle comments
map <Leader>/ <plug>NERDCommenterToggle<CR>

" CTags
map <Leader>rt :!ctags --extra=+f -R *<CR><CR>


" Buffer Navigation
map <Leader>3 :b#<CR>
map <Leader>n :bn<CR>

" Bubble single lines
nmap <C-Up> [e
nmap <C-Down> ]e

" Bubble multiple lines
vmap <C-Up> [egv
vmap <C-Down> ]egv

" Surround with Quote
map <Leader>' ysiw'
map <Leader>" ysiw"

" Map F1 to ESC
map <F1> <Esc>
imap <F1> <Esc>

" Toggle Spellcheck
:map <F5> :setlocal spell! spelllang=en_us<CR>

:nnoremap <F4> "=strftime("%A, %Y-%m-%d %I:%M%P ")<CR>P
:inoremap <F4> <C-R>=strftime("%A, %Y-%m-%d %I:%M%P ")<CR>

" add semi colon at end of line
map <Leader>; g_a;<Esc>

" format current paragraph (hard wrap)
nnoremap Q gqip

" Add Spaces inside parentheses, WordPress Style
map <Leader>o ci(<space><space><Esc>hp

" toggle show whitespace
map <Leader>w :set list<CR>

" }}}


" :Wrap command
command! -nargs=* Wrap set wrap linebreak nolist

" Math
nmap ++ i<c-R>=

" fzf and ripgrep
map <Leader>p :Files<CR>
nmap ; :Buffers<CR>

" use ripgrep for finding text
map <Leader>f :Find<space>
command! -bang -nargs=* Find call fzf#vim#grep( 'rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --color "always" '.shellescape(<q-args>), 1, <bang>0)

" strips trailing whitespace at the end of files. this
" is called on buffer write in the autogroup above.
function! <SID>StripTrailingWhitespaces()
    " save last search & cursor position
    let _s=@/
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    let @/=_s
    call cursor(l, c)
endfunction


" vim:foldmethod=marker:foldlevel=0

