# HIL-RL: Human-in-the-Loop Reinforcement Learning

**Author:** scs100  
**Repository:** https://github.com/scs100/HIL-RL  
**License:** Apache License 2.0  
**Based on:** [RLinf Framework](https://github.com/RLinf/RLinf)

---

## 📋 项目简介

本项目在 RLinf 框架基础上实现了 **Diffusion Policy + SAC + 键盘HIL** 的完整强化学习系统。

**核心贡献：**
- ✅ 键盘HIL控制系统（KeyboardExpert + KeyboardIntervention）
- ✅ DP Transformer + SAC 仿真环境配置
- ✅ ManiSkill3 仿真环境集成
- ✅ 完整的使用文档和快速开始指南

---

## 🎯 新增功能

### 1. 键盘HIL控制模块

**文件位置：**
- `rlinf/envs/common/keyboard/keyboard_expert.py`
- `rlinf/envs/common/wrappers/keyboard_intervention.py`

**功能特性：**
- 实时键盘输入监听
- 人工干预与策略动作无缝切换
- 可配置干预窗口
- 干预统计和可视化

### 2. 完整配置文件

**文件位置：**
- `examples/embodiment/config/maniskill_sac_flow_keyboard_hil.yaml`

**配置特性：**
- Diffusion Policy Transformer (Flow Policy)
- SAC 算法优化参数
- 键盘HIL集成
- 4090 GPU 优化

### 3. 文档和指南

**文件位置：**
- `QUICKSTART_DP_HIL_SAC.md` - 5分钟快速开始
- `SETUP_KEYBOARD_HIL.md` - 详细使用文档
- `HIL_RL_README.md` - 本文档

---

## 🚀 快速开始

### 安装依赖
```bash
pip install pynput
```

### 下载预训练权重
```bash
mkdir -p checkpoints && cd checkpoints
wget https://github.com/RLinf/misc/releases/download/v0.1/resnet10_pretrained.pt
cd ..
```

### 启动训练
```bash
bash examples/embodiment/run_embodiment.sh maniskill_sac_flow_keyboard_hil
```

---

## 🎮 键盘控制

**控制说明：**
- **WASD** - XY平面移动
- **Q/E** - Z轴上下
- **IJKL** - 旋转控制
- **U/O** - Roll旋转
- **Space** - 闭合夹爪
- **Enter** - 打开夹爪

---

## 📊 技术架构

```
键盘输入 → KeyboardExpert → KeyboardIntervention
                                    ↓
                            动作选择（人工/策略）
                                    ↓
                            Flow Policy (DP Transformer)
                                    ↓
                            SAC训练 + Replay Buffer
                                    ↓
                            ManiSkill3 仿真环境
```

---

## 📁 文件列表

### 新增文件（HIL-RL 贡献）

```
rlinf/envs/common/
├── keyboard/
│   ├── __init__.py                      ✅ scs100
│   └── keyboard_expert.py               ✅ scs100
└── wrappers/
    └── keyboard_intervention.py         ✅ scs100

examples/embodiment/config/
└── maniskill_sac_flow_keyboard_hil.yaml ✅ scs100

文档：
├── QUICKSTART_DP_HIL_SAC.md             ✅ scs100
├── SETUP_KEYBOARD_HIL.md                ✅ scs100
└── HIL_RL_README.md                     ✅ scs100
```

### 修改文件

```
rlinf/envs/maniskill/maniskill_env.py    ✅ 添加键盘HIL支持（7行）
```

---

## 🔧 Git 配置

### 创建新仓库
```bash
cd ~/code/opens/RLinf-main

# 如果要创建新的Git仓库
git init
git remote add origin git@github.com:scs100/HIL-RL.git

# 或者如果要更改现有仓库
git remote set-url origin git@github.com:scs100/HIL-RL.git
```

### 提交HIL-RL相关文件
```bash
# 添加新文件
git add rlinf/envs/common/keyboard/
git add rlinf/envs/common/wrappers/keyboard_intervention.py
git add examples/embodiment/config/maniskill_sac_flow_keyboard_hil.yaml
git add QUICKSTART_DP_HIL_SAC.md
git add SETUP_KEYBOARD_HIL.md
git add HIL_RL_README.md

# 提交
git commit -m "feat: Add Keyboard HIL control for DP+SAC RL

- Implement KeyboardExpert for real-time keyboard input
- Add KeyboardIntervention wrapper for HIL
- Complete config for DP Transformer + SAC + HIL
- Add comprehensive documentation

Author: scs100
Project: HIL-RL
"

# 推送（如果需要）
# git push -u origin main
```

---

## 📄 许可证

**Apache License 2.0**

本项目基于 [RLinf Framework](https://github.com/RLinf/RLinf) 开发，遵循 Apache License 2.0。

```
Copyright 2025 scs100

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

---

## 🙏 致谢

本项目基于以下开源项目：
- [RLinf](https://github.com/RLinf/RLinf) - 强化学习基础框架
- [ManiSkill3](https://github.com/haosulab/ManiSkill) - GPU仿真环境
- [Diffusion Policy](https://github.com/real-stanford/diffusion_policy) - DP Transformer架构

特别感谢 RLinf 团队提供的优秀框架！

---

## 📞 联系方式

- **GitHub:** https://github.com/scs100/HIL-RL
- **Issue Tracker:** https://github.com/scs100/HIL-RL/issues

---

**创建日期：** 2025-01-19  
**版本：** v1.0.0  
**作者：** scs100
