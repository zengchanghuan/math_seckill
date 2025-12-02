# 后端 v2.0 实现总结

## 实施完成日期
2025-12-02

---

## 核心目标

**提高学生真实考试通过率**

通过数据驱动的题库质量管理和个性化推荐系统，让学生在系统里的表现尽可能接近真实考试表现。

---

## 已完成功能

### ✅ 1. 扩展题目数据模型

**新增字段**：
- `knowledgePoints`: 知识点标签（如 ["导数", "单调性"]）
- `abilityTags`: 能力要求标签（如 ["apply", "analyze"]）
- `templateId`: 题型模板ID
- `source`: 来源标记（"generated"/"real_exam"/"manual"）
- `isRealExam`: 是否真题
- `totalAttempts`: 总作答次数
- `correctRate`: 正确率
- `discriminationIndex`: 区分度
- `avgTimeSeconds`: 平均耗时
- `reviewStatus`: 审核状态（"pending"/"approved"/"rejected"/"revision"）

**文件**: `schemas.py`

---

### ✅ 2. 题库管理系统

**功能**：
- 题目的CRUD操作
- 按知识点、难度、题型、审核状态查询
- 质量统计更新
- 题库统计报告

**文件**: `core/question_bank.py`

**API接口**:
- `GET /api/questions/stats`: 题库统计
- `GET /api/questions/{questionId}`: 获取题目
- `POST /api/questions`: 创建题目
- `PUT /api/questions/{questionId}`: 更新题目
- `DELETE /api/questions/{questionId}`: 删除题目

---

### ✅ 3. 作答记录追踪系统

**功能**：
- 记录每次学生答题（学生ID、题目ID、答案、是否正确、耗时）
- 查询学生/题目的作答记录
- 计算题目质量统计（正确率、区分度、选项分布）
- 计算学生能力画像

**区分度计算**：
- 将学生按总正确率排序
- 取前27%（高分组）和后27%（低分组）
- 区分度 = 高分组正确率 - 低分组正确率
- 区分度 > 0.6：优质题目
- 区分度 < 0.3：需要优化

**文件**: `core/answer_tracker.py`

**API接口**:
- `POST /api/answers/submit`: 提交答案
- `GET /api/answers/student/{studentId}`: 查询学生记录
- `GET /api/admin/question/{questionId}/stats`: 查询题目统计

---

### ✅ 4. 学生能力画像

**画像内容**：
```json
{
  "studentId": "user123",
  "knowledgeMastery": {
    "导数": 0.75,
    "极限": 0.60,
    "积分": 0.45
  },
  "questionTypeAccuracy": {
    "choice": 0.80,
    "fill": 0.65,
    "solution": 0.50
  },
  "difficultyAccuracy": {
    "L1": 0.90,
    "L2": 0.60,
    "L3": 0.30
  },
  "weakPoints": ["极限", "积分"],
  "predictedScore": 72.5
}
```

**预测分数算法**：
```
预测分数 = L1正确率 × 50 + L2正确率 × 35 + L3正确率 × 15
```
（基于考试蓝图：L1占50%，L2占35%，L3占15%）

**API接口**:
- `GET /api/student/{studentId}/profile`: 获取能力画像

---

### ✅ 5. 个性化推荐算法

**三种推荐模式**：

#### 模式1：薄弱知识点模式 (`weak_points`)
- 70%：薄弱知识点的L1+L2题（针对性突破）
- 20%：已掌握知识点的L2+L3题（巩固强项）
- 10%：随机新题（拓展视野）

#### 模式2：综合训练模式 (`comprehensive`)
- 按考试蓝图分布：L1(50%) + L2(35%) + L3(15%)
- 全面训练，适应考试节奏

#### 模式3：考前冲刺模式 (`exam_prep`)
- 80%：薄弱知识点的L2题（中档难度突破）
- 20%：高频错题重练（查漏补缺）

**推荐理由示例**：
```
基于您的学习数据：薄弱知识点：极限, 积分 | 巩固强项：导数 | 拓展新题
```

**文件**: `core/recommender.py`

**API接口**:
- `POST /api/student/recommend`: 推荐题目

---

### ✅ 6. 题型模板系统

**目的**：标准化题目生成，确保题目符合真题风格

**已实现模板**：
1. `trig_domain_range`: 三角函数的定义域和值域（L1, choice）
2. `trig_identity`: 三角恒等式化简（L2, fill）
3. `quadratic_discriminant`: 一元二次方程判别式（L1+L2, choice+fill）

**模板结构**：
```python
@dataclass
class ProblemTemplate:
    templateId: str
    category: TemplateCategory
    name: str
    description: str
    knowledgePoints: List[str]
    abilityTags: List[str]
    difficulties: List[str]
    questionTypes: List[str]
    generator: Callable  # 生成函数
    examples: List[str]
```

