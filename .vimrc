"vimrc file
"location: $HOME/.vimrc or ~/.vimrc
"last modified: 2/14/14

" -----------------------------------------------------------------------------------------------------------------
" Basic Setup
" -----------------------------------------------------------------------------------------------------------------
syntax on               "Syntax highlighting
set ruler               "Show line/column number bottom right
set showcmd             "Show partial commands bottom right
set scrolloff=5         "lines between cursor and edge of screen when scrolling
set laststatus=2        "Show statusline
set display+=lastline   "If a line is clipped off by bottom of window show as much of it as possible

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

"Folding
"set foldmethod=syntax "Create folds based on code syntax

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

"Make Y behave like C and D
nmap Y y$

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
nmap <silent> <leader>v :set paste!<cr>
nmap <silent> <leader>c :set number!<cr>

"Space bar centers screen and highlights cursor
nnoremap <silent> <space> zz:set cursorline! cursorcolumn!<cr>

"Double // will search for the last term used in Ack search (requires a bash function in ~/.bashrc)
nnoremap <silent> // :call AckSearchTerm()<cr>n

"Cut/Copy/Paste across vim sessions
vmap <leader>y y:call CrossYank()<cr>
vmap <leader>d d:call CrossYank()<cr>
nmap <leader>p :call CrossPaste("p")<cr>
nmap <leader>P :call CrossPaste("P")<cr>
vmap <leader>p d:call CrossPaste("P")<cr>

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
" Tag jumping
" -----------------------------------------------------------------------------------------------------------------
nmap <F3> g<C-]>
nmap <F2> <C-W>g}

" -----------------------------------------------------------------------------------------------------------------
" Filetype specific settings
" -----------------------------------------------------------------------------------------------------------------
"Syntax
"autocmd BufRead,BufNewFile *.less set filetype=css    "Pretend less files are css
autocmd BufRead,BufNewFile *.hql set filetype=sql     "Pretend hive query files are sql
autocmd BufRead,BufNewFile *.salsa set filetype=java  "Pretend salsa files are java
let html_no_rendering=1                               "Don't underline text between <a> tags, etc

"Tabbing
autocmd FileType velocity,vim,dustjs set ts=2 sw=2 sts=2    "Velocity/vim/dust files have 2 space tabs
autocmd FileType make set noet                              "Make files expect <Tab> characters not spaces

"Auto make when writing
if $TRTOP != ""
  autocmd BufWritePost *.vm silent !$TRTOP/scripts/tweak flush velocity >/dev/null 2>&1 &
  "autocmd BufWritePost *.dust silent !$TRTOP/scripts/tweak flush dust >/dev/null 2>&1 &
  "Dispatch
  autocmd FileType javascript let b:dispatch = 'echo "Making JS" && cd $TRTOP && ./gradlew site:js3:assemble >/dev/null'
  autocmd FileType css let b:dispatch = 'echo "Making CSS" && cd $TRTOP && ./gradlew site:css2:assemble >/dev/null'
  autocmd FileType less let b:dispatch = 'echo "Making CSS" && cd $TRTOP && ./gradlew site:css2:assemble >/dev/null'
  autocmd FileType dustjs let b:dispatch = 'echo "Making DUST" && make -C $TRTOP/site/dust clean >/dev/null && make -C $TRTOP/site/dust && tweak flush dust >/dev/null 2>&1'
  autocmd BufWritePost *.less,*.js,*.dust,*.css Dispatch
endif

" -----------------------------------------------------------------------------------------------------------------
" Plugins
" -----------------------------------------------------------------------------------------------------------------
" Pathogen
"   Package manager
"   https://github.com/tpope/vim-pathogen
"Tells pathogen to open other packages
execute pathogen#infect()
call pathogen#helptags()

filetype plugin indent on "Allows plugins to control indent settings
                          "   ... but don't allow them to automatically add comments
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Vitality
"   Teachs iTerm2 and tmux to play well together
"url:   https://github.com/sjl/vitality.vim
let g:vitality_always_assume_iterm = 1 "Tells vitality I'm in iTerm2 even if ssh'd to another box

