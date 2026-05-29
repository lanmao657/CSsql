<div align="center">

# 🅿️ CityPark — 城市路侧停车位动态感知与结算系统

<p>
  <img src="https://img.shields.io/badge/Vue-3.5-4FC08D?style=flat-square&logo=vue.js&logoColor=white" alt="Vue 3">
  <img src="https://img.shields.io/badge/Flask-3.x-000000?style=flat-square&logo=flask&logoColor=white" alt="Flask">
  <img src="https://img.shields.io/badge/PostgreSQL-17-4169E1?style=flat-square&logo=postgresql&logoColor=white" alt="PostgreSQL 17">
  <img src="https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker&logoColor=white" alt="Docker Compose">
  <img src="https://img.shields.io/badge/Element_Plus-2.9-409EFF?style=flat-square&logo=element&logoColor=white" alt="Element Plus">
  <img src="https://img.shields.io/badge/ECharts-6-AA3498?style=flat-square&logo=apacheecharts&logoColor=white" alt="ECharts">
</p>

<p>
  <strong>一套完整的城市路侧停车管理解决方案</strong><br/>
  涵盖路段管理、地磁感知、实时计费、欠费追缴、统计分析 —— 全链路闭环
</p>

</div>

---

## 系统架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        用户浏览器                                │
│   Vue 3 + Element Plus + ECharts + Vue Router                   │
└──────────────────────────┬──────────────────────────────────────┘
                           │  Axios HTTP
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Flask RESTful API                            │
│              23 个端点 · CORS · 静态文件托管                      │
└──────────────────────────┬──────────────────────────────────────┘
                           │  psycopg2
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PostgreSQL 17                                 │
│   9 张表 · 1 个视图 · 1 个触发器 · 1 个存储函数 · 8 个索引       │
└─────────────────────────────────────────────────────────────────┘
```

> **一行命令启动**：`docker compose up -d --build` — 数据库自动建表、注入种子数据、前端自动托管。

---

## 核心功能

<table>
<tr>
<td width="50%">

### 🛣️ 路段与车位管理
- 路段 CRUD、分时段收费标准灵活配置
- 车位状态实时可视化（空闲 / 占用 / 预留 / 故障）
- 地磁传感器模拟，状态自动同步

</td>
<td width="50%">

### 👤 用户与车辆
- 用户注册 / 充值 / 账户管理
- 一人多车绑定，车牌即身份
- 账户状态自动流转：正常 → 冻结 / 欠费

</td>
</tr>
<tr>
<td width="50%">

### 🚗 出入场与计费
- 车辆入场自动分配车位、记录地磁状态
- 出场触发器 **逐分钟累加计费**，跨日自动分段
- 余额充足自动扣款，不足自动生成欠费记录

</td>
<td width="50%">

### 📊 统计分析
- 仪表盘：当日营收 / 占用率 / 活跃用户一目了然
- ECharts 图表：时段分布 / 趋势对比
- 路段排名：停车时长 / 营收 / 欠费率 / 泊位周转率

</td>
</tr>
</table>

---

## 技术栈

| 层 | 技术 | 说明 |
|:---|:-----|:-----|
| **前端** | Vue 3 + Element Plus | 组件化 SPA，开箱即用的 UI 组件库 |
| **可视化** | ECharts 6 + vue-echarts | 交互式图表，数据驱动决策 |
| **路由** | Vue Router 4 | 前端路由，页面无刷新切换 |
| **HTTP** | Axios | 请求拦截、统一错误处理 |
| **后端** | Python Flask | 轻量 RESTful API，23 个端点 |
| **数据库** | PostgreSQL 17 | 企业级关系型数据库 |
| **部署** | Docker Compose | 一键编排，开箱即用 |

---

## 数据库设计亮点

<table>
<tr>
<td width="33%" align="center">

**🔍 视图**
`v_available_spaces`

查询指定路段空闲车位编号、位置分布及距上次离开的间隔时长，为动态调度提供数据支撑。

</td>
<td width="33%" align="center">

**⚡ 触发器**
`trg_vehicle_exit_billing`

车辆出场自动触发计费，逐分钟按时段标准累加，余额不足自动标记"欠费待缴"，全程零人工干预。

</td>
<td width="33%" align="center">

**📈 存储函数**
`fn_daily_statistics()`

按路段统计当日停车总时长、应收/实收金额、欠费率、泊位周转率排名，一键生成日报。

</td>
</tr>
</table>

### 数据模型

```
road_sections ──┐
                ├── parking_spaces
charging_standards ┘         │
                             ▼
users ──── user_vehicles ── entry_records ── exit_records ── billing_records
                                                                      │
                                                               arrears_records
```

**9 张表 · 8 个索引** — 覆盖路段、车位、用户、车辆、出入场、计费、欠费全业务链路。

---

## 快速开始

### 前提条件

| 工具 | 版本 | 用途 |
|:-----|:-----|:-----|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | 最新版 | **必须** — 运行 PostgreSQL 和后端服务 |
| [Node.js](https://nodejs.org/) | 18+ | 仅构建前端时需要 |

### 三步启动

```bash
# 1️⃣  克隆项目
git clone https://github.com/lanmao657/CSsql.git
cd CSsql

