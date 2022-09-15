# 工具仓库

## git

### 创建 PR 分支

- 设置上游：`git remote add upstream https://github.com/ayamir/nvimdots; git remote -v`
- 切换分支：`git checkout upstream/main`
- 创建分支：`git checkout -b pull_request`
- 合如修改：`git cherry-pick xxx`
- 提交分支：`git push --set-upstream https://github.com/HATTER-LONG/nvimdots pull_request`
- 提交 PR。

### git 模块控制

- 增加一个子项目模块：
  - `git submodule add <url> <path>`

- 删除一个子项目模块：
  - `git rm --cached <submodule_path>`
  - `rm -rf <submodule_path>`
  - `vim <src_root_dir/.gitmodules>; clean submodule info`
  - `rm -rf <src_root_dir/.git/module/submodule>`

## python 虚拟环境

### venv

- ubuntu 使用 python venv 进行虚拟环境：
  1. `python -m vevn name` 用于新建一个虚拟 python 环境。
  2. `source name/bin/active` 启用该虚拟环境。

### pyenv

- macos 使用 pyenv 管理 python 环境：
  1. `pyenv list` 查看当前虚拟环境 python 状态。