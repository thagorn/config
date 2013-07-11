"vimrc file
"location: $HOME/.vimrc or ~/.vimrc
"last modified: 6/11/13

" -----------------------------------------------------------------------------------------------------------------
" Basic Setup
" -----------------------------------------------------------------------------------------------------------------
syntax on       "Syntax highlighting
set ruler       "Show line/column number bottom right
set showcmd     "Show partial commands bottom right
set scrolloff=5 "lines between cursor and edge of screen when scrolling

"Title support with tmux
if $TMUX != ""
  "If using tmux then set tmux's title to current filename and path
  autocmd BufEnter,FocusGained * call system("tmux rename-window " . expand("%")) 
endif
set title "Fallback to setting terminal title if not in tmux

"Tabs/indenting
set tabstop=4       "Tabs are 4 spaces long
set expandtab       "Use spaces instead of tabs
set shiftwidth=4    "Number of spaces to auto-indent
set softtabstop=4   "Number of spaces for <Backspace> to delete
set autoindent      "Maintain level of indent currently at
set smartindent     "Guess when to create a deeper indent

"Line numbers
set number          "Show dark grey line numbers
:highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE

"Search options
set ignorecase      "Case insensitive searching
set smartcase       "If you search with capital letters turn on case sensitive search
set incsearch       "Start finding results as you type (incremental search)
set hlsearch        "Highlight search terms in LightMagenta, stop highlighting when <CR> is pressed
highlight Search ctermfg=Black ctermbg=LightMagenta cterm=None
nnoremap <CR> :noh<CR>:echo ""<CR><CR>

"Undo options
if v:version >= 703
  set undodir=~/.vim/vimundo  "This directory must exist, vim can't create it
  set undofile                "Turn on undo history
  set undolevels=1000         "maximum number of changes that can be undone
  set undoreload=10000        "maximum number of lines to save for undo on a buffer reload
endif

" -----------------------------------------------------------------------------------------------------------------
" Key Mapping
" -----------------------------------------------------------------------------------------------------------------
set timeoutlen=250    "Stop looking for a keymap after 1/4 of a second (default 1)
let mapleader = ","   "Replace instances of  <leader> with ,

"Indent/Dedent from mark 'a' to current line
noremap + mb >'a 'b
noremap _ mb <'a 'b