# 2️⃣  构建前端
cd frontend && npm install && npm run build && cd ..

# 3️⃣  一键启动（首次自动建表 + 注入种子数据）
docker compose up -d --build
```

启动完成后访问 **http://localhost:5000** 🎉

### 常用命令

```bash
docker compose up -d          # 启动服务
docker compose down           # 停止服务（保留数据）
docker compose down -v        # 停止并清除所有数据（含数据库）
docker compose logs -f        # 查看实时日志
docker compose ps             # 查看运行状态
```

---

## 项目结构

```
CSsql/
├── docker-compose.yml              # 服务编排（PostgreSQL + Flask）
├── db/
│   └── init.sql                    # 数据库完整初始化脚本
│                                     ├── 9 张业务表
│                                     ├── 8 个性能索引
│                                     ├── 1 个视图（空闲车位查询）
│                                     ├── 1 个触发器（出场自动计费）
│                                     ├── 1 个存储函数（每日统计）
│                                     └── 种子数据（4 路段 / 29 车位 / 4 用户）
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py                      # Flask API（23 个 RESTful 端点）
└── frontend/
    ├── package.json
    ├── vite.config.js
    ├── index.html
    └── src/
        ├── main.js                 # 应用入口
        ├── App.vue                 # 根组件（侧边栏布局）
        ├── router/index.js         # 路由配置（9 个页面）
        ├── api/                    # Axios API 封装（6 个模块）
        │   ├── dashboard.js
        │   ├── roads.js
        │   ├── spaces.js
        │   ├── users.js
        │   ├── billing.js
        │   └── statistics.js
        ├── components/             # 共享组件
        │   ├── AppLayout.vue       # 全局布局（侧边栏 + 顶栏）
        │   └── ParkingGrid.vue     # 车位网格可视化组件
        └── views/                  # 9 个页面
            ├── Dashboard.vue       # 系统总览（统计卡片 + ECharts 图表）
            ├── Roads.vue           # 路段管理（CRUD + 收费标准配置）
            ├── Spaces.vue          # 车位管理（实时状态网格）
            ├── Users.vue           # 用户管理（注册 / 充值 / 车辆绑定）
            ├── Entry.vue           # 车辆入场（车牌识别 + 车位分配）
            ├── Exit.vue            # 车辆出场（触发器自动计费）
            ├── Billing.vue         # 计费记录（支付状态追踪）
            ├── Arrears.vue         # 欠费追缴（一键补缴）
            └── Statistics.vue      # 统计分析（多维度排名）
```

---

## API 接口

<details>
<summary><strong>展开查看全部 23 个 RESTful 端点</strong></summary>

| 方法 | 路径 | 说明 |
|:-----|:-----|:-----|
| `GET` | `/api/stats/dashboard` | 仪表盘统计数据 |
| `GET` | `/api/roads` | 路段列表 |
| `POST` | `/api/roads` | 添加路段 |
| `DELETE` | `/api/roads/:id` | 删除路段 |
| `GET` | `/api/roads/:id/standards` | 路段收费标准 |
| `POST` | `/api/standards` | 添加收费标准 |
| `GET` | `/api/spaces` | 车位列表（支持 `?road_id=` 筛选） |
| `GET` | `/api/spaces/available` | 空闲车位（视图查询） |
| `GET` | `/api/users` | 用户列表 |
| `POST` | `/api/users` | 用户注册 |
| `POST` | `/api/users/:id/topup` | 用户充值 |
| `GET` | `/api/users/:id/vehicles` | 用户绑定车辆 |
| `POST` | `/api/vehicles` | 绑定车辆 |
| `POST` | `/api/entry` | 车辆入场 |
| `POST` | `/api/exit` | 车辆出场（触发器自动计费） |
| `GET` | `/api/entries` | 入场记录 |
| `GET` | `/api/exits` | 出场记录 |
| `GET` | `/api/billing` | 计费记录 |
| `POST` | `/api/billing/:id/pay` | 结算欠费 |
| `GET` | `/api/arrears` | 欠费记录（支持 `?status=` 筛选） |
| `GET` | `/api/stats/daily` | 每日统计（支持 `?date=` 查询） |

</details>

---

## 种子数据

系统首次启动自动注入测试数据，开箱即可体验完整业务流程：

| 数据 | 数量 | 内容 |
|:-----|:-----|:-----|
| 路段 | 4 | 中山北路、人民南路、解放大道、建设路 |
| 车位 | 29 | 分布于 4 条路段，含多种状态 |
| 用户 | 4 | 张三、李四、王五、赵六 |
| 车辆 | 5 | 绑定至不同用户，支持一人多车 |
| 记录 | — | 历史出入场及计费记录 |

---

## 许可证

本项目仅供学习交流使用。
