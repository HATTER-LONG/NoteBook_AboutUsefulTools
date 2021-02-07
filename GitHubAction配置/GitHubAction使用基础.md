# GitHub Action 使用

- [GitHub Action 使用](#github-action-使用)
  - [GitHub Action 的组件](#github-action-的组件)
    - [创建实例工作流程](#创建实例工作流程)
    - [了解工作流程文件](#了解工作流程文件)
  - [工作流中使用环境变量](#工作流中使用环境变量)
    - [在作业之间共享数据](#在作业之间共享数据)
  - [管理负责的工作流程](#管理负责的工作流程)
    - [创建依赖作业](#创建依赖作业)
    - [使用构建矩阵](#使用构建矩阵)
    - [缓存依赖项](#缓存依赖项)

了解 GitHub Actions 的核心概念和各种组件，并查看说明如何为仓库添加自动化的示例。[官方教程](https://docs.github.com/cn/actions/learn-github-actions/introduction-to-github-actions?learn=getting_started)

## GitHub Action 的组件

1. 工作流程：工作流程可用于在 GitHub 上构建、测试、打包、发布或部署项目。
2. 事件：事件是触发工作流程的特定活动。 例如，当有推送提交到仓库或者创建议题或拉取请求时，GitHub 就可能产生活动。具体参阅[触发工作流程的事件](https://docs.github.com/cn/actions/reference/events-that-trigger-workflows)。
3. Jobs：作业是在同一运行服务器上执行的一组步骤。 默认情况下，包含多个作业的工作流程将同时运行这些作业。 您也可以配置工作流程按顺序运行作业。 例如，工作流程可以有两个连续的任务来构建和测试代码，其中测试作业取决于构建作业的状态。 如果构建作业失败，测试作业将不会运行。
4. 运行器：运行器是安装了 GitHub Actions 运行器应用程序的服务器。 您可以使用 GitHub 托管的运行器或托管您自己的运行器。请参阅“[托管您自己的运行器](https://docs.github.com/cn/actions/hosting-your-own-runners)”。

### 创建实例工作流程

1. GitHub Actions 使用 [YAML 语法](https://docs.github.com/cn/actions/reference/workflow-syntax-for-github-actions#jobsjob_idsteps)来定义事件、作业和步骤。 这些 YAML 文件存储在代码仓库中名为 .github/workflows 的目录中。创建 .github/workflows/ 目录来存储工作流程文件。
2. 在 .github/workflows/ 目录中，创建 *.yml 流程定义文件。

    ```yaml
    name: learn-github-actions
    on: [push]
    jobs:
    check-bats-version:
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v2
        - uses: actions/setup-node@v1
        - run: npm install -g bats
        - run: bats -v
    ```

3. 提交这些更改并将其推送到您的 GitHub 仓库。

### [了解工作流程文件](https://docs.github.com/cn/actions/learn-github-actions/introduction-to-github-actions?learn=getting_started#understanding-the-workflow-file)

## 工作流中使用环境变量

```yaml
jobs:
  example-job:
      steps:
        - name: Connect to PostgreSQL
          run: node client.js
          env:
            POSTGRES_HOST: postgres
            POSTGRES_PORT: 5432
```

### 在作业之间共享数据

如果作业生成您要与同一工作流程中的另一个作业共享的文件，或者您要保存这些文件供以后参考，可以将它们作为构件存储在 GitHub 中。 构件是创建并测试代码时所创建的文件。 例如，构件可能包含二进制或包文件、测试结果、屏幕截图或日志文件。 构件与其创建时所在的工作流程运行相关，可被另一个作业使用。

```yaml
jobs:
  example-job:
    name: Save output
    steps:
      - shell: bash
        run: |
          expr 1 + 1 > output.log
      - name: Upload output file
        uses: actions/upload-artifact@v1
        with:
          name: output-log-file
          path: output.log
```

要从单独的工作流程运行下载构件，您可以使用 actions/download-artifact 操作。 例如，您可以下载名为 output-log-file 的构件。具体可以参考[将工作流程数据存储为构件](https://docs.github.com/cn/actions/guides/storing-workflow-data-as-artifacts#downloading-or-deleting-artifacts)。

```yaml
jobs:
  example-job:
    steps:
      - name: Download a single artifact
        uses: actions/download-artifact@v2
        with:
          name: output-log-file
```

## [管理负责的工作流程](https://docs.github.com/cn/actions/learn-github-actions/managing-complex-workflows?learn=getting_started)

### 创建依赖作业

默认情况下，工作流程中的作业同时并行运行。 因此，如果您有一个作业必须在另一个作业完成后运行，可以使用 needs 关键字来创建此依赖项。 如果其中一个作业失败，则跳过所有从属作业；但如果您需要作业继续，可以使用条件语句 [if](https://docs.github.com/cn/actions/reference/workflow-syntax-for-github-actions#jobsjob_idif) 来定义。

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - run: ./setup_server.sh
  build:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - run: ./build_server.sh
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: ./test_server.sh
```

### 使用构建矩阵

如果您希望工作流程跨操作系统、平台和语言的多个组合运行测试，可以使用构建矩阵。 构建矩阵是使用 strategy 关键字创建的，它接收构建选项作为数组。 例如，此构建矩阵将使用不同版本的 Node.js 多次运行作业：

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node: [6, 8, 10]
    steps:
      - uses: actions/setup-node@v1
        with:
          node-version: ${{ matrix.node }}
 ```

更多信息请参阅 [jobs.<job_id>.strategy.matrix](https://docs.github.com/cn/actions/reference/workflow-syntax-for-github-actions#jobsjob_idstrategymatrix)。

### 缓存依赖项

GitHub 托管的运行器启动为每个作业的新环境，如果您的作业定期重复使用依赖项，您可以考虑缓存这些文件以帮助提高性能。 缓存一旦创建，就可用于同一仓库中的所有工作流程。

```yaml
    - name: Cache
      uses: actions/cache@v2.1.4
      id: EnvCache
      with:
        # A list of files, directories, and wildcard patterns to cache and restore
        path: |
              ${{ github.workspace }}/Env/usr/
        # An explicit key for restoring and saving the cache
        key: ${{ runner.os }}-${{ steps.get-date.outputs.date }}-H
```

更多信息请参阅“[缓存依赖项以加快工作流程](https://docs.github.com/cn/actions/guides/caching-dependencies-to-speed-up-workflows)”。
