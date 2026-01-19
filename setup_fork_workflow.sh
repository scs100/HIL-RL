#!/bin/bash
# Copyright 2025 scs100
# Setup Fork Workflow for HIL-RL based on RLinf
# 基于RLinf创建HIL-RL的Fork工作流

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  HIL-RL Fork 工作流设置向导${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查是否已经在RLinf-main目录
CURRENT_DIR=$(basename "$PWD")
if [[ "$CURRENT_DIR" != "RLinf-main" ]]; then
    echo -e "${RED}错误: 请在 RLinf-main 目录下运行此脚本${NC}"
    exit 1
fi

# 步骤1: 提示用户在GitHub上Fork
echo -e "${YELLOW}步骤 1: 在GitHub上Fork原始仓库${NC}"
echo "请访问原始RLinf仓库的GitHub页面，点击右上角的 'Fork' 按钮"
echo "将仓库Fork到您的GitHub账户 (scs100)"
echo ""
read -p "已经完成Fork了吗? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}请先完成Fork操作，然后重新运行此脚本${NC}"
    exit 1
fi

# 步骤2: 获取原始仓库的Git URL
echo ""
echo -e "${YELLOW}步骤 2: 获取原始仓库信息${NC}"
ORIGINAL_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$ORIGINAL_REMOTE" ]; then
    read -p "请输入原始RLinf仓库的Git URL (例如: https://github.com/original/RLinf.git): " ORIGINAL_REMOTE
else
    echo "检测到当前origin: $ORIGINAL_REMOTE"
    read -p "这是原始仓库URL吗? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        read -p "请输入原始RLinf仓库的Git URL: " ORIGINAL_REMOTE
    fi
fi

# 步骤3: 设置您的Fork仓库
echo ""
echo -e "${YELLOW}步骤 3: 配置远程仓库${NC}"
YOUR_FORK="git@github.com:scs100/HIL-RL.git"
echo "您的Fork仓库: $YOUR_FORK"

# 重命名当前origin为upstream
if git remote get-url origin &>/dev/null; then
    echo "将当前 'origin' 重命名为 'upstream'..."
    git remote rename origin upstream
fi

# 添加您的Fork为origin
echo "添加您的Fork仓库为 'origin'..."
git remote add origin "$YOUR_FORK" 2>/dev/null || git remote set-url origin "$YOUR_FORK"

# 显示远程仓库配置
echo ""
echo -e "${GREEN}远程仓库配置完成:${NC}"
git remote -v

# 步骤4: 创建功能分支
echo ""
echo -e "${YELLOW}步骤 4: 创建功能分支${NC}"
read -p "请输入功能分支名称 (默认: feature/keyboard-hil): " BRANCH_NAME
BRANCH_NAME=${BRANCH_NAME:-feature/keyboard-hil}

git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"
echo -e "${GREEN}已切换到分支: $BRANCH_NAME${NC}"

# 步骤5: 提示添加修改
echo ""
echo -e "${YELLOW}步骤 5: 添加您的修改${NC}"
echo "现在您可以修改代码了。修改完成后，使用以下命令提交:"
echo ""
echo -e "${GREEN}  git add .${NC}"
echo -e "${GREEN}  git commit -m '您的提交信息'${NC}"
echo -e "${GREEN}  git push origin $BRANCH_NAME${NC}"
echo ""

# 创建同步脚本
echo -e "${YELLOW}步骤 6: 创建同步上游脚本${NC}"
cat > sync_upstream.sh << 'EOF'
#!/bin/bash
# 同步上游RLinf更新到您的Fork

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}开始同步上游更新...${NC}"

# 获取当前分支
CURRENT_BRANCH=$(git branch --show-current)
echo "当前分支: $CURRENT_BRANCH"

# 获取上游更新
echo -e "${YELLOW}获取上游更新...${NC}"
git fetch upstream

# 切换到main分支
echo -e "${YELLOW}切换到main分支...${NC}"
git checkout main

# 合并上游更新
echo -e "${YELLOW}合并上游更新...${NC}"
git merge upstream/main

# 推送到您的Fork
echo -e "${YELLOW}推送到您的Fork...${NC}"
git push origin main

# 回到原分支
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}切换回 $CURRENT_BRANCH 分支...${NC}"
    git checkout "$CURRENT_BRANCH"
    
    # 询问是否要将更新合并到当前分支
    read -p "是否要将main分支的更新合并到 $CURRENT_BRANCH? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}合并main到 $CURRENT_BRANCH...${NC}"
        git merge main
        echo -e "${GREEN}合并完成！如有冲突，请解决后提交。${NC}"
    fi
fi

echo -e "${GREEN}同步完成！${NC}"
EOF

chmod +x sync_upstream.sh
echo -e "${GREEN}已创建 sync_upstream.sh 脚本${NC}"
echo "使用 './sync_upstream.sh' 来同步上游更新"

# 创建工作流说明文件
cat > FORK_WORKFLOW.md << 'EOF'
# HIL-RL Fork 工作流说明

## 仓库结构

- **origin**: 您的Fork仓库 (git@github.com:scs100/HIL-RL.git)
- **upstream**: 原始RLinf仓库

## 日常工作流

### 1. 开发新功能

```bash
# 创建新的功能分支
git checkout -b feature/new-feature

# 修改代码
# ...

# 提交更改
git add .
git commit -m "描述您的更改"

# 推送到您的Fork
git push origin feature/new-feature
```

### 2. 同步上游更新

```bash
# 使用提供的脚本
./sync_upstream.sh

# 或手动执行
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

### 3. 将上游更新合并到功能分支

```bash
git checkout feature/new-feature
git merge main
# 解决冲突（如果有）
git push origin feature/new-feature
```

### 4. 向上游贡献代码（可选）

如果您想将改进提交回原始RLinf项目：

1. 确保您的功能分支是基于最新的upstream/main
2. 在GitHub上从您的Fork创建Pull Request到上游仓库

## 冲突处理

当合并上游更新时遇到冲突：

```bash
# 1. 查看冲突文件
git status

# 2. 手动编辑冲突文件，解决冲突标记
# <<<<<<< HEAD
# 您的更改
# =======
# 上游的更改
# >>>>>>> upstream/main

# 3. 标记为已解决
git add <冲突文件>

# 4. 完成合并
git commit

# 5. 推送
git push origin <当前分支>
```

## 常用命令

```bash
# 查看远程仓库
git remote -v

# 查看所有分支
git branch -a

# 查看当前状态
git status

# 查看提交历史
git log --oneline --graph --all

# 切换分支
git checkout <分支名>

# 更新所有远程分支信息
git fetch --all
```

## 最佳实践

1. **保持main分支干净**: main分支应该始终与upstream/main同步
2. **在功能分支开发**: 所有修改都在独立的功能分支进行
3. **定期同步**: 每周至少同步一次上游更新
4. **提交前先拉取**: 推送前先同步最新代码，减少冲突
5. **清晰的提交信息**: 使用描述性的commit message
EOF

echo -e "${GREEN}已创建 FORK_WORKFLOW.md 工作流说明文件${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  设置完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "下一步:"
echo "1. 修改代码"
echo "2. git add ."
echo "3. git commit -m '您的提交信息'"
echo "4. git push origin $BRANCH_NAME"
echo "5. 定期运行 ./sync_upstream.sh 同步上游更新"
echo ""
echo "详细工作流说明请查看 FORK_WORKFLOW.md"
