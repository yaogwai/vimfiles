" Switched to Windows

set sw=2
set expandtab
set nojoinspaces
set showcmd
set noshowmode
set hidden
set splitbelow splitright
set previewheight=30
set ignorecase smartcase infercase
set wildignorecase
set gdefault
set clipboard=unnamed
set wildignore+=.DS_Store,*.swp,*.retry,*.map,*/.git/*,*/tags
" pain in the ass
set noswapfile
set fileformats=unix,dos
" setting this fixes alt mappings on Windows
set encoding=utf-8
" set termguicolors
" XXX only available in nvim
" set inccommand=split
let &grepprg = "pt /nocolor /nogroup"


call plug#begin(expand('<sfile>:h') . '/plugged')
" disable for nvim
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-projectionist'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-function'
Plug 'sheerun/vim-polyglot'
Plug 'neomake/neomake'
Plug 'easymotion/vim-easymotion'
Plug 'itchyny/lightline.vim'
Plug 'tomtom/tcomment_vim'
Plug 'godlygeek/tabular'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'garbas/vim-snipmate'
Plug 'honza/vim-snippets'
Plug 'jiangmiao/auto-pairs'
Plug 'vim-scripts/ReplaceWithRegister'
Plug 'ludovicchabant/vim-gutentags'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'ervandew/supertab'
Plug 'skywind3000/asyncrun.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'andyl/vim-textobj-elixir', { 'for': 'elixir' }
Plug 'slashmili/alchemist.vim', { 'for': 'elixir' }
Plug 'shawncplus/phpcomplete.vim', { 'for': 'php' }
Plug 'mattn/emmet-vim'
call plug#end()

let $http_proxy = 'http://localhost:1080'
let $https_proxy = 'http://localhost:1080'
let mapleader = ' '
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'
let g:EasyMotion_smartcase = 1
let g:SuperTabDefaultCompletionType = "context"

" i in normal mode starts insert at indent position instead of the first
" column when current line is empty
" XXX: taints the buffer
fun! s:insertIndent()
  if line('.') != 1 && getline('.') =~ '\v^\s*$'
    exe "normal! 0Dia \<esc>==xl"
  endif
  startinsert
endfun
nnoremap <silent> i :call <SID>insertIndent()<cr>

fun! s:stripTrailingWhitespace()
  let l:winview = winsaveview()
  %s/\v\s+$//e
  call winrestview(l:winview)
endfun

" Project directory if current file in a project, otherwise the directory
" containing the file
fun! s:projectDir()
  let path = projectionist#path('')
  if empty(path) || path == '.'
    let path = expand('%:h')
  endif
  " pain in the ass caused by Windows style path names
  return split(path, '\v\\+$')[0]
endfun

let s:quickfix_is_open = 0
fun! s:quickfixToggle()
  if s:quickfix_is_open
    cclose
    let s:quickfix_is_open = 0
    execute s:quickfix_return_to_win . "wincmd w"
  else
    let s:quickfix_return_to_win = winnr()
    copen
    let s:quickfix_is_open = 1
  endif
endfun
nnoremap <silent> <leader>q :call <SID>quickfixToggle()<cr>

augroup Quickfix
  au!
  au FileType qf nnoremap <buffer> <silent> q :cclose<cr>
augroup END

fun! s:grepOperator(type)
  let saved_reg = @@
  if a:type ==# 'v'
    silent normal! gvy
  elseif a:type ==# 'char'
    silent normal! `[v`]y
  else
    return
  endif
  silent execute "grep! " . @@ . " " . shellescape(s:projectDir())
  copen 30
  let @@ = saved_reg
endfun
nnoremap <silent> <leader>g :set operatorfunc=<SID>grepOperator<cr>g@
vnoremap <silent> <leader>g :<c-u>call <SID>grepOperator(visualmode())<cr>
nnoremap <silent> <leader>G :silent execute "grep! " . expand('<cword>') . " " . shellescape(<SID>projectDir())<bar>copen 30<cr>

