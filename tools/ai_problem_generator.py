#!/usr/bin/env python3
"""
AI 题目生成工具
支持多个 AI 服务提供商（包括国内可用的服务）
"""

import json
import os
import sys
from typing import List, Dict, Optional
from pathlib import Path

# 支持的 AI 服务
SUPPORTED_PROVIDERS = {
    "openai": "OpenAI (ChatGPT)",
    "zhipu": "智谱AI (GLM)",
    "qwen": "通义千问 (阿里云)",
    "baidu": "文心一言 (百度)",
    "kimi": "月之暗面 (Kimi)",
}


def generate_problem_prompt(topic: str, difficulty: str, count: int = 1) -> str:
    """生成题目提示词"""
    return f"""请生成 {count} 道关于"{topic}"的微积分选择题，难度为"{difficulty}"。

要求：
1. 每道题目必须是选择题，包含4个选项（A、B、C、D）
2. 题目使用 LaTeX 格式，数学公式用 $...$ 包裹
3. 选项也使用 LaTeX 格式
4. 必须包含详细的解答过程（使用 LaTeX 格式）
5. 题目要有一定难度，符合"{difficulty}"水平

输出格式为 JSON 数组，每个题目包含以下字段：
- question: 题目内容（LaTeX 格式）
- options: 四个选项的数组（LaTeX 格式），正确答案放在第一个位置
- answer: 正确答案（"A"、"B"、"C" 或 "D"）
- solution: 详细解答（LaTeX 格式，使用 \\n 换行）
- tags: 标签数组

示例格式：
[
  {{
    "question": "求函数 $f(x) = x^2 + 3x + 2$ 的导数。",
    "options": [
      "$2x + 3$",
      "$x + 3$",
      "$2x^2 + 3$",
      "$x^2 + 3$"
    ],
    "answer": "A",
    "solution": "使用基本求导法则：\\n$f'(x) = \\frac{{d}}{{dx}}(x^2) + \\frac{{d}}{{dx}}(3x) + \\frac{{d}}{{dx}}(2)$\\n$f'(x) = 2x + 3 + 0 = 2x + 3$",
    "tags": ["导数", "多项式"]
  }}
]

请只输出 JSON 数组，不要包含其他文字说明。"""


def generate_with_openai(prompt: str) -> Optional[str]:
    """使用 OpenAI API"""
    try:
        import openai
        client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "你是一个专业的微积分教师，擅长出题和解答。"},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
        )
        return response.choices[0].message.content.strip()
    except ImportError:
        print("错误: 请安装 openai 库: pip install openai")
        return None
    except Exception as e:
        print(f"OpenAI API 错误: {e}")
        return None


