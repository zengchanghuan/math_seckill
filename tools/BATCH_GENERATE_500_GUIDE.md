# 批量生成500道题目指南

## 📊 当前状态

- **当前题目数**: 30 道
- **目标题目数**: 500 道
- **需要新增**: 470 道

## 🎯 目标分布

| 主题 | 基础 | 进阶 | 小计 |
|------|------|------|------|
| 导数基础 | 100 | 70 | 170 |
| 极限与连续 | 100 | 65 | 165 |
| 积分 | 100 | 65 | 165 |
| **总计** | **300** | **200** | **500** |

## 🚀 方法 1: 使用 AI 批量生成（推荐）

### 前提条件

需要获取 AI API Key（任选其一）：
- **智谱AI** (推荐): https://open.bigmodel.cn/
- **通义千问**: https://dashscope.console.aliyun.com/
- **文心一言**: https://cloud.baidu.com/product/wenxinworkshop
- **Kimi**: https://platform.moonshot.cn/

### 使用步骤

1. **设置 API Key**（以智谱AI为例）：
   ```bash
   export ZHIPU_API_KEY='your-api-key-here'
   ```

2. **运行批量生成脚本**：
   ```bash
   cd /Users/zengchanghuan/Desktop/workspace/flutter/math_seckill
   python3 tools/batch_generate_500.py zhipu 10
   ```

   参数说明：
   - `zhipu`: AI 提供商（可选：zhipu, qwen, baidu, kimi, openai）
   - `10`: 每批生成数量（可选，默认10）

3. **等待生成完成**
   - 脚本会自动分批生成题目
   - 每批生成后会显示进度
   - 生成完成后会自动验证格式

### 注意事项

- API 调用可能需要一些时间（470道题大约需要 47-94 批）
- 建议在网络稳定的环境下运行
- 如果中途失败，可以重新运行脚本（会自动跳过已生成的题目）

---

## ✋ 方法 2: 手动生成（如果没有 API Key）

如果没有 AI API Key，可以：

1. **使用网页工具手动生成**：
   - 打开 `tools/manual_entry_helper.html`
   - 参考 `tools/MANUAL_ENTRY_GUIDE.md` 的详细指南

2. **使用 AI 网页版**：
   - 打开 `tools/ai_prompt_template.md`
   - 复制提示词到以下任一 AI 工具：
     - 智谱AI: https://open.bigmodel.cn/
     - 通义千问: https://tongyi.aliyun.com/
     - 文心一言: https://yiyan.baidu.com/
     - Kimi: https://kimi.moonshot.cn/
   - 复制生成的 JSON 并添加到 `assets/data/problems.json`

3. **分批手动添加**：
   - 每次生成 10-20 道题目
   - 使用验证工具检查格式：
     ```bash
     python3 tools/validate_problems.py
     ```

---

## 📝 方法 3: 混合方案（推荐）

1. **先手动生成一批**（到 100 道左右）
   - 确保题目质量
   - 覆盖主要知识点

2. **使用 AI 批量生成剩余题目**
   - 使用批量生成脚本
   - 快速扩展题库

---

## 🔍 验证题目

生成完成后，运行验证工具：

```bash
python3 tools/validate_problems.py
```

检查项：
- ✅ 题目格式正确
- ✅ LaTeX 语法正确
- ✅ 答案格式正确
- ✅ 选项数量正确

---

## 💡 提示

- **分批生成**: 如果 API 调用失败，可以分批生成（每次生成 50-100 道）
- **质量检查**: 生成后建议人工检查部分题目，确保质量
- **备份数据**: 生成前建议备份 `assets/data/problems.json`

---

## 🆘 遇到问题？

1. **API Key 错误**: 检查环境变量是否正确设置
2. **网络错误**: 检查网络连接，或更换 AI 提供商
3. **格式错误**: 运行验证工具检查，手动修复
4. **生成失败**: 可以重新运行脚本，会自动跳过已生成的题目





