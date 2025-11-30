# AI 题目生成提示词模板

## 快速使用方法（适合中国大陆用户）

### 推荐使用的 AI 服务

1. **智谱AI (GLM)** - 推荐，国内可用，API 稳定
2. **通义千问 (阿里云)** - 国内可用，质量好
3. **文心一言 (百度)** - 国内可用
4. **月之暗面 (Kimi)** - 国内可用，长文本能力强
5. **ChatGPT** - 需要科学上网

### 方法 1: 使用 AI 工具直接生成（最简单）

直接复制下面的提示词到以下任一 AI 工具中：
- 智谱AI: https://open.bigmodel.cn/
- 通义千问: https://tongyi.aliyun.com/
- 文心一言: https://yiyan.baidu.com/
- Kimi: https://kimi.moonshot.cn/

---

**提示词：**

```
请生成 10 道关于"导数基础"的微积分选择题，难度为"基础"。

要求：
1. 每道题目必须是选择题，包含4个选项（A、B、C、D）
2. 题目使用 LaTeX 格式，数学公式用 $...$ 包裹
3. 选项也使用 LaTeX 格式
4. 必须包含详细的解答过程（使用 LaTeX 格式）
5. 题目要有一定难度，符合"基础"水平

输出格式为 JSON 数组，每个题目包含以下字段：
- question: 题目内容（LaTeX 格式）
- options: 四个选项的数组（LaTeX 格式），正确答案放在第一个位置
- answer: 正确答案（"A"、"B"、"C" 或 "D"）
- solution: 详细解答（LaTeX 格式，使用 \n 换行）
- tags: 标签数组

示例格式：
[
  {
    "question": "求函数 $f(x) = x^2 + 3x + 2$ 的导数。",
    "options": [
      "$2x + 3$",
      "$x + 3$",
      "$2x^2 + 3$",
      "$x^2 + 3$"
    ],
    "answer": "A",
    "solution": "使用基本求导法则：\n$f'(x) = \frac{d}{dx}(x^2) + \frac{d}{dx}(3x) + \frac{d}{dx}(2)$\n$f'(x) = 2x + 3 + 0 = 2x + 3$",
    "tags": ["导数", "多项式"]
  }
]

请只输出 JSON 数组，不要包含其他文字说明。
```

**使用步骤：**
1. 复制上面的提示词
2. 修改主题（如"导数基础"）和难度（如"基础"）
3. 修改题目数量（如 10 道）
4. 粘贴到 AI 工具中
5. 复制生成的 JSON
6. 手动添加到 `assets/data/problems.json`

---

### 方法 2: 使用 Python 脚本（自动化）

#### 2.1 智谱AI (推荐)

1. 注册并获取 API Key: https://open.bigmodel.cn/
2. 安装依赖：
```bash
pip install zhipuai
```

3. 设置 API Key：
```bash
export ZHIPU_API_KEY='your-api-key-here'
```

4. 运行脚本：
```bash
python tools/ai_problem_generator.py "导数基础" "基础" 10 zhipu
```

#### 2.2 通义千问

1. 注册并获取 API Key: https://dashscope.console.aliyun.com/
2. 安装依赖：
```bash
pip install dashscope
```

3. 设置 API Key：
```bash
export DASHSCOPE_API_KEY='your-api-key-here'
```

4. 运行脚本：
```bash
python tools/ai_problem_generator.py "导数基础" "基础" 10 qwen
```

#### 2.3 文心一言

1. 注册并获取 API Key: https://cloud.baidu.com/product/wenxinworkshop
2. 安装依赖：
```bash
pip install requests
```

3. 设置 API Key：
```bash
export BAIDU_API_KEY='your-api-key'
export BAIDU_SECRET_KEY='your-secret-key'
```

4. 运行脚本：
```bash
python tools/ai_problem_generator.py "导数基础" "基础" 10 baidu
```

#### 2.4 月之暗面 (Kimi)

1. 注册并获取 API Key: https://platform.moonshot.cn/
2. 安装依赖：
```bash
pip install openai
```

3. 设置 API Key：
```bash
export KIMI_API_KEY='your-api-key-here'
```

4. 运行脚本：
```bash
python tools/ai_problem_generator.py "导数基础" "基础" 10 kimi
```

## 常用主题和难度

### 主题列表
- 导数基础
- 极限与连续
- 积分
- 微分方程
- 级数
- 多元函数
- 向量分析

### 难度级别
- 基础
- 进阶

## 批量生成建议

1. **按主题批量生成**：每个主题生成 20-30 道题目
2. **难度分布**：基础题目占 60%，进阶题目占 40%
3. **题目类型**：确保覆盖该主题的主要知识点
4. **质量检查**：生成后使用验证工具检查格式

## 验证和检查

生成题目后，运行验证工具：
```bash
python tools/validate_problems.py
```

检查项：
1. LaTeX 格式是否正确
2. 答案是否正确
3. 选项是否合理（干扰项要有一定迷惑性）
4. 解答过程是否详细清晰

## API Key 获取链接

- **智谱AI**: https://open.bigmodel.cn/ (推荐，国内稳定)
- **通义千问**: https://dashscope.console.aliyun.com/
- **文心一言**: https://cloud.baidu.com/product/wenxinworkshop
- **Kimi**: https://platform.moonshot.cn/
- **OpenAI**: https://platform.openai.com/ (需要科学上网)