def generate_with_zhipu(prompt: str) -> Optional[str]:
    """使用智谱AI (GLM) API"""
    try:
        from zhipuai import ZhipuAI
        client = ZhipuAI(api_key=os.getenv("ZHIPU_API_KEY"))

        response = client.chat.completions.create(
            model="glm-4",
            messages=[
                {"role": "system", "content": "你是一个专业的微积分教师，擅长出题和解答。"},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
        )
        return response.choices[0].message.content.strip()
    except ImportError:
        print("错误: 请安装 zhipuai 库: pip install zhipuai")
        return None
    except Exception as e:
        print(f"智谱AI API 错误: {e}")
        return None


def generate_with_qwen(prompt: str) -> Optional[str]:
    """使用通义千问 API"""
    try:
        from dashscope import Generation
        import dashscope

        dashscope.api_key = os.getenv("DASHSCOPE_API_KEY")

        response = Generation.call(
            model="qwen-turbo",
            messages=[
                {"role": "system", "content": "你是一个专业的微积分教师，擅长出题和解答。"},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
        )

        if response.status_code == 200:
            return response.output.choices[0].message.content.strip()
        else:
            print(f"通义千问 API 错误: {response.message}")
            return None
    except ImportError:
        print("错误: 请安装 dashscope 库: pip install dashscope")
        return None
    except Exception as e:
        print(f"通义千问 API 错误: {e}")
        return None


def generate_with_baidu(prompt: str) -> Optional[str]:
    """使用文心一言 API"""
    try:
        import requests

        api_key = os.getenv("BAIDU_API_KEY")
        secret_key = os.getenv("BAIDU_SECRET_KEY")

        if not api_key or not secret_key:
            print("错误: 请设置 BAIDU_API_KEY 和 BAIDU_SECRET_KEY")
            return None

        # 获取 access_token
        token_url = f"https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id={api_key}&client_secret={secret_key}"
        token_response = requests.post(token_url)
        access_token = token_response.json().get("access_token")

        if not access_token:
            print("错误: 无法获取 access_token")
            return None

        # 调用 API
        url = f"https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions?access_token={access_token}"
        payload = {
            "messages": [
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.7,
        }

        response = requests.post(url, json=payload)
        result = response.json()

        if "result" in result:
            return result["result"].strip()
        else:
            print(f"文心一言 API 错误: {result}")
            return None
    except ImportError:
        print("错误: 请安装 requests 库: pip install requests")
        return None
    except Exception as e:
        print(f"文心一言 API 错误: {e}")
        return None


def generate_with_kimi(prompt: str) -> Optional[str]:
    """使用月之暗面 (Kimi) API"""
    try:
        from openai import OpenAI

        # Kimi 使用 OpenAI 兼容的 API
        client = OpenAI(
            api_key=os.getenv("KIMI_API_KEY"),
            base_url="https://api.moonshot.cn/v1",
        )

        response = client.chat.completions.create(
            model="moonshot-v1-8k",
            messages=[
                {"role": "system", "content": "你是一个专业的微积分教师，擅长出题和解答。"},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
        )
        return response.choices[0].message.content.strip()
    except ImportError:
        print("错误: 请安装 openai 库: pip install openai")
        return None
    except Exception as e:
        print(f"Kimi API 错误: {e}")
        return None


def generate_problems_with_ai(topic: str, difficulty: str, count: int = 5, provider: str = "zhipu") -> List[Dict]:
    """使用指定 AI 服务生成题目"""
    prompt = generate_problem_prompt(topic, difficulty, count)

    content = None
    if provider == "openai":
        content = generate_with_openai(prompt)
    elif provider == "zhipu":
        content = generate_with_zhipu(prompt)
    elif provider == "qwen":
        content = generate_with_qwen(prompt)
    elif provider == "baidu":
        content = generate_with_baidu(prompt)
    elif provider == "kimi":
        content = generate_with_kimi(prompt)
    else:
        print(f"错误: 不支持的提供商 '{provider}'")
        print(f"支持的提供商: {', '.join(SUPPORTED_PROVIDERS.keys())}")
        return []

    if not content:
        return []

    # 尝试提取 JSON（可能包含 markdown 代码块）
    if "```json" in content:
        content = content.split("```json")[1].split("```")[0].strip()
    elif "```" in content:
        content = content.split("```")[1].split("```")[0].strip()

    try:
        problems = json.loads(content)
        return problems if isinstance(problems, list) else [problems]
    except json.JSONDecodeError as e:
        print(f"JSON 解析错误: {e}")
        print(f"原始内容: {content[:500]}...")
        return []


def format_problem_for_json(problem: Dict, start_id: int, topic: str, difficulty: str) -> Dict:
    """格式化题目为 JSON 格式"""
    options = problem.get("options", [])
    answer = problem.get("answer", "A")

    # 确保选项顺序正确
    answer_index = ord(answer.upper()) - ord("A")
    if answer_index < len(options):
        correct_option = options[answer_index]
        options = [correct_option] + [opt for i, opt in enumerate(options) if i != answer_index]
        answer = "A"

    return {
        "id": f"p{start_id}",
        "topic": topic,
        "difficulty": difficulty,
        "question": problem.get("question", ""),
        "answer": answer,
        "options": options[:4],
        "solution": problem.get("solution", ""),
        "tags": problem.get("tags", [])
    }


def merge_with_existing_problems(new_problems: List[Dict], json_file_path: str, topic: str, difficulty: str) -> List[Dict]:
    """合并新题目到现有题库"""
    if os.path.exists(json_file_path):
        with open(json_file_path, 'r', encoding='utf-8') as f:
            existing = json.load(f)
    else:
        existing = []

    # 获取下一个 ID
    if existing:
        last_id = int(existing[-1]["id"][1:])
        start_id = last_id + 1
    else:
        start_id = 1

    # 格式化新题目
    formatted_problems = []
    for i, problem in enumerate(new_problems):
        formatted = format_problem_for_json(problem, start_id + i, topic, difficulty)
        formatted_problems.append(formatted)

    # 合并
    all_problems = existing + formatted_problems

    return all_problems


def main():
    """主函数"""
    if len(sys.argv) < 3:
        print("用法: python ai_problem_generator.py <主题> <难度> [数量] [提供商]")
        print("示例: python ai_problem_generator.py '导数基础' '基础' 5 zhipu")
        print("\n支持的 AI 提供商:")
        for key, name in SUPPORTED_PROVIDERS.items():
            print(f"  {key}: {name}")
        print("\n环境变量设置:")
        print("  zhipu: ZHIPU_API_KEY")
        print("  qwen: DASHSCOPE_API_KEY")
        print("  baidu: BAIDU_API_KEY, BAIDU_SECRET_KEY")
        print("  kimi: KIMI_API_KEY")
        print("  openai: OPENAI_API_KEY")
        sys.exit(1)

    topic = sys.argv[1]
    difficulty = sys.argv[2]
    count = int(sys.argv[3]) if len(sys.argv) > 3 else 5
    provider = sys.argv[4] if len(sys.argv) > 4 else "zhipu"

    # 检查 API Key
    api_key_env = {
        "zhipu": "ZHIPU_API_KEY",
        "qwen": "DASHSCOPE_API_KEY",
        "baidu": "BAIDU_API_KEY",
        "kimi": "KIMI_API_KEY",
        "openai": "OPENAI_API_KEY",
    }

    if provider == "baidu":
        if not os.getenv("BAIDU_API_KEY") or not os.getenv("BAIDU_SECRET_KEY"):
            print("错误: 请设置 BAIDU_API_KEY 和 BAIDU_SECRET_KEY")
            sys.exit(1)
    elif provider in api_key_env:
        if not os.getenv(api_key_env[provider]):
            print(f"错误: 请设置环境变量 {api_key_env[provider]}")
            sys.exit(1)

    print(f"使用 {SUPPORTED_PROVIDERS.get(provider, provider)} 生成 {count} 道关于 '{topic}' 的 '{difficulty}' 难度题目...")

    # 生成题目
    problems = generate_problems_with_ai(topic, difficulty, count, provider)

    if not problems:
        print("生成失败，请检查 API Key 和网络连接")
        sys.exit(1)

    print(f"成功生成 {len(problems)} 道题目")

    # 合并到现有题库
    json_path = Path(__file__).parent.parent / "assets" / "data" / "problems.json"
    all_problems = merge_with_existing_problems(problems, str(json_path), topic, difficulty)

    # 保存
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(all_problems, f, ensure_ascii=False, indent=2)

    print(f"题目已保存到 {json_path}")
    print(f"题库现在共有 {len(all_problems)} 道题目")


if __name__ == "__main__":
    main()
