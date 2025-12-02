#!/usr/bin/env python3
"""
数据迁移脚本：将现有题目数据从旧格式迁移到新格式

变更：
1. 难度：基础 → L1，进阶 → L2
2. 添加 type 字段：默认为 "choice"（选择题）
3. 添加 answerType 和 answerExpr 字段：选择题为 None
4. 备份原文件
"""

import json
import shutil
from datetime import datetime
from pathlib import Path

def migrate_problems():
    # 文件路径
    project_root = Path(__file__).parent.parent
    problems_file = project_root / "assets" / "data" / "problems.json"

    if not problems_file.exists():
        print(f"错误: 文件不存在 {problems_file}")
        return

    # 备份原文件
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = problems_file.parent / f"problems_backup_{timestamp}.json"
    shutil.copy2(problems_file, backup_file)
    print(f"✅ 已备份原文件到: {backup_file}")

    # 读取现有数据
    with open(problems_file, 'r', encoding='utf-8') as f:
        problems = json.load(f)

    print(f"📊 原有题目数量: {len(problems)}")

    # 迁移数据
    migrated_count = 0
    for problem in problems:
        # 迁移难度
        old_difficulty = problem.get('difficulty', '基础')
        if old_difficulty == '基础':
            problem['difficulty'] = 'L1'
            migrated_count += 1
        elif old_difficulty == '进阶':
            problem['difficulty'] = 'L2'
            migrated_count += 1
        elif old_difficulty not in ['L1', 'L2', 'L3']:
            # 未知的难度，默认为L1
            print(f"⚠️  题目 {problem['id']} 的难度 '{old_difficulty}' 未识别，设置为 L1")
            problem['difficulty'] = 'L1'
            migrated_count += 1

        # 添加 type 字段（如果不存在）
        if 'type' not in problem:
            # 判断是否为选择题：有options且answer是A/B/C/D
            has_options = problem.get('options') and len(problem.get('options', [])) > 0
            answer = problem.get('answer', '')
            is_choice = has_options and answer.upper() in ['A', 'B', 'C', 'D']

            problem['type'] = 'choice' if is_choice else 'choice'  # 默认都设为choice

        # 添加 answerType 和 answerExpr（如果不存在）
        if 'answerType' not in problem:
            problem['answerType'] = None  # 选择题不需要
        if 'answerExpr' not in problem:
            problem['answerExpr'] = None  # 选择题不需要

    # 写回文件
    with open(problems_file, 'w', encoding='utf-8') as f:
        json.dump(problems, f, ensure_ascii=False, indent=2)

    print(f"✅ 迁移完成:")
    print(f"   - 总题目数: {len(problems)}")
    print(f"   - 已迁移题目: {migrated_count}")
    print(f"   - 保存到: {problems_file}")

    # 统计新难度分布
    difficulty_count = {}
    type_count = {}
    for problem in problems:
        diff = problem.get('difficulty', 'L1')
        difficulty_count[diff] = difficulty_count.get(diff, 0) + 1

        ptype = problem.get('type', 'choice')
        type_count[ptype] = type_count.get(ptype, 0) + 1

    print("\n📈 难度分布:")
    for diff, count in sorted(difficulty_count.items()):
        percentage = count / len(problems) * 100
        print(f"   {diff}: {count} 题 ({percentage:.1f}%)")

    print("\n📊 题型分布:")
    for ptype, count in sorted(type_count.items()):
        percentage = count / len(problems) * 100
        print(f"   {ptype}: {count} 题 ({percentage:.1f}%)")

if __name__ == "__main__":
    print("=" * 60)
    print("题目数据迁移脚本")
    print("=" * 60)
    migrate_problems()
    print("=" * 60)

