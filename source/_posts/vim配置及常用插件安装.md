---
title: vim配置及常见插件安装
date: 2017-11-21 21:30:04
tags: 随笔
category: linux
---
### 前言
作为一个程序员，一个常用的工具就是编辑器，常用的编辑器有Sublime Text、Emacs、Vim、Source Insight、Atom、TextMate.
<!--more-->
#### 引用知乎大佬[刘尚奇](https://www.zhihu.com/question/21376577/answer/32617207)的言论

> 中国范围，08年以前Vim和Emacs认知度较低，两基友相爱相杀，流行度不相上下；此后Vim一跃领先，在11年后以压倒性优势成为最流行的editor；Emacs份额也稳中有升，并在12年后迎来更广的认知度和流行度；Sublime Text的趋势跟Worldwide相似但略有delay，流行度在13年超越Emacs；TextMate一直作为小众的存在，从Sublime Text诞生起就被超越。




可以看出vim仍是目前的主流编辑器，它流行的一个主要原因就是可扩展。配上各种插件就可以实现非常炫酷的功能。
### 本人的环境
系统：Centos7.0 
vim版本：8.0

### 插件列表
- Vundle
管理vim插件的插件 ，其特色在于使用git来管理插件,更新方便。
- Nerdtree
树形目录插件，可以方便查看目录
- DoxygenToolkit
用它可以很方便地添加 Doxygen 风格的注释，可以节省大量时间和精力，提高写代码的效率。
- Taglist
TagList插件是一款基于ctags，在vim代码窗口旁以分割窗口形式显示当前的代码结构概览，增加代码浏览的便利程度的vim插件。
- nerdcommenter
快速注释插件，可以很方便的注释代码
- vim-airline
状态栏美化插件
- YouCompleteMe
代码自动补全插件

