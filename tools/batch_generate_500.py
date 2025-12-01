#!/usr/bin/env python3
"""
批量生成500道题目的脚本
由于500道题数量很大，建议分批生成
"""

import json
import os
import sys
from pathlib import Path

# 导入AI生成工具
sys.path.insert(0, str(Path(__file__).parent))
from ai_problem_generator import generate_problems_with_ai, merge_with_existing_problems, SUPPORTED_PROVIDERS

# 目标分布
TARGET_DISTRIBUTION = {
    "导数基础": {"基础": 100, "进阶": 70},
    "极限与连续": {"基础": 100, "进阶": 65},
    "积分": {"基础": 100, "进阶": 65},
}

# 当前分布（需要计算）
CURRENT_DISTRIBUTION = {
    "导数基础": {"基础": 0, "进阶": 0},
    "极限与连续": {"基础": 0, "进阶": 0},
    "积分": {"基础": 0, "进阶": 0},
}


def count_current_problems(json_path: str):
    """统计当前题目分布"""
    if not os.path.exists(json_path):
        return

    with open(json_path, 'r', encoding='utf-8') as f:
        problems = json.load(f)

    for problem in problems:
        topic = problem.get("topic", "")
        difficulty = problem.get("difficulty", "")
        if topic in CURRENT_DISTRIBUTION and difficulty in CURRENT_DISTRIBUTION[topic]:
            CURRENT_DISTRIBUTION[topic][difficulty] += 1


def calculate_needed():
    """计算需要生成的题目数量"""
    needed = {}
    for topic in TARGET_DISTRIBUTION:
        needed[topic] = {}
        for difficulty in TARGET_DISTRIBUTION[topic]:
            current = CURRENT_DISTRIBUTION[topic][difficulty]
            target = TARGET_DISTRIBUTION[topic][difficulty]
            needed[topic][difficulty] = max(0, target - current)
    return needed


def batch_generate(json_path: str, provider: str = "zhipu", batch_size: int = 10):
    """批量生成题目"""
    needed = calculate_needed()

    print("=" * 60)
    print("题目生成计划")
    print("=" * 60)
    total_needed = 0
    for topic in needed:
        for difficulty in needed[topic]:
            count = needed[topic][difficulty]
            total_needed += count
            if count > 0:
                print(f"  {topic} - {difficulty}: 需要生成 {count} 道")
    print(f"\n总计需要生成: {total_needed} 道题目")
    print("=" * 60)

    if total_needed == 0:
        print("✅ 所有题目已足够，无需生成")
        return

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
            print("❌ 错误: 请设置 BAIDU_API_KEY 和 BAIDU_SECRET_KEY")
            print("\n提示: 如果没有 API Key，可以:")
            print("1. 使用手动生成方式（参考 tools/MANUAL_ENTRY_GUIDE.md）")
            print("2. 获取 API Key 后重新运行此脚本")
            return
    elif provider in api_key_env:
        if not os.getenv(api_key_env[provider]):
            print(f"❌ 错误: 请设置环境变量 {api_key_env[provider]}")
            print("\n提示: 如果没有 API Key，可以:")
            print("1. 使用手动生成方式（参考 tools/MANUAL_ENTRY_GUIDE.md）")
            print("2. 获取 API Key 后重新运行此脚本")
            return

    print(f"\n使用 {SUPPORTED_PROVIDERS.get(provider, provider)} 生成题目...")
    print(f"每批生成 {batch_size} 道题目\n")

    # 分批生成
    all_new_problems = []
    for topic in needed:
        for difficulty in needed[topic]:
            count = needed[topic][difficulty]
            if count <= 0:
                continue

            print(f"\n📝 生成: {topic} - {difficulty} ({count} 道)")

            # 分批生成
            batches = (count + batch_size - 1) // batch_size
            for batch_num in range(batches):
                batch_count = min(batch_size, count - batch_num * batch_size)
                print(f"  批次 {batch_num + 1}/{batches}: 生成 {batch_count} 道...", end=" ", flush=True)

                problems = generate_problems_with_ai(topic, difficulty, batch_count, provider)

                if problems:
                    # 添加 topic 和 difficulty 信息
                    for p in problems:
                        p['_topic'] = topic
                        p['_difficulty'] = difficulty
                    all_new_problems.extend(problems)
                    print(f"✅ 成功生成 {len(problems)} 道")
                else:
                    print(f"❌ 生成失败")
                    print("   提示: 可能是 API 调用失败，请检查网络和 API Key")

    if not all_new_problems:
        print("\n❌ 没有生成任何题目")
        return

    print(f"\n✅ 总共生成 {len(all_new_problems)} 道新题目")

    # 合并到现有题库
    print("\n正在合并到题库...")
    if os.path.exists(json_path):
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
    from ai_problem_generator import format_problem_for_json
    formatted_problems = []
    for i, problem in enumerate(all_new_problems):
        topic = problem.pop('_topic', '')
        difficulty = problem.pop('_difficulty', '')
        formatted = format_problem_for_json(problem, start_id + i, topic, difficulty)
        formatted_problems.append(formatted)

    # 合并
    all_problems = existing + formatted_problems

    # 保存
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(all_problems, f, ensure_ascii=False, indent=2)

    print(f"✅ 题目已保存到 {json_path}")
    print(f"📊 题库现在共有 {len(all_problems)} 道题目")

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
    """主函数"""
    if len(sys.argv) < 2:
        print("用法: python batch_generate_500.py <提供商> [批次大小]")
        print("示例: python batch_generate_500.py zhipu 10")
        print("\n支持的 AI 提供商:")
        for key, name in SUPPORTED_PROVIDERS.items():
            print(f"  {key}: {name}")
        print("\n如果没有 API Key，建议使用手动生成方式（参考 tools/MANUAL_ENTRY_GUIDE.md）")
        sys.exit(1)

    provider = sys.argv[1]
    batch_size = int(sys.argv[2]) if len(sys.argv) > 2 else 10

    json_path = Path(__file__).parent.parent / "assets" / "data" / "problems.json"

    # 统计当前题目
    print("正在统计当前题目分布...")
    count_current_problems(str(json_path))

    # 批量生成
    batch_generate(str(json_path), provider, batch_size)


if __name__ == "__main__":
    main()