**使用方式**：
```python
from core.problem_templates import generate_from_template

problem = generate_from_template(
    template_id="trig_domain_range",
    difficulty="L1",
    question_type="choice"
)
```

**文件**: `core/problem_templates.py`

---

### ✅ 7. 审核流程

**审核状态**：
- `pending`: 待审核（新题默认状态）
- `approved`: 已通过（可用于推荐）
- `rejected`: 已拒绝（不可用）
- `revision`: 需修改（返回修改）

**审核流程**：
1. 生成/创建题目 → `pending`
2. 人工审核 → `approved` / `rejected` / `revision`
3. 如果是 `revision`，修改后重新提交 → `pending`
4. 只有 `approved` 的题目才会被推荐给学生

**API接口**:
- `POST /api/admin/review`: 审核题目

---

### ✅ 8. 数据迁移工具

**功能**：
- 将现有题库升级到v2格式
- 自动备份原文件
- 推断知识点和能力标签
- 生成迁移统计报告

**使用方式**：
```bash
cd /Users/zengchanghuan/Desktop/workspace/flutter/math_seckill_server/tools
python migrate_to_v2.py ../data/questions.json
```

**推断规则**：

*知识点推断*：
- 基于 `topic` 字段（如"三角函数" → ["三角函数"]）
- 基于 `tags` 字段
- 基于题干关键词（如"定义域" → ["定义域"]）

*能力标签推断*：
- L1 → ["memory", "understand"]
- L2 → ["apply", "analyze"]
- L3 → ["synthesize", "model"]
- 题型辅助推断（choice → "understand", fill/solution → "apply"）

**文件**: `tools/migrate_to_v2.py`

---

## 技术架构

```
后端 v2.0 架构图

                ┌─────────────────┐
                │   FastAPI App   │
                │   (main.py)     │
                └────────┬────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
    ┌────▼────┐    ┌────▼────┐    ┌────▼────┐
    │ 题库管理 │    │ 作答追踪 │    │ 推荐引擎 │
    │question │    │ answer  │    │recommend│
    │ _bank   │    │_tracker │    │   er    │
    └────┬────┘    └────┬────┘    └────┬────┘
         │               │               │
         │        ┌──────┴──────┐        │
         │        │             │        │
    ┌────▼────┐ ┌▼───────┐ ┌───▼───┐ ┌──▼────┐
    │questions│ │answer  │ │student│ │problem│
    │  .json  │ │_records│ │profile│ │template│
    └─────────┘ │ .json  │ │       │ │       │
                └────────┘ └───────┘ └───────┘

数据流：
1. 学生做题 → answer_tracker 记录
2. answer_tracker → 计算 question stats
3. answer_tracker → 计算 student profile
4. recommender → 基于 profile 推荐题目
5. question_bank → 管理题目质量
```

---

## 数据模型关系

```
Question (题目)
├── questionId
├── knowledgePoints[]
├── difficulty
├── type
├── totalAttempts ─┐
├── correctRate   ─┤ 由 AnswerRecord 计算
└── discrimination─┘

AnswerRecord (作答记录)
├── studentId ────────────┐
├── questionId           │
├── isCorrect            │
└── timeSpent            │
                         │
StudentProfile (学生画像)│
├── studentId ◄──────────┘
├── knowledgeMastery{}   ◄── 由 AnswerRecord 聚合
├── weakPoints[]         ◄── 由 knowledgeMastery 计算
└── predictedScore       ◄── 由 difficultyAccuracy 计算

Recommendation (推荐)
├── studentId
├── mode
└── questions[] ◄── 基于 StudentProfile + QuestionBank
```

---

## API完整列表

### 基础
- `GET /` - 健康检查

### 题库管理
- `GET /api/questions/stats` - 题库统计
- `GET /api/questions/{questionId}` - 获取题目
- `POST /api/questions` - 创建题目
- `PUT /api/questions/{questionId}` - 更新题目
- `DELETE /api/questions/{questionId}` - 删除题目

### 作答记录
- `POST /api/answers/submit` - 提交答案
- `GET /api/answers/student/{studentId}` - 学生作答记录

### 质量统计
- `GET /api/admin/question/{questionId}/stats` - 题目统计
- `POST /api/admin/question/update-stats` - 更新统计

### 学生画像
- `GET /api/student/{studentId}/profile` - 能力画像

### 个性化推荐
- `POST /api/student/recommend` - 推荐题目

### 审核管理
- `POST /api/admin/review` - 审核题目

---

## 关键算法

### 1. 区分度计算

```python
def calculate_discrimination(question_id, records):
    # 1. 计算每个学生的总正确率
    student_rates = {}
    for record in all_records:
        student_rates[student_id] = correct / total
    
    # 2. 排序并取前27%和后27%
    sorted_students = sorted(student_rates.items(), key=lambda x: x[1], reverse=True)
    top_27 = sorted_students[:int(len * 0.27)]
    low_27 = sorted_students[-int(len * 0.27):]
    
    # 3. 计算该题在两组的正确率
    top_correct_rate = ...
    low_correct_rate = ...
    
    # 4. 区分度 = 差值
    discrimination = top_correct_rate - low_correct_rate
    return discrimination
```

