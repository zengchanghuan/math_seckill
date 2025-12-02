## “解答”Tab + FastAPI 后端联调用法（本地开发版）

本指南说明如何在本地同时运行 **Python FastAPI 后端** 和 **Flutter App**，让底部导航的 **“解答”** Tab 从后端实时获取题目与解析。

> ✅ **真机调试已测试通过**：使用 Mac 热点连接，iPhone 真机可以正常访问后端服务器。

---

### 一、后端目录结构与依赖

后端代码位于独立的 `math_seckill_server/` 目录：

- `main.py`：FastAPI 入口，定义接口 `/` 和 `/api/problem`
- `schemas.py`：请求 / 响应的 Pydantic 模型
- `core/problem_generator.py`：使用 SymPy 生成"导数基础 · 基础"导数题目和解析
- `requirements.txt`：后端所需 Python 依赖

当前主要依赖：

- `fastapi`
- `uvicorn[standard]`
- `sympy`
- `pydantic`

---

### 二、第一次启动后端（推荐步骤）

1. 打开终端，进入后端目录：

   ```bash
   cd /Users/zengchanghuan/Desktop/workspace/flutter/math_seckill_server
   ```

2. 创建并激活虚拟环境（只需第一次创建，以后只需激活）：

   ```bash
   python3 -m venv venv  # 或 python3 -m venv .venv
   source venv/bin/activate  # 或 source .venv/bin/activate
   ```

3. 安装依赖：

   ```bash
   pip install -r requirements.txt
   ```

4. 启动 FastAPI 服务（默认端口 8000）：

   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

   > **说明**：使用 `--host 0.0.0.0` 可以接受来自所有网络接口的连接，比 `127.0.0.1` 更灵活。如果只想本地访问，也可以使用 `--host 127.0.0.1`。

5. 浏览器验证服务是否正常：

   - 打开：`http://127.0.0.1:8000/`
   - 看到返回：`{"status":"ok"}` 即表示服务正常
   - 接口文档（可选）：`http://127.0.0.1:8000/docs`

> 以后再次启动后端，只需执行：
>
> ```bash
> cd /Users/zengchanghuan/Desktop/workspace/flutter/math_seckill_server
> source venv/bin/activate  # 或 source .venv/bin/activate（根据你的虚拟环境名称）
> uvicorn main:app --reload --host 0.0.0.0 --port 8000
> ```

---

### 三、FastAPI 提供的接口说明

1. **健康检查**

   - 方法：`GET /`
   - 返回示例：

   ```json
   {
     "status": "ok"
   }
   ```

2. **获取单个题目**

   - 方法：`POST /api/problem`
   - 请求 JSON：

   ```json
   {
     "topic": "导数基础",
     "difficulty": "基础"
   }
   ```

   - 响应 JSON 字段与 Flutter `Problem` 模型保持一致：

   ```json
   {
     "id": "backend-temp",
     "topic": "导数基础",
     "difficulty": "基础",
     "question": "题干（LaTeX 字符串）",
     "options": ["选项A", "选项B", "选项C", "选项D"],
     "answer": "A",
     "solution": "解析（支持 LaTeX 片段）",
     "tags": ["导数", "多项式", "后端生成"]
   }
   ```

---

### 四、Flutter 端如何联调“解答”Tab

1. 确保依赖已拉取：

   在 Flutter 项目根目录执行：

   ```bash
   cd /Users/zengchanghuan/Desktop/workspace/flutter/math_seckill
   flutter pub get
   ```

2. 启动 Flutter App（推荐 iOS 模拟器）：

   ```bash
   flutter run
   ```

3. 在 App 中操作：

   - 底部导航切换到 **“解答”** Tab
   - 页面会自动向后端请求一题：
     - 主题：`导数基础`
     - 难度：`基础`
   - 点击底部按钮 **“再来一题”** 会再次请求 `/api/problem`，获取新的随机题目和解析

