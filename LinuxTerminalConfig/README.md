# Linux Terminal Config

快速部署 Linux 终端工具：

- 更新日期：2021/10/25

## Install

使用 git submodule 管理各个工具版本。

1. 安装已有模块：
   - `./install.sh`

2. 更新子项目模块：
   - `./upgrade.sh`

3. 增加一个子项目模块：
   - `git submodule add <url> <path>`

4. 删除一个子项目模块：
   - `git rm --cached <submodule_path>`
   - `rm -rf <submodule_path>`
   - `vim <src_root_dir/.gitmodules>; clean submodule info`
   - `rm -rf <src_root_dir/.git/module/submodule>`

## 其他依赖

1. [vim forked amix/vimrc](https://github.com/HATTER-LONG/vimrc)：
   - 使用 [coc.nvim](https://github.com/neoclide/coc.nvim) 提供了补全功能：
     - Install nodejs >= 12.12：`curl -sL install-node.now.sh/lts | bash`。
     - Install npm：用于插件更新与管理。
     - 当前以安装的插件如下，如发现插件未加载请执行:`cd ~/.vim_runtime/temp_dirs/coc;mkdir coc;cp -rf * ./coc`
     - [coc-clangd](https://github.com/clangd/coc-clangd)。
     - [coc-highlight](https://github.com/neoclide/coc-highlight)。
     - [coc-rust-analyzer](https://github.com/fannheyward/coc-rust-analyzer)。
     - [coc-json](https://github.com/neoclide/coc-json)。
     - [coc-cmake](https://github.com/voldikss/coc-cmake)。
     - [coc-sh](https://github.com/josa42/coc-sh)
        - 依赖：`npm i -g bash-language-server`
     - [coc-clang-format-style-options](https://www.npmjs.com/package/coc-clang-format-style-options)
2. vim ack 插件依赖 ack 命令，需要安装。
