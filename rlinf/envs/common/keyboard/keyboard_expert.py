# Copyright 2025 scs100
# Project: HIL-RL (Human-in-the-Loop Reinforcement Learning)
# Repository: https://github.com/scs100/HIL-RL
# Licensed under the Apache License, Version 2.0
#
# Based on RLinf framework: https://github.com/RLinf/RLinf

"""
键盘控制接口 - 用于仿真环境的HIL
"""

import threading
import numpy as np


class KeyboardExpert:
    """
    键盘控制专家系统
    持续监听键盘输入，提供get_action方法获取实时动作
    """
    
    def __init__(self):
        try:
            from pynput import keyboard
        except ImportError:
            raise ImportError(
                "请先安装 pynput: pip install pynput"
            )
        
        self.state_lock = threading.Lock()
        self.latest_data = {
            "action": np.zeros(7),  # [x, y, z, rx, ry, rz, gripper]
            "buttons": [0, 0]       # [gripper_close, gripper_open]
        }
        
        # 键盘监听器
        self.listener = keyboard.Listener(
            on_press=self._on_press,
            on_release=self._on_release
        )
        self.listener.daemon = True
        self.listener.start()
        
        # 当前按下的键
        self.pressed_keys = set()
        
        # 控制灵敏度（仿真环境可以调高一些）
        self.linear_speed = 0.02   # 线性速度
        self.angular_speed = 0.1   # 角速度
        
        print("=" * 60)
        print("🎮 键盘控制已启动")
        print("=" * 60)
        print("控制说明:")
        print("  【平移控制】")
        print("    W/S     - 前进/后退 (Y轴)")
        print("    A/D     - 左移/右移 (X轴)")
        print("    Q/E     - 上升/下降 (Z轴)")
        print("")
        print("  【旋转控制】")
        print("    I/K     - 俯仰 (Pitch)")
        print("    J/L     - 偏航 (Yaw)")
        print("    U/O     - 翻滚 (Roll)")
        print("")
        print("  【夹爪控制】")
        print("    Space   - 闭合夹爪")
        print("    Enter   - 打开夹爪")
        print("=" * 60)
    
    def _on_press(self, key):
        """按键按下事件"""
        with self.state_lock:
            try:
                # 字母键
                if hasattr(key, 'char') and key.char:
                    self.pressed_keys.add(key.char.lower())
                # 特殊键
                else:
                    self.pressed_keys.add(key)
                
                self._update_action()
            except Exception as e:
                pass
    
    def _on_release(self, key):
        """按键释放事件"""
        with self.state_lock:
            try:
                if hasattr(key, 'char') and key.char:
                    self.pressed_keys.discard(key.char.lower())
                else:
                    self.pressed_keys.discard(key)
                
                self._update_action()
            except Exception as e:
                pass
    
    def _update_action(self):
        """根据当前按键更新动作"""
        action = np.zeros(7)
        buttons = [0, 0]
        
        # === XYZ 平移控制 ===
        if 'w' in self.pressed_keys:  # 前进 (+Y)
            action[1] = self.linear_speed
        if 's' in self.pressed_keys:  # 后退 (-Y)
            action[1] = -self.linear_speed
        if 'a' in self.pressed_keys:  # 左移 (-X)
            action[0] = -self.linear_speed
        if 'd' in self.pressed_keys:  # 右移 (+X)
            action[0] = self.linear_speed
        if 'q' in self.pressed_keys:  # 上升 (+Z)
            action[2] = self.linear_speed
        if 'e' in self.pressed_keys:  # 下降 (-Z)
            action[2] = -self.linear_speed
        
        # === 旋转控制 ===
        if 'i' in self.pressed_keys:  # Pitch +
            action[4] = self.angular_speed
        if 'k' in self.pressed_keys:  # Pitch -
            action[4] = -self.angular_speed
        if 'j' in self.pressed_keys:  # Yaw +
            action[5] = self.angular_speed
        if 'l' in self.pressed_keys:  # Yaw -
            action[5] = -self.angular_speed
        if 'u' in self.pressed_keys:  # Roll +
            action[3] = self.angular_speed
        if 'o' in self.pressed_keys:  # Roll -
            action[3] = -self.angular_speed
        
        # === 夹爪控制 ===
        from pynput import keyboard as kb
        if kb.Key.space in self.pressed_keys:  # 空格 = 闭合
            action[6] = -1.0
            buttons[0] = 1
        if kb.Key.enter in self.pressed_keys:  # 回车 = 打开
            action[6] = 1.0
            buttons[1] = 1
        
        self.latest_data["action"] = action
        self.latest_data["buttons"] = buttons
    
    def get_action(self) -> tuple[np.ndarray, list]:
        """返回最新的动作和按钮状态"""
        with self.state_lock:
            return self.latest_data["action"].copy(), self.latest_data["buttons"].copy()
    
    def stop(self):
        """停止键盘监听"""
        self.listener.stop()
        print("🎮 键盘控制已停止")


if __name__ == "__main__":
    import time
    
    expert = KeyboardExpert()
    
    try:
        print("\n开始测试，按 Ctrl+C 退出...\n")
        while True:
            action, buttons = expert.get_action()
            if np.any(action != 0) or any(buttons):
                print(f"Action: {action.round(3)}, Buttons: {buttons}")
            time.sleep(0.1)
    except KeyboardInterrupt:
        expert.stop()
        print("\n测试结束")
