# 提高考试通过率的题库生成标准

> 核心理念：让学生在系统里的表现尽可能接近真实考试表现

---

## 一、核心目标：减小偏差

### 什么叫"偏差小"？

让两件事更接近：
- **学生在系统里的表现**
- **学生在真实考试里的表现**

### 两个维度的"贴近"

1. **考点贴近**
   - 练的知识点和真实考试的知识点分布接近
   - 不偏题、不押题、不遗漏

2. **题感贴近**
   - 题型、难度、表述风格、综合度和考试相似
   - 让学生有"真实考试"的感觉

---

## 二、建立"考试蓝图"

### 从"考试标准"出发，而非"生成题目"出发

#### 考试蓝图包含：

1. **知识点维度**
   - 章节划分
   - 子知识点细分
   - 必考点 vs 常考点 vs 偶考点

2. **题型维度**
   - 选择题：单选/多选
   - 填空题：数值/表达式/区间
   - 解答题：证明/计算/应用

3. **难度分层**
   - 基础题（L1）：会做就得分，占50%
   - 中档题（L2）：区分度题目，占35%
   - 压轴题（L3）：拔高题目，占15%

4. **能力要求**
   - 记忆：公式、定义
   - 理解：概念辨析
   - 应用：套公式解题
   - 综合：多知识点融合
   - 建模：实际问题数学化

5. **分值结构**
   - 各部分占分比例
   - 时间分配建议

### 蓝图示例（高等数学）

```
总分：100分，时间：120分钟

第一部分：选择题（40分，40分钟）
  - 基础概念：20分（L1）
  - 计算应用：15分（L2）
  - 综合判断：5分（L3）

第二部分：填空题（30分，30分钟）
  - 直接计算：15分（L1）
  - 方法应用：12分（L2）
  - 综合填空：3分（L3）

第三部分：解答题（30分，50分钟）
  - 基础证明：10分（L1+L2）
  - 综合计算：15分（L2+L3）
  - 压轴大题：5分（L3）
```

---

## 三、用"真题 + 真题拆解"作为标尺

### 1. 真题做底座

**收集工作**：
- 近3-5年真题
- 权威模拟卷
- 名校期末试卷

**标注工作**：
```json
{
  "questionId": "real_2023_choice_01",
  "source": "2023年专升本真题",
  "knowledgePoints": ["导数", "单调性"],
  "questionType": "choice",
  "difficulty": "L2",
  "ability": ["理解", "应用"],
  "score": 4,
  "avgCorrectRate": 0.65,  // 历年统计数据
  "discriminationIndex": 0.45  // 区分度
}
```

**统计分析**：
- 各知识点出现频率
- 各题型分值占比
- 难度分布
- 常见陷阱和易错点

### 2. 真题拆解成"题型模板"

**抽象过程**：
```
真题：求函数 f(x) = x³ - 3x² + 2 在区间[0,3]上的最大值

模板：
{
  "templateId": "derivative_max_min_interval",
  "pattern": "三次多项式函数在闭区间上求最值",
  "steps": [
    "求导数",
    "解导数方程找驻点",
    "比较端点和驻点的函数值"
  ],
  "variableParams": {
    "degree": [2, 3, 4],
    "coefficients": "random(-5, 5)",
    "interval": "[a, b] where 0 <= a < b <= 5"
  }
}
```

**使用模板生成**：
- 保留解题思路和考察能力
- 改变具体数值和表述
- 确保难度一致

---

## 四、题目生成的严格约束

### 1. 题目元信息要求（必填字段）

```json
{
  "questionId": "gen_deriv_001",
  "knowledgePoints": ["导数", "单调性"],
  "questionType": "choice",
  "difficulty": "L2",
  "ability": ["理解", "应用"],
  "templateId": "derivative_monotonicity",
  "qualityScore": null,  // 待统计
  "correctRate": null,   // 待统计
  "discriminationIndex": null  // 待统计
}
```

### 2. 生成题的质量检查清单

#### 自动检查：
- [ ] 知识点标签是否正确
- [ ] 难度估计是否在合理范围
- [ ] 选项是否有重复
- [ ] 答案是否唯一且可验证
- [ ] LaTeX格式是否正确

#### 人工审核：
- [ ] 题干是否清晰无歧义
- [ ] 错误选项是否有迷惑性
- [ ] 是否符合真题表述风格
- [ ] 知识点是否越界
- [ ] 综合度是否适当

### 3. 题目风格校正规则

**题干要求**：
- 长度：与本地区真题接近（不要太长或太短）
- 语言：学术规范，避免口语化
- 背景：贴近学生认知（不要太抽象或太商业化）

**选项要求**（选择题）：
- 迷惑性：常见错误思路应该在选项中
- 排除法难度：不能一眼排除3个
- 长度均衡：选项长度不要差异过大

