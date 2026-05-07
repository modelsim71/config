"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author   : dx
" Version  : v0.1
" Blog     :
" Mail     :
" Date     : 2014-12-16
"
" Setions  :  ->General
"             ->VIM user interface
"             ->Colors and Fonts
"             ->Files and Backups
"             ->Text, tab and indent
"             ->Staus line
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Set how many lines of history VIM has to remember
set history=1000

" Line number
set number
set rnu

" 设置匹配模式，输入左括号会出现右括号
set showmatch

" Enable filetype plugins
filetype on
filetype plugin on
filetype indent on

" 编辑时显示光标状态
set ruler

" Set mapleader
let mapleader = ","
" Fast reload .vimrc
map <silent> <leader>ss : source ~/.vimrc<cr>
" Fast edit .vimrc
map <silent> <leader>ee :e ~/.vimrc<cr>
" when .vimrc is edited, reload it
autocmd! bufwritepost .vimrc source ~/.vimrc

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Color scheme
colorscheme desert
set background=light

" Enable syntax highlighting
syntax enable
syntax on
hi search term=reverse ctermbg=1 guibg=DarkRed

" utf-8 encoding
set encoding=utf8

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> Files, backups
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nobackup

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> Text, tab and indent
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 1 tab == 4 spaces
set tabstop=4
set softtabstop=4

" 移动整行内容时，一次移动的字宽度
set shiftwidth=4

" Use spaces instead of tab
set noexpandtab

" Be smart when using tabs
set smarttab

" Auto indent
set autoindent

" smart indent mode
set smartindent

" 空白或者标点处折行
set lbr

" Linebreak on 500 characters
set tw=500

" screen wrap, don't insert EOL
set wrap

" C indent
set cindent

"hight
set hlsearch

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> Status line
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> Vim Plug Manager 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"call plug#begin('~/.vim/plugged')
" Shorthand notation for plugin
"Plug 'vim-airline/vim-airline'
"call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> bundle Plug Manager
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'lilydjwg/colorizer'
Plug 'kshenoy/vim-signature'
Plug 'jiangmiao/auto-pairs'
Plug 'preservim/NERDTree'
Plug 'fholgado/minibufexpl.vim'
Plug 'vim-scripts/grep.vim'
Plug 'vim-scripts/comments.vim'
Plug 'vim-scripts/indentpython.vim'
Plug 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Plug 'rust-lang/rust.vim'
Plug 'dense-analysis/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'autozimu/LanguageClient-neovim', {
"    \ 'branch': 'next',
"    \ 'do': 'bash install.sh',
"    \ }
Plug 'junegunn/fzf'
"Plug 'vim-scripts/supertab'
"Plug 'Valloric/YouCompleteMe'
"Plug 'vim-scripts/OmniCppComplete'
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> pythone language
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=119 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

highlight BadWhitespace ctermbg=red guibg=DarkRed
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> javascript language
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.js, *.html, *.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> Coc setting 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

let g:LanguageClient_serverCommands = {
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
    \ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
    \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
    \ 'python': ['/usr/local/bin/pyls'],
    \ 'ruby': ['~/.rbenv/shims/solargraph', 'stdio'],
    \ }

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? "\<C-p>" : "\<C-h>"

inoremap <silent><expr> <cr> coc#pum#visible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nnoremap <silent> <LEADER>h :call <SID>show_documentation()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> rust language
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:rustfmt_autosave = 1
let g:rustfmt_command = "rustfmt" 
let g:rust_clip_command = 'xclip -selection clipboard'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> ALE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let g:LanguageClient_serverCommands = {
"\ 'rust': ['rust-analyzer'],
"\ }
let g:ale_linters = {
\   'rust': ['cargo', 'clippy'],
\}
let g:ale_fixers = {
\   'rust': ['cargo', 'rustfmt'],
\}
let g:ale_rust_cargo_use_clippy = 1
let g:airline#extensions#ale#enabled = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> NerdTree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeGlyphReadOnly = "RO"
let g:NERDTreeDirArrows = 1
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:NERDTreeGlyphReadOnly = "RO"
let g:NERDTreeNodeDelimiter = "\u00a0"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> Window Manager
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let winManagerWindowLayout = "NERDTree|TagList"

"设置win窗口宽度
let winManagerWidth=30

"不同时显示多个文件的tag，只显示当前文件的tag
let Tlist_Show_One_File=1

"如果taglist是最后一个窗口,则退出vim
let Tlist_Exit_OnlyWindow=1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> supertab plugin setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let g:SuperTabRetainCompletionType = 2
"let g:SuperTabDefaultCompletionType = "<C-X><C-O>"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> yourcomplet plugin setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let g:ycm_autoclose_preview_window_after_completion=1
"map <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> OmniCppComplete plugin setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"set nocp
"set completeopt=menu,longest,menuone "关掉只能补全时的预览窗口
"let OmniCpp_MayCompleteDot = 1 "autocomplete with .
"let OmniCpp_MayCompleteArrow = 1 "autocomplete with ->
"let OmniCpp_MayCompleteScope = 1 "autocomplete with ::
"let OmniCpp_SelectFirstItem = 2 "search namespace in this and include files
"let OmniCpp_ShowPrototypeInAbbt = 1 "show function prototype in popup window
"let OmniCpp_GlobalScopeSearch = 1 "enable the global scope search
"let OmniCpp_DisplayMode = 1 "Class scope completion mode : always show all members
"let OmniCpp_DefaultNamespaces = ["std","_GLIBCXX_STD"]
"let OmniCpp_ShowScopeInAbbt = 1 "show scope in abbreviation and remove the last column
"let OmniCpp_ShowAccess = 1
"let OmniCpp_NamespaceSearch = 2
"let OmniCpp_LocalSearchDecl = 1 " use local search function, bracket on 1st column
"let OmniCpp_DisplayMode = 1
"au BufNewFile,BufRead,BufEnter *.cpp,*.hpp set omnifunc=omni#cpp#complete#Main
"au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> cscope plugin setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set cscopequickfix=s-,c-,d-,i-,t-,e-
if has("cscope")
set csprg=/usr/bin/cscope
set csto=0
set cst
set nocsverb
set cspc=0
if filereadable("cscope.out")
    cs add cscope.out
elseif $CSCOPE_DB != ""
    cs add $CSCOPE_DB
endif
endif

nmap <C-a>s : cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-a>g : cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-a>c : cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-a>t : cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-a>f : cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-a>i : cs find i <C-R>=expand("<cfile>")<CR><CR>
nmap <C-a>d : cs find d <C-R>=expand("<cfile>")<CR><CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> ctsgs plugin setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tags=tags

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ====> F快捷键定义
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"按下F3自动补全代码，注意该映射语句后不能有其它字符，否则
"按下F3后自动补全一些乱码
imap <F3> <C-X><C-I>

"定义打开winmanager快捷键为F4
nmap <silent> <F4> : WMToggle<cr>

"按下F5重新生成tag文件，并更新taglist
map <F5> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q <CR><ESC>
imap <F5><ESC> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q <CR><ESC>