### 2. 学生画像计算

```python
def calculate_student_profile(student_id):
    records = get_student_records(student_id)
    
    # 按知识点统计
    for record in records:
        question = get_question(record.questionId)
        for kp in question.knowledgePoints:
            kp_stats[kp]["total"] += 1
            if record.isCorrect:
                kp_stats[kp]["correct"] += 1
    
    # 计算掌握度
    knowledge_mastery = {
        kp: stats["correct"] / stats["total"]
        for kp, stats in kp_stats.items()
    }
    
    # 找出薄弱点（正确率<0.6）
    weak_points = [kp for kp, rate in knowledge_mastery.items() if rate < 0.6]
    
    # 预测分数
    predicted_score = (
        difficulty_accuracy["L1"] * 50 +
        difficulty_accuracy["L2"] * 35 +
        difficulty_accuracy["L3"] * 15
    )
    
    return profile
```

### 3. 个性化推荐算法

```python
def recommend_for_weak_points(student_id, count=20):
    profile = calculate_student_profile(student_id)
    problems = []
    
    # 70%：薄弱知识点
    for kp in profile.weakPoints:
        l1_questions = query(knowledgePoints=[kp], difficulty="L1")
        l2_questions = query(knowledgePoints=[kp], difficulty="L2")
        problems.extend(sample(l1_questions + l2_questions, per_kp_count))
    
    # 20%：已掌握知识点
    strong_kp = random.choice([kp for kp, rate in profile.knowledgeMastery.items() if rate >= 0.75])
    l2_l3_questions = query(knowledgePoints=[strong_kp], difficulty=["L2", "L3"])
    problems.extend(sample(l2_l3_questions, consolidate_count))
    
    # 10%：随机新题
    unseen = [q for q in all_approved if q.questionId not in done_ids]
    problems.extend(sample(unseen, new_count))
    
    return problems[:count]
```

---

## 下一步计划

### 短期（1-2周）
- [ ] 收集真题并标注（目标：50道真题）
- [ ] 扩展题型模板库（目标：20+模板）
- [ ] 完善数据迁移（批量标注知识点）
- [ ] Flutter前端集成新API

### 中期（1个月）
- [ ] 模拟考试模式（完整试卷+严格计时）
- [ ] 错题本功能
- [ ] 学习报告（周报/月报）
- [ ] 题目难度自动校准

### 长期（3个月+）
- [ ] A/B测试不同推荐策略
- [ ] 预测分数准确度优化（需要大量数据）
- [ ] 大数据分析考试趋势
- [ ] 多用户协同学习

---

## 质量保障

### 题目质量监控指标

| 指标 | 理想范围 | 警告阈值 | 处理措施 |
|------|---------|----------|----------|
| 正确率偏差 | ±10% | ±15% | 调整难度标签 |
| 区分度 | >0.6 | <0.3 | 优化选项/题干 |
| 平均耗时 | 30-60s | >90s | 简化题干 |
| 选项分布 | >5% | <3% | 优化迷惑项 |

### 审核流程

```
生成题目 → pending
    ↓
人工审核
    ├→ approved → 进入题库
    ├→ rejected → 归档
    └→ revision → 修改后重审
```

### 数据驱动优化循环

```
收集作答数据 → 计算质量指标 → 质量检查
                                    ↓
更新题库 ←─ 优化题目 ←─ 标记问题题目
    ↓
重新审核
```

---

## 文档索引

- **API使用指南**: `docs/API_V2_GUIDE.md`
- **题库生成标准**: `docs/QUESTION_BANK_STANDARD.md`
- **实施计划**: `cursor-plan://微积分刷题App三标签结构.plan.md`

---

## 部署说明

### 启动服务器

```bash
cd /Users/zengchanghuan/Desktop/workspace/flutter/math_seckill_server
source venv/bin/activate
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 验证部署

```bash
curl http://localhost:8000/
# 应返回: {"status":"ok","version":"2.0.0"}

curl http://localhost:8000/api/questions/stats
# 应返回题库统计信息
```

### 数据迁移（如果需要）

```bash
cd tools
python migrate_to_v2.py ../data/questions.json
```

---

## 总结

✅ **8个核心功能全部完成**

✅ **数据模型、API接口、核心算法全部实现**

✅ **代码质量检查通过，无linter错误**

✅ **服务器成功启动，版本v2.0.0**

✅ **文档完善，包括API指南、实施计划、质量标准**

**系统已具备完整的题库质量管理和个性化推荐能力，可以开始收集数据并迭代优化！** 🚀

