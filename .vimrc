" Much of this vim config was inspired by:
" https://github.com/meiaalsup/anecdots

" `nocompatible` switches from the default Vi-compatibility mode and enables
" more useful Vim functionality. Not strictly necessary for ~/.vimrc, but needed
" if config loaded in other way
set nocompatible

" Turn on syntax highlighting.
syntax on

" Disable the default Vim startup message.
set shortmess+=I

" Show line numbers.
set number
" show line and column in status bar
set ruler

" set column marker at 80 characters
set colorcolumn=80

" Always show the status line at the bottom, even if you only have one window open.
set laststatus=2

" store extra :cmdline history
set history=1000

" Override backspace default (default doesn't word beyond insertion point set
" with 'i') to backspace over anything
set backspace=indent,eol,start

" Enable hidden buffers (not shown in any window)
set hidden

" Enable mouse support
set mouse+=a

" This setting makes search case-insensitive when all characters in the string
" being searched are lowercase. However, the search becomes case-sensitive if
" it contains any capital letters. This makes searching more convenient.
set ignorecase
set smartcase

" Enable searching as you type, rather than waiting till you press enter.
set incsearch

" Automatically update a file if it is changed externally
set autoread

" show mode in bottom
set showmode

" Cursor shape: block in normal mode, bar in insert mode
let &t_SI = "\e[6 q"  " Insert mode: bar
let &t_EI = "\e[2 q"  " Normal mode: block
let &t_SR = "\e[4 q"  " Replace mode: underline

" turn off swap files
set noswapfile
set nobackup
set nowb

" Persistent Undo: Keep undo history across sessions, by storing in file
if has('persistent_undo') && isdirectory(expand('~').'/.vim/backups')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" use 4 spaces instead of tabs during formatting
set autoindent
set tabstop=4
set shiftwidth=4
set softtabstop=0
set expandtab

" use 2 spaces for javascript and typescript
autocmd FileType typescript setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
autocmd FileType typescriptreact setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab

set nowrap "Don't wrap lines

" Disable audible bell because it's annoying.
set noerrorbells visualbell t_vb=

" make spacebar select word
map <space> viw

nnoremap <C-p> :set invpaste paste?<CR>
set pastetoggle=<C-p>

nnoremap <PageUp> <C-u>
nnoremap <PageDown> <C-d>

filetype plugin indent on " enable file type detection

""""""""""""""" Plugin Configuration """""""""""""""""
map <C-n> :NERDTreeToggle<CR>



call plug#begin('~/.vim/plugged')

" fuzzy find
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

" Add Coc (Conquer of Completion) for autocompletion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" syntastic
Plug 'vim-syntastic/syntastic'

" Syntax highlighting
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'sbdchd/neoformat'

call plug#end()

" In order for Neoformat to use a project-local version of Prettier (i.e. to
" use node_modules/.bin/prettier instead of looking for prettier on $PATH),
" you must set the neoformat_try_node_exe option:
" https://prettier.io/docs/en/vim.html
" let g:neoformat_try_node_exe = 1
" autocmd BufWritePre *.ts Prettier
" let g:vim_jsx_pretty_colorful_config = 1 " default 0

colorscheme desert

" color picker:
" https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
augroup MyColors
  autocmd!
  autocmd ColorScheme * highlight Error term=NONE cterm=NONE ctermfg=252 ctermbg=089 guifg=#d0d0d0 guibg=#87005f
        \ | highlight SpellBad ctermfg=252 ctermbg=089 guifg=#d0d0d0 guibg=#87005f
        \ | highlight SpellCap ctermfg=252 ctermbg=059 guifg=#d0d0d0 guibg=#5f5f5f
        \ | highlight link SpellBad SyntasticCheck
        \ | highlight link SpellCap SyntasticWarning

augroup END
map <silent> <C-f> :BLines<CR>
map <silent> <C-n> :FZF!<CR>


" set up json to be viewable with longer text strings wrapped to 80 characters.
autocmd FileType json setlocal wrap
autocmd FileType json setlocal linebreak
autocmd FileType json setlocal textwidth=80
autocmd FileType json setlocal formatoptions-=t
autocmd FileType json setlocal formatoptions-=c
autocmd FileType json setlocal formatoptions-=r
autocmd FileType json setlocal formatoptions-=o

" status line config from //shapeshed.com/vim-statuslines/
set statusline=
" status line color options - run :so $VIMRUNTIME/syntax/hitest.vim
"set statusline+=%#StatusLine#                               " colorscheme
set statusline+=\ %.40f                                 " File name (truncated)
set statusline+=%m
set statusline+=%=
set statusline+=\ %y                                        " File type
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}  " File encoding
"set statusline+=\[%{&fileformat}\]                         " File format
set statusline+=\ %p%%                                      " % through file
set statusline+=\ %l/                                       " line num
set statusline+=%L                                          " total lines
set statusline+=\

""""" syntastic settings
" " config syntastic status line
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 0
"let g:syntastic_check_on_wq = 0

"" configure height of initial syntastic error bar
"let g:syntastic_loc_list_height=5
"
"" syntastic off by default
"let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [],'passive_filetypes': [] }
"let g:syntastic_sh_checkers = ['shellcheck']
"let g:syntastic_cpp_checkers = ['cpplint']
"let g:syntastic_go_checkers = ['go']
"let g:syntastic_javascript_checkers=['eslint']
"let g:syntastic_typescript_checkers=['eslint']
"nnoremap <C-w>E :SyntasticCheck<CR>
"nnoremap <C-w>R :SyntasticReset<CR>

" Setup coc.nvim
let g:coc_global_extensions = [
  \ 'coc-json',
  \ 'coc-tsserver',
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-pyright',
  \ 'coc-sh',
  \ ]

" Use tab for trigger completion with characters ahead and navigate
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" Setup ESLint and Prettier for JavaScript/TypeScript
autocmd FileType javascript,javascriptreact,typescript,typescriptreact setlocal formatexpr=CocAction('formatSelected') formatoptions+=ro

" Enable CocAction for formatting Python
autocmd FileType python setlocal formatexpr=CocAction('formatSelected') formatoptions+=ro

" Format on save using CocAction for JavaScript/TypeScript and Python
"autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx,*.py CocActionAsync('runCommand', 'editor.action.format')
augroup myformat
      autocmd!
        autocmd BufWritePre *.ts,*.tsx,*.js,*.jsx,*.py :CocCommand prettier.formatFile
augroup END

" Setup shellcheck for shell scripts
let g:coc_filetype_map = {'sh': 'shellscript'}


" local customizations in ~/.vimrc_local
let $LOCALFILE=expand("~/.vimrc_local")
if filereadable($LOCALFILE)
    source $LOCALFILE
    endif
