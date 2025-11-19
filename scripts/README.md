# 同步脚本使用说明

## sync-from-tinygo.sh

从 TinyGo 官方仓库同步 machine 或 device 包的自动化脚本。

### 功能特性

- ✅ 自动从 TinyGo 仓库克隆指定版本
- ✅ 自动切换到对应的同步分支
- ✅ 生成详细的同步信息记录
- ✅ 自动创建 git 标签标记同步点
- ✅ 安全检查（工作区状态、分支存在性等）
- ✅ 交互式确认和推送选项

### 使用方法

```bash
# 基本用法
./scripts/sync-from-tinygo.sh <package> <version>

# 同步 machine 包到指定版本
./scripts/sync-from-tinygo.sh machine v0.32.0

# 同步 device 包到最新版本
./scripts/sync-from-tinygo.sh device latest

# 同步到特定的 git tag
./scripts/sync-from-tinygo.sh machine v0.33.0
```

### 参数说明

| 参数 | 说明 | 可选值 |
|------|------|--------|
| `package` | 要同步的包名 | `machine`, `device` |
| `version` | TinyGo 版本标签 | `v0.32.0`, `latest`, 任何有效的 git tag |

### 执行流程

脚本会按以下步骤执行：

1. **参数验证** - 检查输入参数是否有效
2. **安全检查** - 确保工作区干净，避免丢失未提交的更改
3. **分支切换** - 自动切换到对应的同步分支（如不存在则创建）
4. **克隆 TinyGo** - 从官方仓库克隆指定版本到临时目录
5. **文件同步** - 复制对应包的所有文件
6. **生成记录** - 创建/更新 SYNC_INFO.md 文件
7. **Git 提交** - 提交更改并创建标签
8. **清理** - 删除临时文件
9. **推送选项** - 询问是否推送到远程仓库

### 同步后的工作

脚本执行完成后，你需要：

#### 1. 检查同步的内容

```bash
# 查看最新提交的详细信息
git log -1 --stat

# 查看具体的代码差异
git show HEAD

# 对比与上一次同步的差异
git diff <上次同步的tag>
```

#### 2. 推送同步分支

```bash
# 推送分支和标签到远程
git push origin machine --tags
# 或
git push origin device --tags
```

#### 3. 合并到 main 分支

```bash
# 切换到 main 分支
git checkout main

# 合并同步的更改
git merge machine
# 或
git merge device

# 如果有冲突，解决后提交
git add .
git commit -m "Merge machine/device updates from TinyGo"

# 推送 main 分支
git push origin main
```

#### 4. 应用自定义修改

在 main 分支上应用你们的自定义修改：

```bash
# 创建功能分支
git checkout -b feature/your-custom-changes

# 进行修改
# ... 编辑文件 ...

# 提交修改
git add .
git commit -m "[CUSTOM] Your custom changes description"

# 合并回 main
git checkout main
git merge feature/your-custom-changes
```

### 注意事项

⚠️ **重要提醒**：

1. **工作区必须干净**
   - 脚本执行前会检查工作区状态
   - 如有未提交的更改，请先提交或暂存

2. **machine/device 分支的纯净性**
   - 这两个分支应该只包含从 TinyGo 同步的代码
   - 不要在这些分支上直接修改代码
   - 所有自定义修改应该在 main 或功能分支上进行

3. **标签命名规则**
   - 自动创建的标签格式：`sync-<package>-<version>`
   - 例如：`sync-machine-v0.32.0`, `sync-device-v0.32.0`

4. **备份机制**
   - 脚本会自动备份现有目录
   - 如果同步失败，可以从备份恢复

5. **网络要求**
   - 需要访问 GitHub 克隆 TinyGo 仓库
   - 确保网络连接稳定

### 故障排除

#### 问题：克隆 TinyGo 失败

```bash
# 解决方案1: 检查网络连接
ping github.com

# 解决方案2: 使用代理
export https_proxy=http://your-proxy:port
./scripts/sync-from-tinygo.sh machine v0.32.0

# 解决方案3: 手动克隆测试
git clone --depth 1 --branch v0.32.0 https://github.com/tinygo-org/tinygo.git /tmp/tinygo-test
```

#### 问题：找不到 src/machine 或 src/device 目录

可能的原因：
- TinyGo 版本太旧，目录结构不同
- 指定的版本标签不存在

```bash
# 解决方案：查看 TinyGo 的可用版本
git ls-remote --tags https://github.com/tinygo-org/tinygo.git | grep -v '\^{}' | tail -10
```

#### 问题：工作区不干净

```bash
# 查看未提交的更改
git status

# 方案1: 提交更改
git add .
git commit -m "Save work in progress"

# 方案2: 暂存更改
git stash
# 执行同步脚本后恢复
git stash pop
```

### 高级用法

#### 同步到特定 commit

如果需要同步到特定的 commit 而不是 tag：

```bash
# 修改脚本中的 VERSION 变量为 commit hash
./scripts/sync-from-tinygo.sh machine abc123def
```

#### 批量同步

创建一个批处理脚本：

```bash
#!/bin/bash
# batch-sync.sh

VERSION=${1:-latest}

echo "Syncing machine and device to $VERSION"
./scripts/sync-from-tinygo.sh machine $VERSION
./scripts/sync-from-tinygo.sh device $VERSION

echo "All packages synced!"
```

### 相关文档

- [分支管理策略](../BRANCHING.md) - 了解分支结构和管理策略
- [TinyGo 官方文档](https://tinygo.org/docs/) - TinyGo 项目文档
- [TinyGo GitHub](https://github.com/tinygo-org/tinygo) - TinyGo 源代码仓库
