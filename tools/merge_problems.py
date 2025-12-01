#!/usr/bin/env python3
"""
合并新题目到题库的脚本
用法: python3 merge_problems.py <新题目JSON文件> <主题> <难度>
示例: python3 merge_problems.py temp_problems.json "导数基础" "基础"
"""

import json
import sys
from pathlib import Path


def merge_problems(new_problems_file: str, topic: str, difficulty: str):
    """合并新题目到题库"""
    # 读取新题目
    with open(new_problems_file, 'r', encoding='utf-8') as f:
        new_problems = json.load(f)

    if not isinstance(new_problems, list):
        print("错误: 新题目文件必须包含 JSON 数组")
        sys.exit(1)

    # 读取现有题库
    json_path = Path(__file__).parent.parent / "assets" / "data" / "problems.json"
    if json_path.exists():
        with open(json_path, 'r', encoding='utf-8') as f:
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
        # 确保选项顺序正确（正确答案在第一个位置）
        options = problem.get("options", [])
        answer = problem.get("answer", "A")

        answer_index = ord(answer.upper()) - ord("A")
        if answer_index < len(options):
            correct_option = options[answer_index]
            # 将正确答案移到第一个位置
            other_options = [opt for j, opt in enumerate(options) if j != answer_index]
            options = [correct_option] + other_options
            answer = "A"

        formatted = {
            "id": f"p{start_id + i}",
            "topic": topic,
            "difficulty": difficulty,
            "question": problem.get("question", ""),
            "answer": answer,
            "options": options[:4],  # 确保只有4个选项
            "solution": problem.get("solution", ""),
            "tags": problem.get("tags", [])
        }
        formatted_problems.append(formatted)

    # 合并
    all_problems = existing + formatted_problems

    # 保存
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(all_problems, f, ensure_ascii=False, indent=2)

    print(f"✅ 成功添加 {len(formatted_problems)} 道题目")
    print(f"📊 题库现在共有 {len(all_problems)} 道题目")
    print(f"📁 已保存到 {json_path}")

    # 验证
    print("\n正在验证题目格式...")
    import subprocess
    result = subprocess.run(
        [sys.executable, str(Path(__file__).parent / "validate_problems.py")],
        capture_output=True,
        text=True
    )
    print(result.stdout)
    if result.returncode != 0:
        print("⚠️  验证过程中发现一些问题，请检查")


def main():
    if len(sys.argv) < 4:
        print("用法: python3 merge_problems.py <新题目JSON文件> <主题> <难度>")
        print('示例: python3 merge_problems.py temp_problems.json "导数基础" "基础"')
        print("\n主题选项:")
        print("  - 导数基础")
        print("  - 极限与连续")
        print("  - 积分")
        print("\n难度选项:")
        print("  - 基础")
        print("  - 进阶")
        sys.exit(1)

    new_problems_file = sys.argv[1]
    topic = sys.argv[2]
    difficulty = sys.argv[3]

    if not Path(new_problems_file).exists():
        print(f"错误: 文件不存在: {new_problems_file}")
        sys.exit(1)

    merge_problems(new_problems_file, topic, difficulty)


if __name__ == "__main__":
    main()

