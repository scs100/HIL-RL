#!/bin/bash

# HIL-RL Git 仓库配置脚本
# Author: scs100
# Repository: https://github.com/scs100/HIL-RL

echo "================================================"
echo "HIL-RL Git 仓库配置"
echo "================================================"
echo ""

# 1. 检查Git仓库状态
if [ -d ".git" ]; then
    echo "✅ Git仓库已存在"
    echo ""
    
    # 显示当前远程仓库
    echo "当前远程仓库："
    git remote -v
    echo ""
    
    # 询问是否更改远程仓库
    read -p "是否要更改远程仓库为 scs100/HIL-RL? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote set-url origin git@github.com:scs100/HIL-RL.git
        echo "✅ 远程仓库已更新"
        git remote -v
    fi
else
    echo "⚠️  Git仓库不存在，正在初始化..."
    git init
    git remote add origin git@github.com:scs100/HIL-RL.git
    echo "✅ Git仓库已初始化"
fi

echo ""
echo "================================================"
echo "2. 添加 HIL-RL 相关文件"
echo "================================================"
echo ""

# 添加新文件
echo "添加键盘HIL控制模块..."
git add rlinf/envs/common/keyboard/

echo "添加键盘干预包装器..."
git add rlinf/envs/common/wrappers/keyboard_intervention.py

echo "添加配置文件..."
git add examples/embodiment/config/maniskill_sac_flow_keyboard_hil.yaml

echo "添加文档..."
git add QUICKSTART_DP_HIL_SAC.md
git add SETUP_KEYBOARD_HIL.md
git add HIL_RL_README.md
git add .git_setup_hil_rl.sh

echo "添加修改的文件..."
git add rlinf/envs/maniskill/maniskill_env.py

echo ""
echo "✅ 文件已添加到暂存区"
echo ""

# 显示状态
echo "当前Git状态："
git status

echo ""
echo "================================================"
echo "3. 提交更改"
echo "================================================"
echo ""

read -p "是否要提交这些更改? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git commit -m "feat: Add Keyboard HIL control for DP+SAC RL

- Implement KeyboardExpert for real-time keyboard input
- Add KeyboardIntervention wrapper for HIL
- Complete config for DP Transformer + SAC + HIL  
- Add comprehensive documentation

Features:
- Real-time keyboard control (WASD/QE/IJKL/UO/Space/Enter)
- Seamless intervention switching (human/policy)
- Configurable intervention window
- Full integration with ManiSkill3 simulation
- Optimized for RTX 4090

Author: scs100
Project: HIL-RL (Human-in-the-Loop Reinforcement Learning)
Repository: https://github.com/scs100/HIL-RL
"
    echo ""
    echo "✅ 更改已提交"
    echo ""
    
    # 询问是否推送
    read -p "是否要推送到远程仓库? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "正在推送到 origin main..."
        git push -u origin main
        echo "✅ 推送完成"
    else
        echo "ℹ️  稍后可以使用以下命令推送："
        echo "   git push -u origin main"
    fi
fi

echo ""
echo "================================================"
echo "完成！"
echo "================================================"
echo ""
echo "HIL-RL 文件清单："
echo ""
echo "新增文件："
echo "  ✅ rlinf/envs/common/keyboard/keyboard_expert.py"
echo "  ✅ rlinf/envs/common/keyboard/__init__.py"
echo "  ✅ rlinf/envs/common/wrappers/keyboard_intervention.py"
echo "  ✅ examples/embodiment/config/maniskill_sac_flow_keyboard_hil.yaml"
echo "  ✅ QUICKSTART_DP_HIL_SAC.md"
echo "  ✅ SETUP_KEYBOARD_HIL.md"
echo "  ✅ HIL_RL_README.md"
echo ""
echo "修改文件："
echo "  ✅ rlinf/envs/maniskill/maniskill_env.py (添加7行HIL支持)"
echo ""
echo "仓库信息："
echo "  📦 Repository: https://github.com/scs100/HIL-RL"
echo "  👤 Author: scs100"
echo "  📄 License: Apache License 2.0"
echo ""
echo "下一步："
echo "  1. 查看文档: cat QUICKSTART_DP_HIL_SAC.md"
echo "  2. 启动训练: bash examples/embodiment/run_embodiment.sh maniskill_sac_flow_keyboard_hil"
echo "  3. 访问仓库: https://github.com/scs100/HIL-RL"
echo ""