4. iOS 网络权限配置（重要）：

   iOS 需要在 `Info.plist` 中配置网络权限才能访问本地 HTTP 服务。项目已自动配置，包含：

   - `NSLocalNetworkUsageDescription`：本地网络使用说明
   - `NSAppTransportSecurity`：允许本地网络的 HTTP 请求（因为后端使用 HTTP 而非 HTTPS）

   配置文件位置：`ios/Runner/Info.plist`

   > **注意**：如果修改了后端地址，确保 `NSExceptionDomains` 中包含对应的域名（如 `localhost`、`127.0.0.1`）

5. 网络配置说明：

   - Dart 中后端基础地址定义在 `lib/core/services/api_config.dart`：

     ```dart
     class ApiConfig {
       static const String baseUrl = 'http://192.168.231.26:8000';
     }
     ```

   - **iOS 模拟器**：使用 `localhost` 或 `127.0.0.1` 访问宿主机
   - **iOS 真机**：必须使用 Mac 的实际 IP 地址（不能使用 localhost）
     - 获取 Mac IP：在终端运行 `ifconfig | grep "inet " | grep -v 127.0.0.1`
     - 确保真机和 Mac 连接在**同一个 Wi-Fi 网络**
   - **Android 模拟器**：使用 `http://10.0.2.2:8000`

---

### 五、常见问题（FAQ）

1. **解答页一直转圈 / 报错 "获取题目失败"**

   - 检查后端是否已启动，并且终端里无错误
   - 浏览器访问 `http://localhost:8000/` 或 `http://127.0.0.1:8000/` 看是否返回 `{"status":"ok"}`
   - 检查 `ApiConfig.baseUrl` 是否和后端地址一致
   - **iOS 用户**：确认 `ios/Runner/Info.plist` 中已配置 `NSAppTransportSecurity` 和 `NSLocalNetworkUsageDescription`
   - 如果修改了 `Info.plist`，需要完全重启 App（停止并重新运行 `flutter run`）

2. **iOS 真机连接失败：No route to host (errno = 65)**

   - **确保真机和 Mac 在同一 Wi-Fi 网络**
     - 在 iPhone 设置 → Wi-Fi 中确认连接的 Wi-Fi 名称
     - 在 Mac 系统设置 → 网络 中确认连接的 Wi-Fi 名称
     - 两者必须完全一致

   - **确认 Mac IP 地址正确**
     - 在 Mac 终端运行：`ifconfig | grep "inet " | grep -v 127.0.0.1`
     - 找到类似 `192.168.x.x` 的地址
     - 在 `lib/core/services/api_config.dart` 中使用这个 IP

   - **确认后端使用 `--host 0.0.0.0`**
     - 后端必须使用：`uvicorn main:app --reload --host 0.0.0.0 --port 8000`
     - 不能使用 `--host 127.0.0.1`（只允许本地访问）

   - **检查 Mac 防火墙**
     - 系统设置 → 网络 → 防火墙
     - 如果开启，需要允许 Python 或添加端口例外

   - **在真机 Safari 中测试**
     - 在 iPhone Safari 中访问：`http://192.168.231.26:8000/`
     - 如果浏览器能访问，说明网络正常，问题在 App 配置
     - 如果浏览器也不能访问，说明是网络或防火墙问题

3. **后端端口被占用**

   - 终端看到类似 `Address already in use`，说明 8000 端口被占用
   - 可以换一个端口，例如：

     ```bash
     uvicorn main:app --reload --host 127.0.0.1 --port 8001
     ```

   - 同时在 `ApiConfig.baseUrl` 中改为：

     ```dart
     static const String baseUrl = 'http://127.0.0.1:8001';
     ```

4. **虚拟环境忘记激活**

   - 如果出现 `ModuleNotFoundError: No module named 'fastapi'` 等错误：
     - 确认当前目录在 `math_seckill_server/`
     - 先执行：

       ```bash
       source .venv/bin/activate
       ```

     - 再执行：

       ```bash
       uvicorn main:app --reload --host 127.0.0.1 --port 8000
       ```

---

### 六、后续扩展建议

- 在 `core/problem_generator.py` 中新增更多题型生成函数：
  - 如极限与连续、积分等
  - 根据 `topic` / `difficulty` 路由到不同生成逻辑
- 在 Flutter 的 `AnswerPage` 中放开更多下拉选项（不同主题和难度），与后端生成逻辑一一对应。
