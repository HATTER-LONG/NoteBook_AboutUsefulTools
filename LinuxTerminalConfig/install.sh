#!/bin/sh

# 更新子模块
git submodule sync
git submodule update --init --recursive
git submodule update --remote --merge

ZSH=~/.oh-my-zsh
ZSHRC=~/.zshrc
VIMRUNTIME=~/.vim_runtime
PURE=~/.zsh
CURRENT=`pwd`

echo $CURRENT
echo $ZSH

echo "安装 vim config .........."
ln -s $CURRENT/vim_runtime $VIMRUNTIME
cd $VIMRUNTIME
./install_awesome_vimrc.sh
cd -

echo "安装 oh my zsh ..........."
ln -s $CURRENT/ohmyzsh_plugins/* $CURRENT/ohmyzsh/custom/plugins/
ln -s $CURRENT/ohmyzsh $ZSH
ln -s $CURRENT/zshrc $ZSHRC

echo "安装 pure 主题 ..........."
mkdir $PURE
ln -s $CURRENT/pure $PURE


echo "请注意安装依赖 npm nodejs 用于支持 cocnvim"
