# 题库管理工具

## 工具列表

### 1. AI 题目生成器 (`ai_problem_generator.py`)

支持多个 AI 服务提供商批量生成微积分选择题，**特别适合中国大陆用户**。

**支持的 AI 服务：**
- **智谱AI (GLM)** - 推荐，国内可用，API 稳定
- **通义千问 (阿里云)** - 国内可用，质量好
- **文心一言 (百度)** - 国内可用
- **月之暗面 (Kimi)** - 国内可用，长文本能力强
- **OpenAI (ChatGPT)** - 需要科学上网

**使用方法：**

```bash
# 安装依赖
pip install -r tools/requirements.txt

# 智谱AI (推荐)
export ZHIPU_API_KEY='your-api-key-here'
python tools/ai_problem_generator.py "导数基础" "基础" 10 zhipu

# 通义千问
export DASHSCOPE_API_KEY='your-api-key-here'
python tools/ai_problem_generator.py "导数基础" "基础" 10 qwen

# 文心一言
export BAIDU_API_KEY='your-api-key'
export BAIDU_SECRET_KEY='your-secret-key'
python tools/ai_problem_generator.py "导数基础" "基础" 10 baidu

# Kimi
export KIMI_API_KEY='your-api-key-here'
python tools/ai_problem_generator.py "导数基础" "基础" 10 kimi
```

**参数：**
- 主题：如 "导数基础"、"极限与连续"、"积分" 等
- 难度：如 "基础"、"进阶"
- 数量：要生成的题目数量（可选，默认 5）
- 提供商：AI 服务提供商（可选，默认 zhipu）

### 2. 题目验证工具 (`validate_problems.py`)

验证 `problems.json` 中的题目格式是否正确。

**使用方法：**
```bash
python tools/validate_problems.py
```

**检查项：**
- 必需字段是否存在
- ID 格式是否正确
- 答案格式是否正确（A/B/C/D）
- 选项数量是否为 4 个
- LaTeX 格式是否有误
- 显示题目统计信息

### 3. AI 提示词模板 (`ai_prompt_template.md`)

包含用于 ChatGPT/Claude 等 AI 工具的提示词模板，可以直接复制使用。

## 快速录入流程

### 方法 1: 使用 AI 工具直接生成（最简单，推荐）

1. 打开 `ai_prompt_template.md`
2. 复制提示词到以下任一 AI 工具：
   - 智谱AI: https://open.bigmodel.cn/
   - 通义千问: https://tongyi.aliyun.com/
   - 文心一言: https://yiyan.baidu.com/
   - Kimi: https://kimi.moonshot.cn/
3. 修改主题和难度
4. 复制生成的 JSON
5. 手动添加到 `assets/data/problems.json`

### 方法 2: 使用 Python 脚本（自动化，推荐）

1. 安装依赖：`pip install -r tools/requirements.txt`
2. 选择 AI 服务并获取 API Key（见 `ai_prompt_template.md`）
3. 设置环境变量（如 `export ZHIPU_API_KEY='your-key'`）
4. 运行脚本生成题目
5. 使用验证工具检查格式

### 方法 3: 手动录入

直接编辑 `assets/data/problems.json`，参考现有题目格式。

## 题目格式

```json
{
  "id": "p1",
  "topic": "导数基础",
  "difficulty": "基础",
  "question": "求函数 $f(x) = x^2 + 3x + 2$ 的导数。",
  "answer": "A",
  "options": [
    "$2x + 3$",
    "$x + 3$",
    "$2x^2 + 3$",
    "$x^2 + 3$"
  ],
  "solution": "使用基本求导法则：\\n$f'(x) = \\frac{d}{dx}(x^2) + \\frac{d}{dx}(3x) + \\frac{d}{dx}(2)$\\n$f'(x) = 2x + 3 + 0 = 2x + 3$",
  "tags": ["导数", "多项式"]
}
```

## 注意事项

1. **LaTeX 格式**：所有数学公式必须用 `$...$` 包裹
2. **答案位置**：正确答案应该放在 options 数组的第一个位置，answer 字段设为 "A"
3. **换行符**：solution 中使用 `\n` 表示换行
4. **ID 格式**：必须从 "p1" 开始，按顺序递增
5. **选项数量**：必须正好 4 个选项

## 下一步：AI 自动生成

未来可以实现：
- 基于知识点的自动题目生成
- 题目难度自动评估
- 题目质量自动检查
- 批量导入和导出功能

