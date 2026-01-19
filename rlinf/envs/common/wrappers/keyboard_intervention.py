# Copyright 2025 scs100
# Project: HIL-RL (Human-in-the-Loop Reinforcement Learning)
# Repository: https://github.com/scs100/HIL-RL
# Licensed under the Apache License, Version 2.0
#
# Based on RLinf framework: https://github.com/RLinf/RLinf

"""
键盘HIL干预Wrapper - 用于仿真环境
"""

import time
import gymnasium as gym
import numpy as np

from rlinf.envs.common.keyboard.keyboard_expert import KeyboardExpert


class KeyboardIntervention(gym.ActionWrapper):
    """
    键盘人工干预包装器
    当检测到键盘输入时，使用人工动作替代策略动作
    """
    
    def __init__(self, env, intervention_window=0.5):
        super().__init__(env)
        
        print("🎮 初始化键盘HIL控制...")
        
        # 检测动作空间维度
        self.action_dim = self.action_space.shape[0]
        print(f"   动作空间维度: {self.action_dim}")
        
        # 初始化键盘专家
        self.expert = KeyboardExpert()
        
        # HIL参数
        self.intervention_window = intervention_window  # 干预窗口（秒）
        self.last_intervene = 0
        self.left, self.right = False, False
        
        # 统计信息
        self.total_steps = 0
        self.intervention_steps = 0
        
        print("✅ 键盘HIL控制初始化完成")
        print(f"   干预窗口: {intervention_window}秒")
        print()
    
    def action(self, policy_action: np.ndarray) -> tuple[np.ndarray, bool]:
        """
        选择动作：键盘输入优先于策略动作
        
        Returns:
            action: 最终执行的动作
            intervened: 是否被人工干预
        """
        # 获取键盘输入
        expert_a, buttons = self.expert.get_action()
        self.left, self.right = tuple(buttons)
        
        # 检测是否有键盘输入（任何非零分量）
        if np.linalg.norm(expert_a) > 1e-4:
            self.last_intervene = time.time()
        
        # 在干预窗口内，使用人工动作
        if time.time() - self.last_intervene < self.intervention_window:
            # 确保动作维度匹配
            if len(expert_a) != self.action_dim:
                # 截断或填充
                final_action = np.zeros(self.action_dim)
                final_action[:min(len(expert_a), self.action_dim)] = expert_a[:min(len(expert_a), self.action_dim)]
            else:
                final_action = expert_a
            
            return final_action, True
        
        return policy_action, False
    
    def step(self, policy_action):
        """执行一步，可能被键盘干预"""
        # 选择最终动作
        final_action, intervened = self.action(policy_action)
        
        # 执行动作
        obs, rew, done, truncated, info = self.env.step(final_action)
        
        # 记录干预信息
        self.total_steps += 1
        if intervened:
            self.intervention_steps += 1
            info["intervention"] = True
            info["intervention_action"] = final_action
            
            # 每100步打印一次统计
            if self.total_steps % 100 == 0:
                ratio = self.intervention_steps / self.total_steps * 100
                print(f"🎮 HIL统计: {self.intervention_steps}/{self.total_steps} ({ratio:.1f}%) 步被人工干预")
        
        info["keyboard_left"] = self.left
        info["keyboard_right"] = self.right
        
        return obs, rew, done, truncated, info
    
    def reset(self, **kwargs):
        """重置环境"""
        # 重置统计（可选）
        # self.total_steps = 0
        # self.intervention_steps = 0
        return self.env.reset(**kwargs)
    
    def close(self):
        """清理资源"""
        print("\n🎮 关闭键盘HIL控制...")
        print(f"   总步数: {self.total_steps}")
        print(f"   干预步数: {self.intervention_steps}")
        if self.total_steps > 0:
            print(f"   干预率: {self.intervention_steps/self.total_steps*100:.1f}%")
        
        self.expert.stop()
        super().close()