"Add/Remove comment to the start of lines from mark 'a' to current line
map ) :call AddComment()<cr>
map ( :exec "'a,. s/^\\(\\S\\)\\1\\?//"<cr>:noh<cr>:echo ""<cr>

"Save me from typing too quickly
nmap :Q :q
nmap :W :w

"Let :$ work in visual mode
vmap :$ G

"Center screen on results when searching
nnoremap N Nzz
nnoremap n nzz

"Copy/paste out of vim cleanly
nmap <silent> <leader>v :set smartindent! \| set autoindent! \| setl smartindent< \| setl autoindent<<cr>
nmap <silent> <leader>c :set number!<cr>

"Space bar centers screen and highlights cursor
nnoremap <silent> <space> zz:set cursorline! cursorcolumn!<cr>

"Double quote in visual mode will quote around the selected text
vnoremap "" <esc>`<i"<esc>`>la"<esc>
vnoremap '' <esc>`<i'<esc>`>la'<esc>

"Double // will search for the last term used in Ack search (requires a bash function in ~/.bashrc)
nnoremap <silent> // :call AckSearchTerm()<cr>n

"Copy/Paste across vim sessions
map <leader>y "fy:new ~/.vim/.paste<cr>:%d<cr>:$put f<cr>:x<cr>
map <leader>p :r ~/.vim/.paste<cr>

"Makes f and t work across multiple lines
nmap <silent> f :call FindChar(0, 0, 0)<cr>
omap <silent> f :call FindChar(0, 1, 0)<cr>
nmap <silent> F :call FindChar(1, 0, 0)<cr>
omap <silent> F :call FindChar(1, 1, 1)<cr>
nmap <silent> t :call FindChar(0, 0, 1)<cr>
omap <silent> t :call FindChar(0, 0, 0)<cr>
nmap <silent> T :call FindChar(1, 1, 0)<cr>
omap <silent> T :call FindChar(1, 1, 0)<cr>

"Disable arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" -----------------------------------------------------------------------------------------------------------------
" Filetype specific settings
" -----------------------------------------------------------------------------------------------------------------
"Syntax
autocmd BufRead,BufNewFile *.less set filetype=css    "Pretend less files are css
autocmd BufRead,BufNewFile *.salsa set filetype=java  "Pretend salsa files are java

"Tabbing
autocmd FileType velocity,vim set ts=2 sw=2 sts=2     "Velocity/vim files have 2 space tabs
autocmd FileType make set noet                        "Make files expect <Tab> characters not spaces

"Auto make when writing
if $TRTOP != ""
  autocmd BufWritePost *.vm silent !$TRTOP/scripts/tweak flush velocity >/dev/null 2>&1 &
  if expand("%:p") =~ 'site/\(js3\|css2\)/mobile'
    autocmd BufWritePost *.js silent !make -C $TRTOP/site/js3/mobile >/dev/null 2>&1  &
    autocmd BufWritePost *.css silent !make -C $TRTOP/site/css2/mobile >/dev/null 2>&1 &
    autocmd BufWritePost *.less silent !make -C $TRTOP/site/css2/mobile >/dev/null 2>&1 &
  elseif expand("%:p") =~ 'site/\(js3\|css2\)/tablet'
    autocmd BufWritePost *.js silent !make -C $TRTOP/site/js3/tablet >/dev/null 2>&1  &
    autocmd BufWritePost *.css silent !make -C $TRTOP/site/css2/tablet >/dev/null 2>&1 &
    autocmd BufWritePost *.less silent !make -C $TRTOP/site/css2/tablet >/dev/null 2>&1 &
  else
    autocmd BufWritePost *.js silent !make -C $TRTOP/site/js3 >/dev/null 2>&1  &
    autocmd BufWritePost *.css silent !make -C $TRTOP/site/css2 >/dev/null 2>&1 &
    autocmd BufWritePost *.less silent !make -C $TRTOP/site/css2 >/dev/null 2>&1 &
  endif
endif

" -----------------------------------------------------------------------------------------------------------------
" Plugins
" -----------------------------------------------------------------------------------------------------------------
" Pathogen
"   Package manager
"   https://github.com/tpope/vim-pathogen
"Tells pathogen to open other packages
execute pathogen#infect()
filetype plugin indent on "Allows plugins to control indent settings
                          "   ... but don't allow them to automatically add comments
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Vitality
"   Teachs iTerm2 and tmux to play well together
"   https://github.com/sjl/vitality.vim
let g:vitality_always_assume_iterm = 1 "Tells vitality I'm in iTerm2 even if ssh'd to another box

" Vim Multiple Cursors
"   Gives multi cursor support to vim (from Sublime text)
"   https://github.com/terryma/vim-multiple-cursors
let g:multi_cursor_exit_from_visual_mode = 0  "<Esc> exits visual mode, not multiple cursors
let g:multi_cursor_exit_from_insert_mode = 0  "<Esc> exits insert mode, not multiple cursors

" Velocity
"   Gives velocity syntax support to vim
"   https://github.com/lepture/vim-velocity
autocmd BufRead,BufNewFile *.vm,*.html,*.htm,*.shtml set filetype=velocity  "Maybe necessary?


" Lucius 
"   Colorscheme
"   https://github.com/jonathanfilip/vim-lucius
set t_Co=256          "Tell vim I have access to 256 colors
set background=light  "Tell vim I'm using a light background
colorscheme lucius    "Set colorscheme

" -----------------------------------------------------------------------------------------------------------------
" Functions
" -----------------------------------------------------------------------------------------------------------------

"Asks for what commend to add
"   Proceeds to add the input text to the start of every line from mark a to current line
fun! AddComment()
  call inputsave()
  let output = input('Comment type:')
  call inputrestore()
  exec "'a,. s/^/".escape(output, '/')."/"
endfun

"Searches for a single character (used to mimic f/t across lines)
"   Searches across lines but not past end of file
"   back - searches backwards
"   inclusive - goes right one character after search
"   exclusive - goes left one character after search
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

"Searches for the last search term used in terminal ack
"   Requires matching functon in ~/.bashrc
fun! AckSearchTerm()
  let shellcmd = "cat ~/.vim/acksearch"
  let output = system(shellcmd)
  let output = substitute(output, '\n$', '', '')
  exe 'let @/ ="'.output.'"'
endfun