" Vim Multiple Cursors
"   Gives multi cursor support to vim (from Sublime text)
"url:   https://github.com/terryma/vim-multiple-cursors
let g:multi_cursor_exit_from_visual_mode = 0  "<Esc> exits visual mode, not multiple cursors
let g:multi_cursor_exit_from_insert_mode = 0  "<Esc> exits insert mode, not multiple cursors

" Vim Surround
"   Creates a set of commands for manipulating surround characters (html tags, quotes, parens)
"url:   https://github.com/tpope/vim-surround

" Vim Repeat
"   Allows other plugins to use . to repeat their functions
"url:   https://github.com/tpope/vim-repeat

" Dispatch
"   Asynchronous auto building
"url:   https://github.com/tpope/vim-dispatch.git

" Improved ft
"   Allows ft to work across multiple lines
"url:   https://github.com/chrisbra/improvedft

" Python Mode
"   Adds linting, auto-folding etc to python files
"url:   https://github.com/klen/python-mode
let g:pymode_lint_checkers = ["pyflakes","mccabe"]  "Python linters to run
let g:pymode_folding = 1                            "Enable python folding
let g:pymode_rope = 0                               "Disable rope

" Velocity
"   Gives velocity syntax support to vim
"url:   https://github.com/lepture/vim-velocity
autocmd BufRead,BufNewFile *.vm,*.html,*.htm,*.shtml set filetype=velocity  "Maybe necessary?
hi link velocityVar Special                                                 "Prefer this coloring for vars

" Dustjs
"   Gives dust syntax support to vim
"url:   https://github.com/jimmyhchan/dustjs.vim
let g:surround_{char2nr('d')} = "{\r}"    "Add {} as surround characters for Vim Surround

" Vim-less
"   Gives less syntax support to vim
"url:   https://github.com/groenewege/vim-less.git

" Lucius 
"   Colorscheme
"url:   https://github.com/jonathanfilip/vim-lucius
set t_Co=256          "Tell vim I have access to 256 colors
set background=light  "Tell vim I'm using a light background
colorscheme lucius    "Set colorscheme

" Vim-javascript
"   Improves javascript syntax support for vim
"url:   https://github.com/pangloss/vim-javascript.git

" Vim-jsx
"   Gives jsx syntax support to vim
"url:   https://github.com/mxw/vim-jsx.git

" -----------------------------------------------------------------------------------------------------------------
" Functions
" -----------------------------------------------------------------------------------------------------------------

"Asks for what comment to add
"   Proceeds to add the input text to the start of every line from mark a to current line
fun! AddComment()
  call inputsave()
  let output = input('Comment type:')
  call inputrestore()
  exec "'a,. s/^/".escape(output, '/')."/"
endfun

"Searches for the last search term used in terminal ack
"   Requires matching functon in ~/.bashrc
fun! AckSearchTerm()
  let shellcmd = "cat ~/.vim/acksearch"
  let output = system(shellcmd)
  let output = substitute(output, '\n$', '', '')
  exe 'let @/ ="'.output.'"'
endfun

"Allows for yanking into a file
"  Puts register 0 into ~/.vim/.paste
"  Puts the current register type (line, character, block) into ~/.vim/.pastetype
fun! CrossYank()
  let @g = getregtype()
  new ~/.vim/.paste
  %d
  $put 0
  0d
  x
  new ~/.vim/.pastetype
  %d
  $put g
  0d
  x
endfun

"Allows for pasting from a file
"  Pastes using pastecmd (p or P) the contents of ~/.vim/.paste
"  Uses the register type (character, line, block) from ~/.vim/.pastetype
fun! CrossPaste(pastecmd)
  :let @f = join(readfile(glob("~/.vim/.paste")), "\n")
  let regtype = system('cat ~/.vim/.pastetype')
  call setreg("f", getreg("f"), regtype)
  exe 'normal "f'.a:pastecmd
endfun
