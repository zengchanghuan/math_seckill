# 题库扩展状态

## 📊 当前状态

- **当前题目数**: 45 道
- **目标题目数**: 500 道
- **已完成进度**: 9.0%
- **还需生成**: 455 道

## 📈 题目分布

### 按主题分布
- 导数基础: 16 道
- 极限与连续: 13 道
- 积分: 16 道

### 按难度分布
- 基础: 26 道
- 进阶: 19 道

## 🎯 目标分布（500道）

| 主题 | 基础 | 进阶 | 小计 | 当前 | 还需 |
|------|------|------|------|------|------|
| 导数基础 | 100 | 70 | 170 | 16 | 154 |
| 极限与连续 | 100 | 65 | 165 | 13 | 152 |
| 积分 | 100 | 65 | 165 | 16 | 149 |
| **总计** | **300** | **200** | **500** | **45** | **455** |

## 🚀 后续方案

### 方案 1: 使用 AI 批量生成（推荐 ⭐⭐⭐⭐⭐）

**前提**: 需要 AI API Key

**步骤**:
1. 获取 API Key（推荐智谱AI，国内可用）:
   - 智谱AI: https://open.bigmodel.cn/
   - 通义千问: https://dashscope.console.aliyun.com/
   - 文心一言: https://cloud.baidu.com/product/wenxinworkshop
   - Kimi: https://platform.moonshot.cn/

2. 设置环境变量:
   ```bash
   export ZHIPU_API_KEY='your-api-key-here'
   ```

3. 运行批量生成脚本:
   ```bash
   cd /Users/zengchanghuan/Desktop/workspace/flutter/math_seckill
   python3 tools/batch_generate_500.py zhipu 10
   ```

   脚本会自动:
   - 统计当前题目分布
   - 计算需要生成的题目数量
   - 分批生成题目（每批10道）
   - 自动合并到题库
   - 验证题目格式

**优势**:
- ✅ 自动化，快速生成
- ✅ 自动验证格式
- ✅ 自动合并到题库
- ✅ 支持断点续传（可以重新运行）

---

### 方案 2: 使用网页版 AI 工具手动生成

**步骤**:
1. 打开 `tools/ai_prompt_template.md`
2. 复制提示词到以下任一 AI 工具:
   - 智谱AI: https://open.bigmodel.cn/
   - 通义千问: https://tongyi.aliyun.com/
   - 文心一言: https://yiyan.baidu.com/
   - Kimi: https://kimi.moonshot.cn/
3. 修改主题和难度，生成 10-20 道题目
4. 复制生成的 JSON
5. 手动添加到 `assets/data/problems.json`
6. 运行验证工具:
   ```bash
   python3 tools/validate_problems.py
   ```

**优势**:
- ✅ 不需要 API Key
- ✅ 可以控制题目质量
- ✅ 免费使用

**劣势**:
- ❌ 需要手动操作
- ❌ 速度较慢

---

### 方案 3: 使用网页表单手动录入

**步骤**:
1. 打开 `tools/manual_entry_helper.html`
2. 参考 `tools/MANUAL_ENTRY_GUIDE.md` 的详细指南
3. 逐题录入

**优势**:
- ✅ 完全控制题目内容
- ✅ 不需要 API Key

**劣势**:
- ❌ 速度最慢
- ❌ 工作量大

---

## 💡 推荐方案

**最佳实践**: 混合方案

1. **先手动生成一批**（已完成，45道）
   - 确保题目质量
   - 覆盖主要知识点

2. **使用 AI 批量生成剩余题目**（推荐）
   - 获取 API Key
   - 运行批量生成脚本
   - 快速扩展到 500 道

3. **人工检查部分题目**
   - 确保题目质量
   - 检查 LaTeX 格式
   - 验证答案正确性

---

## 📝 注意事项

1. **题目格式**: 所有题目必须符合 JSON 格式，包含必需字段
2. **LaTeX 格式**: 数学公式必须用 `$...$` 包裹
3. **答案格式**: 必须是 A、B、C 或 D
4. **选项数量**: 必须正好 4 个选项
5. **ID 连续**: 题目 ID 必须连续递增（p1, p2, p3, ...）

---

## 🔍 验证工具

生成题目后，务必运行验证工具:

```bash
python3 tools/validate_problems.py
```

检查项:
- ✅ 题目格式正确
- ✅ LaTeX 语法正确
- ✅ 答案格式正确
- ✅ 选项数量正确
- ✅ ID 连续递增

---

## 📚 相关文档

- `tools/BATCH_GENERATE_500_GUIDE.md` - 批量生成详细指南
- `tools/ai_prompt_template.md` - AI 提示词模板
- `tools/MANUAL_ENTRY_GUIDE.md` - 手动录入指南
- `tools/manual_entry_helper.html` - 手动录入辅助工具

---

**最后更新**: 2024-12-01
**当前进度**: 45/500 (9.0%)

