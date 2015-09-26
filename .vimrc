set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'vim-less'
Plugin 'vim-autoclose'
Plugin 'flazz/vim-colorschemes'
Plugin 'mileszs/ack.vim'
Plugin 'pangloss/vim-javascript'
Plugin 'wavded/vim-stylus'
call vundle#end()

filetype plugin on

let current_filetype = &filetype

if current_filetype!='javascript'
    filetype plugin indent on
endif

fun! SetupVAM()
  let c = get(g:, 'vim_addon_manager', {})
  let g:vim_addon_manager = c
  let c.plugin_root_dir = expand('$HOME', 1) . '/.vim/vim-addons'
  " most used options you may want to use:
  " let c.log_to_buf = 1
  " let c.auto_install = 0
  let &rtp.=(empty(&rtp)?'':',').c.plugin_root_dir.'/vim-addon-manager'
  if !isdirectory(c.plugin_root_dir.'/vim-addon-manager/autoload')
    execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '
        \       shellescape(c.plugin_root_dir.'/vim-addon-manager', 1)
  endif
  call vam#ActivateAddons(['vim-snippets'], {'auto_install' : 0})
endfun

call SetupVAM()
VAMActivate matchit.zip vim-addon-commenting
ActivateAddons vim-snippets snipmate
"use <c-x><c-p> to complete plugin names

set nu
set autoindent
set tabstop=4
set softtabstop=4
set expandtab
set smartindent
set sw=4

set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1

set nobackup
set noswapfile
syntax on

"backspace
set nocp
set backspace=indent,eol,start

"highlight all search
set hlsearch

set ruler

set ignorecase
set smartcase
colorscheme greens
set mouse=nicr
set pastetoggle=<F2>

autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS

autocmd BufNewFile,BufReadPost *.styl set filetype=stylus

let g:AutoPairsShortcutFastWrap = '´' " <M-e>

" Find file in current directory and edit it.
function! Find(name)
let l:list=system("find . -type f | grep -i '".a:name."' | perl -ne 'print \"$.\\t$_\"'")
" let l:list=system("find . -iname '".a:name."' | perl -ne 'print \"$.\\t$_\"'")
" replace above line with below one for gvim on windows
" let l:list=system("find . -name ".a:name." | perl -ne \"print qq{$.\\t$_}\"")
  let l:num=strlen(substitute(l:list, "[^\n]", "", "g"))
  if l:num < 1
    echo "'".a:name."' not found"
    return
  endif
  if l:num != 1
    echo l:list
    let l:input=input("Which ? (CR=nothing)\n")
    if strlen(l:input)==0
      return
    endif
    if strlen(substitute(l:input, "[0-9]", "", "g"))>0
      echo "Not a number"
      return
    endif
    if l:input<1 || l:input>l:num
      echo "Out of range"
      return
    endif
    let l:line=matchstr("\n".l:list, "\n".l:input."\t[^\n]*")
  else
    let l:line=l:list
  endif
  let l:line=substitute(l:line, "^[^\t]*\t./", "", "")
  execute ":e ".l:line
endfunction
command! -nargs=1 Find :call Find("<args>")

:cabbrev find <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'Find' : 'find')<CR>
:cabbrev ack <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'Ack' : 'ack')<CR>
