---
title: Git/Github入门指南
date: 2018-03-17 20:54:38
tags: 学习笔记
category: Other
---
学会使用Git/Github的正确姿势
<!--more-->
### 什么是版本控制
> 版本控制（Version control）是能让你了解到一个文件的历史，以及它的发展过程的系统。

#### 常见的版本控制系统
 - Git
 - SVN

#### Git与SVN的区别
- Git是分布式
- SVN是集中式
- Git代码管理更出色，SVN文档管理更好用

#### 什么是Github
> gitHub是一个面向开源及私有软件项目的托管平台，因为只支持git 作为唯一的版本库格式进行托管，故名gitHub。

#### 安装Git
Debian系列
```
sudo apt-get install -y git
```
Redhat系列
```
sudo yum install -y git
```
Windows/Mac OS
下载安装包[https://git-scm.com/download/](https://git-scm.com/download/)

#### 配置Git
```
$ git config --global user.name "Your Name"
$ git config --global user.email "email@example.com"
```
#### 创建版本库
```
$ git init
```
#### 提交文件到缓冲区
```
$ touch README.md
$ git add .
```
#### 提交文件到版本库
```
$ git commit -m "your commit"
```
#### 查看版本库状态
```
$ git status
```
#### 比较文件差异
```
$ git diff
```
#### 版本回退
```
$ git reset --hard HEAD^
```
#### 排除不需要的文档
```
$ touch .gitignore
```
在 .gitignore文件中写入不需要的文件名
#### 同步到Github远程仓库
你需要有一个Github账号
##### 创建SSH Key
``` 
$ ssh-keygen -t rsa -C "youremail@example.com"
```
一路回车使用默认值即可
然后登录GitHub网站，打开“Account settings”，“SSH Keys”页面,然后点“Add SSH Key”，填上任意Title，在Key文本框里粘贴id_rsa.pub文件的内容。
##### 添加远程仓库
在Github新建一个远程仓库
```
git remote add origin git@github.com:repo/repo_name.git(更改为你的远程仓库链接)
```
#### 提交代码
```
$ git push -u origin master
```