---

## 五、数据驱动的质量校准

### 1. 收集学生作答数据

**关键指标**：
```python
{
  "questionId": "gen_deriv_001",
  "totalAttempts": 1523,        # 总作答次数
  "correctCount": 892,          # 正确次数
  "correctRate": 0.586,         # 正确率
  "avgTime": 45.2,              # 平均耗时（秒）
  "topStudentCorrectRate": 0.95,  # 高分组正确率
  "lowStudentCorrectRate": 0.28,  # 低分组正确率
  "discriminationIndex": 0.67,    # 区分度
  "optionDistribution": {         # 选项分布
    "A": 0.12,
    "B": 0.25,
    "C": 0.586,  # 正确答案
    "D": 0.044
  }
}
```

### 2. 质量评估标准

#### 难度符合度
```python
if abs(correctRate - expectedCorrectRate) > 0.15:
    # 偏差超过15%，需要调整难度标签或题目本身
    flag_for_review()
```

#### 区分度检查
```python
discrimination = topGroupCorrectRate - lowGroupCorrectRate

if discrimination < 0.3:
    # 区分度过低，无法区分好学生和差学生
    flag_as_low_quality()
elif discrimination > 0.7:
    # 区分度很好
    mark_as_high_quality()
```

#### 选项合理性
```python
for option, rate in optionDistribution.items():
    if option != correctAnswer and rate < 0.05:
        # 某个错误选项几乎无人选，说明太明显
        suggest_improve_option(option)
```

### 3. 自动调整策略

**题目标签调整**：
- 实际正确率0.85，标记为L1 → 改标为L1
- 实际正确率0.35，标记为L1 → 改标为L2或L3

**题目下架**：
- 区分度<0.2 且 正确率异常（<0.1 或 >0.95）
- 学生反馈有歧义（需要人工确认）

**题目优化**：
- 某个选项无人选 → 优化该选项
- 平均耗时过长 → 简化题干

---

## 六、训练结构设计

### 三层训练体系

#### 第1层：知识点专项训练
```
目标：把「不会」变成「会」

模式：
  - 按章节/知识点分类
  - 同一知识点集中练习
  - 即时反馈 + 解析
  - 错题重练机制

题目要求：
  - 覆盖该知识点的所有考法
  - 难度递进（L1→L2→L3）
  - 每个知识点至少20道题
```

#### 第2层：真题/仿真卷训练
```
目标：适应"整套卷的节奏"

模式：
  - 完全模拟真实考试
  - 严格时间限制
  - 禁止中途查看解析
  - 分Section（选择/填空/解答）

题目要求：
  - 题型分布与真题一致
  - 难度分布与真题一致
  - 知识点覆盖与真题一致
  - 总时长与真题一致
```

#### 第3层：考前冲刺
```
目标：弱点集中突破 + 心态调整

模式：
  - 根据学生能力画像推送
  - 薄弱知识点集中训练
  - 高频错题重练
  - 限时模拟考

题目要求：
  - 个性化推荐
  - 难度适中（不打击信心）
  - 覆盖易错点
```

---

## 七、学生能力画像系统

### 数据收集

```python
class StudentProfile:
    studentId: str
    
    # 知识点掌握度
    knowledgePointMastery: Dict[str, float]  # {"导数": 0.75, "极限": 0.60}
    
    # 题型正确率
    questionTypeAccuracy: Dict[str, float]  # {"choice": 0.80, "fill": 0.65}
    
    # 难度正确率
    difficultyAccuracy: Dict[str, float]  # {"L1": 0.90, "L2": 0.60, "L3": 0.30}
    
    # 做题统计
    totalProblems: int
    correctCount: int
    avgTimePerProblem: float
    
    # 薄弱知识点
    weakPoints: List[str]  # ["极限", "积分"]
    
    # 预测分数
    predictedScore: float  # 基于当前数据预测考试分数
```

### 个性化推荐算法

```python
def recommend_problems(student: StudentProfile, count: int = 20):
    """
    为学生推荐题目
    """
    problems = []
    
    # 70%：薄弱知识点
    weak_points_count = int(count * 0.7)
    for point in student.weakPoints:
        # 选择该知识点的L1+L2题
        problems.extend(
            select_problems(
                knowledgePoint=point,
                difficulty=["L1", "L2"],
                limit=weak_points_count // len(student.weakPoints)
            )
        )
    
    # 20%：已掌握知识点（巩固）
    consolidate_count = int(count * 0.2)
    strong_points = get_strong_points(student)
    problems.extend(
        select_problems(
            knowledgePoint=random.choice(strong_points),
            difficulty=["L2", "L3"],
            limit=consolidate_count
        )
    )
    
    # 10%：随机新题（拓展）
    new_count = count - len(problems)
    problems.extend(select_random_unseen_problems(student, new_count))
    
    return problems
```

