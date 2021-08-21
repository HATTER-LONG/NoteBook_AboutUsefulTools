#!/bin/sh

# 更新子模块
git submodule sync
git submodule update --init --recursive
git submodule foreach git pull

ZSH=~/.oh-my-zsh
ZSHRC=~/.zshrc
VIMRUNTIME=~/.vim_runtime
PURE=~/.zsh
CURRENT=`pwd`

echo $CURRENT
echo $ZSH

echo "安装 vim config .........."
ln -s ./vim_runtime $VIMRUNTIME
cd VIMRUNTIME
install_awesome_vimrc.sh
cd -

echo "安装 oh my zsh ..........."
ln -s $CURRENT/ohmyzsh_plugins/* ./ohmyzsh/custom/plugins/
ln -s $CURRENT/ohmyzsh $ZSH
ln -s $CURRENT/zshrc $ZSHRC

echo "安装 pure 主题 ..........."
mkdir $PURE
ln -s $CURRENT/pure $PURE

