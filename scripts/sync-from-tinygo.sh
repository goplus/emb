#!/bin/bash
set -e

# TinyGo 同步脚本
# 用法: ./sync-from-tinygo.sh <package> <version>
# 示例: ./sync-from-tinygo.sh machine v0.32.0

PACKAGE=$1
VERSION=$2
TINYGO_REPO="https://github.com/tinygo-org/tinygo.git"
TEMP_DIR=$(mktemp -d)

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 帮助信息
show_help() {
    echo "用法: $0 <package> <version>"
    echo ""
    echo "参数:"
    echo "  package   : 要同步的包名 (machine 或 device)"
    echo "  version   : TinyGo 版本标签 (如 v0.32.0) 或 'latest'"
    echo ""
    echo "示例:"
    echo "  $0 machine v0.32.0"
    echo "  $0 device latest"
    echo ""
}

# 参数检查
if [ -z "$PACKAGE" ] || [ -z "$VERSION" ]; then
    echo -e "${RED}错误: 缺少参数${NC}"
    show_help
    exit 1
fi

if [ "$PACKAGE" != "machine" ] && [ "$PACKAGE" != "device" ]; then
    echo -e "${RED}错误: package 必须是 'machine' 或 'device'${NC}"
    exit 1
fi

echo -e "${GREEN}=== TinyGo 同步脚本 ===${NC}"
echo "包名: $PACKAGE"
echo "版本: $VERSION"
echo "临时目录: $TEMP_DIR"
echo ""

# 确认操作
read -p "确认要同步吗? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}操作已取消${NC}"
    exit 0
fi

# 检查是否在 git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}错误: 不在 git 仓库中${NC}"
    exit 1
fi

# 保存当前分支
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${YELLOW}当前分支: $CURRENT_BRANCH${NC}"

# 检查工作区是否干净
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}错误: 工作区不干净，请先提交或暂存更改${NC}"
    git status --short
    exit 1
fi

# 切换到目标分支
echo -e "${GREEN}切换到 $PACKAGE 分支${NC}"
if ! git show-ref --verify --quiet refs/heads/$PACKAGE; then
    echo -e "${YELLOW}分支 $PACKAGE 不存在，正在创建...${NC}"
    git checkout -b $PACKAGE
else
    git checkout $PACKAGE
fi

# 克隆 TinyGo 仓库
echo -e "${GREEN}克隆 TinyGo 仓库到临时目录...${NC}"
git clone --depth 1 --branch $VERSION $TINYGO_REPO "$TEMP_DIR/tinygo" 2>&1 | grep -v "^Cloning" || true

# 确定源目录路径
SOURCE_DIR="$TEMP_DIR/tinygo/src/$PACKAGE"

if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}错误: TinyGo 仓库中找不到 src/$PACKAGE 目录${NC}"
    echo "尝试的路径: $SOURCE_DIR"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 备份现有文件（如果存在）
if [ -d "$PACKAGE" ]; then
    echo -e "${YELLOW}备份现有 $PACKAGE 目录...${NC}"
    BACKUP_DIR="$PACKAGE.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$PACKAGE" "$BACKUP_DIR"
fi

# 复制新文件
echo -e "${GREEN}复制 $PACKAGE 文件...${NC}"
cp -r "$SOURCE_DIR" .

# 获取 TinyGo 的 commit hash
TINYGO_COMMIT=$(cd "$TEMP_DIR/tinygo" && git rev-parse HEAD)
TINYGO_COMMIT_SHORT=$(cd "$TEMP_DIR/tinygo" && git rev-parse --short HEAD)

# 创建或更新 SYNC_INFO.md
SYNC_INFO_FILE="$PACKAGE/SYNC_INFO.md"
cat > "$SYNC_INFO_FILE" << EOF
# TinyGo 同步信息

## 最新同步记录

- **包名**: $PACKAGE
- **TinyGo 版本**: $VERSION
- **TinyGo Commit**: $TINYGO_COMMIT
- **同步日期**: $(date +"%Y-%m-%d %H:%M:%S")
- **同步者**: $(git config user.name) <$(git config user.email)>

## 同步说明

此分支仅包含从 TinyGo 官方仓库同步的原始代码，不应包含任何自定义修改。

### TinyGo 源仓库
- 仓库地址: $TINYGO_REPO
- 源路径: src/$PACKAGE/

### 下次同步步骤

\`\`\`bash
./scripts/sync-from-tinygo.sh $PACKAGE <新版本号>
\`\`\`

## 历史同步记录

| 日期 | 版本 | Commit | 同步者 |
|------|------|--------|--------|
| $(date +"%Y-%m-%d") | $VERSION | $TINYGO_COMMIT_SHORT | $(git config user.name) |

EOF

# 添加所有更改
echo -e "${GREEN}添加文件到 git...${NC}"
git add "$PACKAGE"

# 检查是否有更改
if git diff --staged --quiet; then
    echo -e "${YELLOW}没有检测到更改，可能已经是最新版本${NC}"
    rm -rf "$TEMP_DIR"
    [ -d "$BACKUP_DIR" ] && mv "$BACKUP_DIR" "$PACKAGE"
    git checkout "$CURRENT_BRANCH"
    exit 0
fi

# 提交更改
COMMIT_MSG="[SYNC] Update $PACKAGE to TinyGo $VERSION

Synced from: $TINYGO_REPO
Source path: src/$PACKAGE/
TinyGo commit: $TINYGO_COMMIT
Sync date: $(date +"%Y-%m-%d %H:%M:%S")
"

echo -e "${GREEN}提交更改...${NC}"
git commit -m "$COMMIT_MSG"

# 创建标签
TAG_NAME="sync-$PACKAGE-$VERSION"
echo -e "${GREEN}创建标签: $TAG_NAME${NC}"
git tag -a "$TAG_NAME" -m "Sync $PACKAGE from TinyGo $VERSION"

# 清理
echo -e "${GREEN}清理临时文件...${NC}"
rm -rf "$TEMP_DIR"
[ -d "$BACKUP_DIR" ] && rm -rf "$BACKUP_DIR"

# 显示统计信息
echo ""
echo -e "${GREEN}=== 同步完成 ===${NC}"
echo "分支: $PACKAGE"
echo "版本: $VERSION"
echo "标签: $TAG_NAME"
echo ""
echo -e "${YELLOW}接下来的步骤:${NC}"
echo "1. 检查同步的代码: git log -1 --stat"
echo "2. 推送到远程: git push origin $PACKAGE --tags"
echo "3. 合并到 main: git checkout main && git merge $PACKAGE"
echo "4. 返回原分支: git checkout $CURRENT_BRANCH"
echo ""

# 询问是否推送
read -p "是否现在推送到远程? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}推送到远程...${NC}"
    git push origin $PACKAGE --tags
    echo -e "${GREEN}推送完成${NC}"
fi

# 询问是否返回原分支
read -p "是否返回原分支 $CURRENT_BRANCH? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    git checkout "$CURRENT_BRANCH"
    echo -e "${GREEN}已返回 $CURRENT_BRANCH 分支${NC}"
fi
