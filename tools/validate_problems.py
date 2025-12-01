#!/usr/bin/env python3
"""
题目验证工具
检查 problems.json 中的题目格式是否正确
"""

import json
import sys
from pathlib import Path


def validate_problem(problem: dict, index: int) -> list:
    """验证单个题目"""
    errors = []

    required_fields = ["id", "topic", "difficulty", "question", "answer", "options", "solution"]
    for field in required_fields:
        if field not in problem:
            errors.append(f"题目 {index}: 缺少必需字段 '{field}'")

    # 检查 ID 格式
    if "id" in problem and not problem["id"].startswith("p"):
        errors.append(f"题目 {index}: ID 格式错误，应以 'p' 开头")

    # 检查答案格式
    if "answer" in problem:
        if problem["answer"] not in ["A", "B", "C", "D"]:
            errors.append(f"题目 {index}: 答案必须是 A、B、C 或 D")

    # 检查选项数量
    if "options" in problem:
        if len(problem["options"]) != 4:
            errors.append(f"题目 {index}: 选项数量必须是 4 个，当前有 {len(problem['options'])} 个")

        # 检查答案对应的选项是否存在
        if "answer" in problem:
            answer_index = ord(problem["answer"].upper()) - ord("A")
            if answer_index >= len(problem["options"]):
                errors.append(f"题目 {index}: 答案 '{problem['answer']}' 对应的选项不存在")

    # 检查 LaTeX 格式（简单检查）
    if "question" in problem:
        question = problem["question"]
        # 检查是否有未闭合的 $ 符号
        if question.count("$") % 2 != 0:
            errors.append(f"题目 {index}: 题目中的 LaTeX 格式可能有误（$ 符号未闭合）")

    return errors


def main():
    """主函数"""
    json_path = Path(__file__).parent.parent / "assets" / "data" / "problems.json"

    if not json_path.exists():
        print(f"错误: 找不到文件 {json_path}")
        sys.exit(1)

    with open(json_path, 'r', encoding='utf-8') as f:
        problems = json.load(f)

    print(f"正在验证 {len(problems)} 道题目...")

    all_errors = []
    for i, problem in enumerate(problems, 1):
        errors = validate_problem(problem, i)
        if errors:
            all_errors.extend(errors)

    if all_errors:
        print("\n发现以下错误：")
        for error in all_errors:
            print(f"  - {error}")
        sys.exit(1)
    else:
        print("✓ 所有题目验证通过！")

        # 统计信息
        topics = {}
        difficulties = {}
        for problem in problems:
            topic = problem.get("topic", "未知")
            difficulty = problem.get("difficulty", "未知")
            topics[topic] = topics.get(topic, 0) + 1
            difficulties[difficulty] = difficulties.get(difficulty, 0) + 1

        print("\n题目统计：")
        print(f"  总题目数: {len(problems)}")
        print("\n  按主题分布：")
        for topic, count in sorted(topics.items()):
            print(f"    {topic}: {count} 道")
        print("\n  按难度分布：")
        for difficulty, count in sorted(difficulties.items()):
            print(f"    {difficulty}: {count} 道")


if __name__ == "__main__":
    main()