---

## 八、后端实现规划

### 数据库扩展（未来）

#### 题目表扩展
```sql
CREATE TABLE questions (
    question_id VARCHAR PRIMARY KEY,
    content JSONB,  -- 题干、选项、答案等
    
    -- 元信息
    knowledge_points TEXT[],
    question_type VARCHAR,
    difficulty VARCHAR,
    ability_tags TEXT[],
    template_id VARCHAR,
    
    -- 来源
    source VARCHAR,  -- "real_exam_2023" / "generated" / "manual"
    is_real_exam BOOLEAN,
    
    -- 质量指标（统计数据）
    total_attempts INT DEFAULT 0,
    correct_count INT DEFAULT 0,
    correct_rate FLOAT,
    discrimination_index FLOAT,
    avg_time_seconds FLOAT,
    
    -- 审核状态
    review_status VARCHAR,  -- "pending" / "approved" / "rejected"
    reviewer_id VARCHAR,
    
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

#### 学生画像表
```sql
CREATE TABLE student_profiles (
    student_id VARCHAR PRIMARY KEY,
    
    -- 知识点掌握度
    knowledge_mastery JSONB,  -- {"导数": 0.75, "极限": 0.60}
    
    -- 题型正确率
    type_accuracy JSONB,
    
    -- 难度正确率
    difficulty_accuracy JSONB,
    
    -- 做题统计
    total_problems INT,
    correct_count INT,
    avg_time_per_problem FLOAT,
    
    -- 预测分数
    predicted_score FLOAT,
    
    updated_at TIMESTAMP
);
```

#### 作答记录表
```sql
CREATE TABLE answer_records (
    id SERIAL PRIMARY KEY,
    student_id VARCHAR,
    question_id VARCHAR,
    user_answer TEXT,
    is_correct BOOLEAN,
    time_spent INT,  -- 秒
    answered_at TIMESTAMP
);
```

### API接口规划

#### 1. 题目质量统计接口
```python
POST /api/admin/question/update-stats
{
  "questionId": "gen_deriv_001",
  "stats": {
    "totalAttempts": 1523,
    "correctCount": 892,
    "avgTime": 45.2
  }
}
```

#### 2. 学生画像接口
```python
GET /api/student/{studentId}/profile
Response:
{
  "studentId": "user123",
  "knowledgeMastery": {"导数": 0.75},
  "weakPoints": ["极限", "积分"],
  "predictedScore": 72.5
}
```

#### 3. 个性化推荐接口
```python
POST /api/student/recommend
{
  "studentId": "user123",
  "mode": "weak_points",  // 薄弱知识点 / 综合训练 / 考前冲刺
  "count": 20
}

Response:
{
  "problems": [...],
  "recommendation_reason": "基于您在极限和积分的薄弱表现"
}
```

#### 4. 模拟考试接口
```python
POST /api/exam/create
{
  "examType": "simulation",
  "blueprint": "高等数学期末考试",
  "studentId": "user123"
}

Response:
{
  "examId": "exam_20231202_001",
  "sections": [...],
  "timeLimit": 7200,  // 秒
  "totalScore": 100
}
```

---

## 九、实施落地清单

### 短期（MVP阶段）
- [x] 题目元信息完善（knowledgePoints, ability等）
- [x] 题目分类存储（按主题拆分）
- [ ] 真题收集和标注（至少20道）
- [ ] 题型模板设计（5-10个核心模板）
- [ ] 人工审核流程

### 中期（数据驱动）
- [ ] 作答记录收集
- [ ] 题目质量统计（正确率、区分度）
- [ ] 学生能力画像
- [ ] 个性化推荐算法（初版）
- [ ] 模拟考试模式

### 长期（精细化运营）
- [ ] 自动难度调整
- [ ] 题目质量自动评分
- [ ] 预测考试分数
- [ ] A/B测试不同出题策略
- [ ] 大数据分析考试趋势

---

## 十、关键成功因素

### 1. 真题是基石
- 不能脱离真题空想
- 生成题要"像"真题
- 统计分布要对齐真题

### 2. 数据是反馈
- 持续收集学生作答数据
- 用数据校准题目质量
- 用数据优化推荐算法

### 3. 人工是保障
- 教师审核不能省
- 定期review题库质量
- 及时处理学生反馈

### 4. 迭代是常态
- 题库不是一次性建好
- 持续根据数据优化
- 根据考试变化调整

---

## 总结

**提高通过率 = 考点贴近 + 题感贴近 + 数据驱动 + 持续迭代**

核心是：
1. 先搞清楚"真实考试的DNA"
2. 用真题做标尺建立题库
3. 用数据持续校准优化
4. 给学生个性化的训练

这样才能真正帮助学生**提升真实考试分数、提高通过率**。

