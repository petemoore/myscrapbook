syntax on
colorscheme desert
set number
set tabstop=4
set hidden
execute pathogen#infect()
filetype plugin indent on
autocmd vimenter * if !argc() | NERDTree | endif