augroup ReloadRC
  au!
  au BufWritePost $MYVIMRC source $MYVIMRC
augroup END

augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END

augroup Main
  au!
  au BufWritePost * Neomake
  au BufWritePre * call s:stripTrailingWhitespace()
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"zz" | endif
  au BufNewFile,BufRead *.m set filetype=objc
  au FileType eelixir EmmetInstall
augroup END

augroup Filetypes
  au!
  au FileType help wincmd L
  au FileType vim setlocal keywordprg=:help
  au FileType markdown,text setlocal spell spelllang=en_us
  au FileType help,man nnoremap <buffer> <cr> <C-]>
        \ | nnoremap <buffer> q :bunload<cr>
        \ | nnoremap <buffer> f <c-f>
        \ | nnoremap <buffer> <nowait> d <c-b>
        \ | nnoremap <buffer> j <c-e>
        \ | nnoremap <buffer> k <c-y>
  au FileType autohotkey call setbufvar('%', "&makeprg", '"C:\Program Files\AutoHotkey\AutoHotkey.exe" %')
augroup END

augroup AutoInsert
  au!
  au BufNewFile *.php exe "normal! i<?php\<cr>\<cr>"
augroup END

nmap <leader>l <Plug>(easymotion-bd-jk)
nmap <leader>f <Plug>(easymotion-bd-w)
nmap <leader>w <Plug>(easymotion-bd-f)
" writes when changed
nnoremap <silent> <c-s> :update<cr>

inoremap <C-U> <C-G>u<C-U>
inoremap <c-a> <esc>^i
inoremap <c-e> <esc>A
inoremap <c-k> <esc>lDa
inoremap <c-l> <c-x><c-o>
noremap! <c-v> <c-r>*

" c-p/n differ from up/down in that they don't filter history
cnoremap <c-p> <up>
cnoremap <c-n> <down>
cnoremap <c-a> <home>
cnoremap <c-f> <right>
" brings up the command line window, preserving commnd line content
cnoremap <c-j> <c-f>
cnoremap <c-b> <left>
noremap! <m-b> <s-left>
noremap! <m-f> <s-right>

fun! s:dashWord()
   silent! exe "!start cmd /c " . "start dash-plugin://query=" . expand('<cword>')
endfun
nnoremap <silent> <m-d> :call <SID>dashWord()<cr>

fun! s:ctrlp()
  call ctrlp#init(0, { 'dir': s:projectDir() })
endfun
let g:ctrlp_map = '<nop>'
let g:ctrlp_match_window = 'bottom,order:ttb,min:3,max:23'
let g:ctrlp_use_caching = 0
let g:ctrlp_user_command = 'pt /nocolor /nogroup /l /g "" %s'
nnoremap <silent> <c-p> :call <SID>ctrlp()<cr>
nnoremap <silent> <m-r> :CtrlPMRUFiles<cr>
nnoremap <silent> <m-e> :CtrlPBuffer<cr>
nnoremap <silent> <m-g> :Gstatus<cr>

" Q now opens ex mode, is it ever useful?
" q: still opens cmdline history window, which I suppose can sometimes be
" useful, but a lot of times I wanted to press :q
" More useful is q/ and q?, which bring up the search history
nnoremap Q gq

let g:lightline = {
      \ 'component': {
      \   'lineinfo': ' %3l:%-2v',
      \ },
      \ 'component_function': {
      \   'readonly': 'LightlineReadonly',
      \   'fugitive': 'LightlineFugitive'
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }
function! LightlineReadonly()
  return &readonly ? '' : ''
endfunction
function! LightlineFugitive()
  if exists('*fugitive#head')
    let branch = fugitive#head()
    return branch !=# '' ? ''.branch : ''
  endif
  return ''
endfunction

iabbrev hte the

if has('win32')
set renderoptions=type:directx
  cd ~
endif

colorscheme seti
