set nu
set enc=utf-8
set cindent
"set cindent
set shiftwidth=2
set tabstop=2
"autocmd FileType c,cpp set shiftwidth=4 | set expandtab
"set showcmd         " 输入的命令显示出来，看的清楚些
"set magic
set bg=dark
set noeb " 去掉输入错误的提示声音"
set cursorline              " 突出显示当前行"
set nocompatible              " 这是必需的
filetype off                  " 这是必需的

syntax on
syntax enable
colorscheme gruvbox
filetype plugin on
" 你在此设置运行时路径
set rtp+=~/.vim/bundle/Vundle.vim
	" vundle初始化
call vundle#begin()
	" 这应该始终是第一个
	Plugin 'gmarik/Vundle.vim'
	" 该例子来自https://github.com/gmarik/Vundle.vim README
	Plugin 'tpope/vim-fugitive'
	Plugin 'scrooloose/nerdtree'
	Plugin 'DoxygenToolkit.vim'
	Plugin 'taglist.vim'
	Plugin 'Valloric/YouCompleteMe'
	Plugin 'scrooloose/nerdcommenter'
	Plugin 'bling/vim-airline'
	Plugin 'vim-airline/vim-airline-themes'
	Plugin 'morhetz/gruvbox'
	Plugin 'Raimondi/delimitMate'
	Plugin 'Chiel92/vim-autoformat'
	call vundle#end()            " required

	" 关闭NERDTree快捷键
	noremap <leader>t :NERDTreeToggle<CR>
	"map <C-n> :NERDTreeToggle<CR>
	" 显示行号
	let NERDTreeShowLineNumbers=1
	let NERDTreeAutoCenter=1
	" 是否显示隐藏文件
	let NERDTreeShowHidden=1
	" 设置宽度
	let NERDTreeWinSize=30
	" 在终端启动vim时，共享NERDTree
	let g:nerdtree_tabs_open_on_console_startup=1
	" 忽略一下文件的显示
	let NERDTreeIgnore=['\.pyc','\~$','\.swp']
	" 显示书签列表
	let NERDTreeShowBookmarks=1

	" vim不指定具体文件打开是，自动使用nerdtree
	" autocmd StdinReadPre * let s:std_in=1
	"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree |endif
	" 当vim打开一个目录时，nerdtree自动使用
	" autocmd StdinReadPre * let s:std_in=1
	" autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) &&
	"!exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

	" 当vim中没有其他文件，值剩下nerdtree的时候，自动关闭窗口
	autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif



	" 改变nerdtree的箭头


	let Tlist_Ctags_Cmd='ctags'
	let Tlist_Show_One_File=1               "不同时显示多个文件的tag，只显示当前文件的
	let Tlist_WinWidt =28                   "设置taglist的宽度
	let Tlist_Exit_OnlyWindow=1             "如果taglist窗口是最后一个窗口，则退出vim
	let Tlist_Use_Right_Window=1           "在右侧窗口中显示taglist窗口
	"let Tlist_Use_Left_Windo =1
	noremap <leader>l :Tlist<CR>
	let g:DoxygenToolkit_briefTag_funcName = "yes"
	" for C++ style, change the '@' to '\'
	let g:DoxygenToolkit_commentType = "C++"
	let g:DoxygenToolkit_briefTag_pre = "\\brief "
	let g:DoxygenToolkit_templateParamTag_pre = "\\tparam "
	let g:DoxygenToolkit_paramTag_pre = "\\param "
	let g:DoxygenToolkit_returnTag = "\\return "
	let g:DoxygenToolkit_throwTag_pre = "\\throw " " @exception is also valid
	let g:DoxygenToolkit_fileTag = "\\file "
	let g:DoxygenToolkit_dateTag = "\\date "
	let g:DoxygenToolkit_authorTag = "\\author "
	let g:DoxygenToolkit_versionTag = "\\version "
	let g:DoxygenToolkit_blockTag = "\\name "
	let g:DoxygenToolkit_classTag = "\\class "
	let g:DoxygenToolkit_authorName = "suntangji, suntangj2016@gmail.com"
	let g:doxygen_enhanced_color = 1
	"let g:load_doxygen_syntax = 1
	nmap <F4> :DoxAuthor<cr>


	" 自动补全配置
	let g:ycm_global_ycm_extra_conf='~/.ycm_extra_conf.py'  "设置全局配置文件的路径
	let g:ycm_seed_identifiers_with_syntax=1    " 语法关键字补全
	let g:ycm_confirm_extra_conf=0  " 打开vim时不再询问是否加载ycm_extra_conf.py配置
	let g:ycm_key_invoke_completion = '<C-a>' " ctrl + a 触发补全
	set completeopt=longest,menu    "让Vim的补全菜单行为与一般IDE一致(参考VimTip1228)
	autocmd InsertLeave * if pumvisible() == 0|pclose|endif "离开插入模式后自动关闭预览窗口
	inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"    "回车即选中当前项
	"上下左右键的行为 会显示其他信息
	inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
	inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
	inoremap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
	inoremap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"

	"youcompleteme  默认tab  s-tab 和自动补全冲突
	"let g:ycm_key_list_select_completion=['<c-n>']
	let g:ycm_key_list_select_completion = ['<Down>']
	"let g:ycm_key_list_previous_completion=['<c-p>']
	let g:ycm_key_list_previous_completion = ['<Up>']
	let g:ycm_confirm_extra_conf=0 "关闭加载.ycm_extra_conf.py提示
	let g:ycm_collect_identifiers_from_tags_files=1 " 开启 YCM 基于标签引擎
	let g:ycm_min_num_of_chars_for_completion=2 " 从第2个键入字符就开始罗列匹配项
	let g:ycm_cache_omnifunc=0  " 禁止缓存匹配项,每次都重新生成匹配项
	"let g:ycm_seed_identifiers_with_syntax=1    " 语法关键字补全
	"nnoremap <F5> :YcmForceCompileAndDiagnostics<CR>    "force recomile with syntastic
	"nnoremap <leader>lo :lopen<CR> "open locationlist
	"nnoremap <leader>lc :lclose<CR>    "close locationlist
	"inoremap <leader><leader> <C-x><C-o>
	let g:ycm_error_symbol = '>>'
	let g:ycm_warning_symbol = '>*'
	"在注释输入中也能补全
	let g:ycm_complete_in_comments = 1
	"在字符串输入中也能补全
	let g:ycm_complete_in_strings = 1
	"注释和字符串中的文字也会被收入补全
	let g:ycm_collect_identifiers_from_comments_and_strings = 0

	nnoremap <leader>jd :YcmCompleter GoToDefinitionElseDeclaration<CR> " 跳转到定义处

	let g:airline_theme="luna"
	"这个是安装字体后 必须设置此项"
	"let g:airline_theme="kolor"
	let g:airline_powerline_fonts = 1
	set laststatus=2  "永远显示状态栏
	set t_Co=256      "在windows中用xshell连接打开vim可以显示色彩
	"打开tabline功能,方便查看Buffer和切换，这个功能比较不错"
	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#tabline#buffer_nr_show = 1

	"设置切换Buffer快捷键"
	nnoremap <C-N> :bn<CR>
	nnoremap <C-P> :bp<CR>

	" 关闭状态显示空白符号计数,这个对我用处不大"
	let g:airline#extensions#whitespace#enabled = 0
	let g:airline#extensions#whitespace#symbol = '!'
	" unicode symbols
	let g:airline_left_sep = '»'
	let g:airline_left_sep = '▶'
	let g:airline_right_sep = '«'
	let g:airline_right_sep = '◀'

	noremap <F3> :Autoformat<CR>
	let g:autoformat_verbosemode=0
	"保存时自动格式化代码，针对所有支持的文件
	"au BufWrite * :Autoformat
	""保存时自动格式化PHP代码
	"au BufWrite *.php :Autoformat
	"<!-- 指定html格式化工具，并设置缩进为两个空格 -->
	"let g:formatdef_my_html = '"html-beautify -s 2"'
	"let g:formatters_html = ['my_html']
	"let g:formatdef_my_c = 'astyle --mode=c --style=google'
	let g:formatdef_my_cpp = '"astyle --mode=c --style=google --indent=spaces=2 --convert-tabs -v"'
	let g:formatters_c = ['my_cpp']
	let g:formatters_cpp = ['my_cpp']
	map <F5> :call CompileRunGcc()<CR>
func! CompileRunGcc()
	exec "w"
	if &filetype == 'c'
	exec "!gcc % -o %<"
	exec "! ./%<"
	elseif &filetype == 'cpp'
	exec "!g++ % -o %<"
	exec "! ./%<"
	elseif &filetype == 'java'
	exec "!javac %"
	exec "!java %<"
	elseif &filetype == 'sh'
	:!./%
	endif
	endfunc
	"paste热键
	set pastetoggle =<F9>
	vmap <c-c> "+y
	" for python docstring ", 特别有用
	au FileType python let b:delimitMate_nesting_quotes = ['"']
	" 关闭某些类型文件的自动补全
	"au FileType mail let b:delimitMate_autoclose = 0