### 最终效果
![](http://img.blog.csdn.net/20171120110228097?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvcXFfMzk1MjY1MDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

### 1. 安装/升级Vim
基本所有的操作系统都会内置vim,但是YouCompleteMe插件要求vim版本7.4以上，所以我升级到了vim8.0，centos的包管理工具没有8.0的版本，需要进行手动编译安装。若vim版本大于7.4可忽略本步。
```bash
sudo yum install ncurses-devel 
wget https://github.com/vim/vim/archive/master.zip
unzip master.zip
cd vim-master
cd src/
./configure 
sudo make
sudo make install
export PATH=/usr/local/bin:$PATH
vim --version
```

### 2. 安装Vundle
若没有安装git
```bash
sudo yum install -y git
```
下载vundle
```bash
mkdir ~/.vim/bundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```
打开配置文件
```bash
vim ~/.vimrc
```
添加以下代码
```vim
set nocompatible              " 去除VI一致性,必须要添加
filetype off                  " 必须要添加

" 设置包括vundle和初始化相关的runtime path
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" 另一种选择, 指定一个vundle安装插件的路径
"call vundle#begin('~/some/path/here')

" 让vundle管理插件版本,必须
Plugin 'VundleVim/Vundle.vim'

" 以下范例用来支持不同格式的插件安装.
" 请将安装插件的命令放在vundle#begin和vundle#end之间.
" Github上的插件
" 格式为 Plugin '用户名/插件仓库名'
Plugin 'tpope/vim-fugitive'
" 来自 http://vim-scripts.org/vim/scripts.html 的插件
" Plugin '插件名称' 实际上是 Plugin 'vim-scripts/插件仓库名' 只是此处的用户名可以省略
Plugin 'L9'
" 由Git支持但不再github上的插件仓库 Plugin 'git clone 后面的地址'
Plugin 'git://git.wincent.com/command-t.git'
" 本地的Git仓库(例如自己的插件) Plugin 'file:///+本地插件仓库绝对路径'
Plugin 'file:///home/gmarik/path/to/plugin'
" 插件在仓库的子目录中.
" 正确指定路径用以设置runtimepath. 以下范例插件在sparkup/vim目录下
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" 安装L9，如果已经安装过这个插件，可利用以下格式避免命名冲突
Plugin 'ascenator/L9', {'name': 'newL9'}

" 你的所有插件需要在下面这行之前
call vundle#end()            " 必须
filetype plugin indent on    " 必须 加载vim自带和插件相应的语法和文件类型相关脚本
" 忽视插件改变缩进,可以使用以下替代:
"filetype plugin on
```
用vim打开一个新的文件，执行
```vim
:PluginInstall
```
显式Done后安装完毕
### 3. 安装 Nerdtree
打开vim的配置文件
```shell
vim ~/.vimrc
```
添加代码Plugin 'scrooloose/nerdtree'在这行之前
```vim
" 你的所有插件需要在下面这行之前
call vundle#end()            " 必须
```
添加后
```vim 
Plugin 'scrooloose/nerdtree'
" 你的所有插件需要在下面这行之前
call vundle#end()            " 必须
```
在vim中执行
```vim
:PluginInstall
```
在配置文件中添加以下代码
```vim
map <leader>t :NERDTreeToggle<CR>
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
```
### 4. 安装DoxygenToolkit
在vim配置文件中call vundle#end() 之前添加
```vim
Plugin 'DoxygenToolkit.vim'
```
在call vundle#end() 之后添加
```vim
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
let g:DoxygenToolkit_authorName = "suntangji, suntangj2016i@gmail.com"
let g:doxygen_enhanced_color = 1
"let g:load_doxygen_syntax = 1
nmap <F4> :DoxAuthor<cr>
```
在vim中执行
```vim
:PluginInstall
```
### 5. 安装Taglist
taglist依赖ctags,需要进行安装
```bash
sudo yum install -y ctags
```
在vim配置文件中call vundle#end() 之前添加
```vim
Plugin 'taglist.vim'
```
在call vundle#end() 之后添加
```vim
let Tlist_Ctags_Cmd='ctags'
let Tlist_Show_One_File=1           "不同时显示多个文件的tag，只显示当前文件的
let Tlist_WinWidt =28               "设置taglist的宽度
let Tlist_Exit_OnlyWindow=1         "如果taglist窗口是最后一个窗口，则退出vim
let Tlist_Use_Right_Window=1        "在右侧窗口中显示taglist窗口
"let Tlist_Use_Left_Windo =1
map <leader>l :Tlist<CR>
```
在vim中执行
```vim
:PluginInstall
```
### 6. 安装nerdcommenter
在vim配置文件中call vundle#end() 之前添加
```vim
Plugin 'scrooloose/nerdcommenter'
```
在vim中执行
```vim
:PluginInstall
```
### 7. 安装vim-airline
在vim配置文件中call vundle#end() 之前添加
```vim
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
```
在call vundle#end() 之后添加
```vim
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
```
在vim中执行
```vim
:PluginInstall
```
初次安装以后打开Vim，若发现状态栏会出现乱码，这时有两种解决方案，一种是安装[powerline](https://github.com/powerline/fonts)字体或者[Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)实现字体显示，另一种是用unicode字符替代，对于第一种方案，字体的安装请参考github相应主页上的说明

### 8. 安装YouCompleteMe
该插件需要手动编译
首先安装依赖
```bash
sudo yum install -y python-dev python3-dev gcc cmake 
```
#### 方式一 通过Vundle下载源码（不推荐）
该方式下载时间较长，不会进行仓库完备性检查
在vim配置文件中call vundle#end() 之前添加
```vim
Plugin 'Valloric/YouCompleteMe'
```
在vim中执行
```vim
:PluginInstall
```
#### 方式二 通过git 下载源码
```bash
git clone https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundle/YouCompleteMe
git submodule update --init --recursive
```
进行编译
```bash
cd ~/.vim/bundle/YouCompleteMe
sudo ./install.py --clang-completer

```
安装完成后将.yum_extra_conf.py复制一份到 ~/
```bash
cp ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py ~/
```
打开.yum_extra_conf.py，在flags中添加以下代码
```py
'-isystem',
'/usr/include',
'-isystem',
'/usr/include/c++/',
'-isystem',
'/usr/include/i386-linux-gnu/c++'
```
把flags中‘home/xxx'更改为'home/你的用户名'
打开配置文件.vimrc添加
```vim
let g:ycm_global_ycm_extra_conf='~/.ycm_extra_conf.py'  "设置全局配置文件的路径
let g:ycm_seed_identifiers_with_syntax=1    " 语法关键字补全
let g:ycm_confirm_extra_conf=0  " 打开vim时不再询问是否加载ycm_extra_conf.py配置
let g:ycm_key_invoke_completion = '<C-a>' " ctrl + a 触发补全
set completeopt=longest,menu    "让Vim的补全菜单行为与一般IDE一致(参考VimTip1228)
```
至此，大功告成！