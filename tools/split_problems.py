#!/usr/bin/env python3
"""
题库拆分脚本：将大的problems.json拆分为按主题的多个文件

拆分后的文件结构：
assets/data/
  ├── problems/
  │   ├── 导数基础.json
  │   ├── 极限与连续.json
  │   └── 积分.json
  └── problems_index.json (索引文件)
"""

import json
from pathlib import Path
from collections import defaultdict

def split_problems():
    project_root = Path(__file__).parent.parent
    problems_file = project_root / "assets" / "data" / "problems.json"
    output_dir = project_root / "assets" / "data" / "problems"
    
    # 创建输出目录
    output_dir.mkdir(exist_ok=True)
    
    # 读取所有题目
    with open(problems_file, 'r', encoding='utf-8') as f:
        all_problems = json.load(f)
    
    print(f"📚 总题目数: {len(all_problems)}")
    
    # 按主题分组
    problems_by_topic = defaultdict(list)
    for problem in all_problems:
        topic = problem.get('topic', '未分类')
        problems_by_topic[topic].append(problem)
    
    # 写入各主题文件
    index_data = {}
    for topic, problems in problems_by_topic.items():
        # 安全的文件名
        safe_filename = topic.replace('/', '_').replace('\\', '_')
        topic_file = output_dir / f"{safe_filename}.json"
        
        with open(topic_file, 'w', encoding='utf-8') as f:
            json.dump(problems, f, ensure_ascii=False, indent=2)
        
        print(f"✅ {topic}: {len(problems)}道 → {topic_file.name}")
        
        # 记录到索引
        index_data[topic] = {
            'file': f"problems/{safe_filename}.json",
            'count': len(problems)
        }
    
    # 写入索引文件
    index_file = project_root / "assets" / "data" / "problems_index.json"
    with open(index_file, 'w', encoding='utf-8') as f:
        json.dump(index_data, f, ensure_ascii=False, indent=2)
    
    print(f"\n📋 索引文件已创建: {index_file.name}")
    print(f"📂 共拆分为 {len(problems_by_topic)} 个主题文件")

if __name__ == "__main__":
    print("=" * 60)
    print("题库拆分脚本")
    print("=" * 60)
    split_problems()
    print("=" * 60)

