"vimrc file
"location: $HOME/.vimrc or ~/.vimrc
"last modified: 1/18/13

"Quality of life
syntax on
set ruler
set showcmd "shows partial commands bottom right
set scrolloff=5 "lines between cursor and edge of screen when scrolling

"Title support with tmux
if $TMUX != ""
  autocmd BufEnter,FocusGained * call system("tmux rename-window " . expand("%")) 
endif
set title

"Tabs/indenting
set tabstop=4
set expandtab
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent

"Line numbers
set number
:highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

"Key mapping
set timeoutlen=250
let mapleader = ","
map + mb >'a 'b
map _ mb <'a 'b
map ) :call AddComment()<cr>
map ( :exec "'a,. s/^\\(\\S\\)\\1\\?//"<cr>:noh<cr>:echo ""<cr>
nmap :Q :q
nmap :W :w
vmap :$ G
nnoremap N Nzz
nnoremap n nzz
nmap <silent> <leader>v :set smartindent! \| set autoindent!<cr>
nmap <silent> <leader>c :set number!<cr>
"inoremap {<cr> {<cr>}<Esc>O
nnoremap <silent> <space> zz:set cursorline! cursorcolumn!<cr>
vnoremap "" <esc>`<i"<esc>`>la"<esc>
vnoremap '' <esc>`<i'<esc>`>la'<esc>
nnoremap <silent> // :call AckSearchTerm()<cr>n

"Copy to a file
map <leader>y "fy:new ~/.vim/.paste<cr>:%d<cr>:$put f<cr>:x<cr>
map <leader>p :r ~/.vim/.paste<cr>

"Makes f and t work across multiple lines
nmap <silent> f :call FindChar(0, 0, 0)<cr>
omap <silent> f :call FindChar(0, 1, 0)<cr>
nmap <silent> F :call FindChar(1, 0, 0)<cr>
omap <silent> F :call FindChar(1, 1, 0)<cr>
nmap <silent> t :call FindChar(0, 0, 1)<cr>
omap <silent> t :call FindChar(0, 0, 0)<cr>
nmap <silent> T :call FindChar(1, 0, 1)<cr>
omap <silent> T :call FindChar(1, 0, 0)<cr>

"Disable arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

"Search options
set ignorecase
set smartcase
set hlsearch
highlight Search ctermfg=Black ctermbg=LightMagenta cterm=None
nnoremap <CR> :noh<CR>:echo ""<CR><CR>

"Undo options
if v:version >= 703
 set undodir=~/.vim/vimundo "This directory must exist, vim can't create it
 set undofile
 set undolevels=1000 "maximum number of changes that can be undone
 set undoreload=10000 "maximum number of lines to save for undo on a buffer reload
endif

"Special cases
autocmd BufRead,BufNewFile *.vm set filetype=html
autocmd BufRead,BufNewFile *.less set filetype=css
autocmd BufRead,BufNewFile *.salsa set filetype=java
autocmd FileType html set ts=2 sw=2 sts=2
autocmd FileType make set noet

"Auto make when writing
autocmd BufWritePost *.vm silent !$TRTOP/scripts/tweak flush velocity >/dev/null 2>&1 &
autocmd BufWritePost *.js silent !make -C $TRTOP/site/js3 >/dev/null 2>&1  &
autocmd BufWritePost *.css silent !make -C $TRTOP/site/css2 >/dev/null 2>&1 &
autocmd BufWritePost *.less silent !make -C $TRTOP/site/css2 >/dev/null 2>&1 &

"Plugins
execute pathogen#infect()
filetype plugin indent on
let g:vitality_always_assume_iterm = 1

"Functions
fun! AddComment()
 call inputsave()
 let output = input('Comment type:')
 call inputrestore()
 exec "'a,. s/^/".escape(output, '/')."/"
endfun

fun! FindChar(back, inclusive, exclusive)
 let flag = 'W'
 if a:back
   let flag = 'Wb'
 endif
 if search('\V' . nr2char(getchar()), flag)
   if a:inclusive
     norm! l
     endif
     if a:exclusive
     norm! h
   endif
 endif
endfun

fun! AckSearchTerm()
   let shellcmd = "cat ~/.vim/acksearch"
   let output = system(shellcmd)
   let output = substitute(output, '\n$', '', '')
   exe 'let @/ ="'.output.'"'
endfun
