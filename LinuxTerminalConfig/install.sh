#!/bin/sh

# 更新子模块
./upgrade.sh

ZSH=~/.oh-my-zsh
ZSHRC=~/.zshrc
EXPORTRC=~/.exports
ALIASESRC=~/.aliases
FUNCTIONRC=~/.functions
VIMRUNTIME=~/.vim_runtime
PURE=~/.zsh/pure
CURRENT=`pwd`
time_now=$(date "+%Y%m%d")
needback="false"

echo "清理已有环境 .........."
function clean_target() {
    if [ -d $1 ];then
        echo "清理已安装的 $1 ......"
        if [ $needback == "true" ];then
            echo "back $1 --> ${1}_back_$[time_now]"
            mv -f $1 ${1}_back_$[time_now]
        else
            rm -rf ${1}
        fi
    fi
}

clean_target $VIMRUNTIME
clean_target $ZSH
clean_target $ZSHRC
clean_target $PURE
clean_target $EXPORTRC
clean_target $ALIASESRC
clean_target $FUNCTIONRC

echo "安装 vim config .........."
ln -s $CURRENT/vim_runtime $VIMRUNTIME
cd $VIMRUNTIME
./install_awesome_vimrc.sh
cd -

echo "安装 oh my zsh ..........."
ln -s $CURRENT/ohmyzsh_plugins/* $CURRENT/ohmyzsh/custom/plugins/
ln -s $CURRENT/ohmyzsh $ZSH
ln -s $CURRENT/zshrc $ZSHRC
ln -s $CURRENT/functions $FUNCTIONRC
ln -s $CURRENT/aliases $ALIASESRC
ln -s $CURRENT/exports $EXPORTRC

echo "安装 pure 主题 ..........."

if [ ! -d ~/.zsh ];then
    mkdir ~/.zsh
fi
ln -s $CURRENT/pure $PURE


echo "安装依赖 npm nodejs 用于支持 cocnvim, 安装 ack 命令支持全局搜索..........."
#INSTALL="sudo pacman -Syyu"
INSTALL="brew install"
$INSTALL bat fzf  ack nodejs npm


echo "DONE !!! Enjoy :)"
