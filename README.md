# 城市路侧停车位动态感知与结算系统

基于 Vue 3 + Flask + PostgreSQL 的城市路侧停车位管理与结算系统。

## 系统功能

- **路段管理** — 路段信息维护、分时段收费标准配置
- **车位状态管理** — 实时车位占用状态可视化（地磁传感器模拟）
- **用户车辆绑定** — 用户注册、充值、车辆绑定
- **入场/出场记录** — 车辆入场登记、出场自动结算
- **实时计费** — 按时段标准自动计费，余额自动扣款
- **欠费追缴** — 余额不足自动生成欠费记录，支持补缴
- **统计分析** — 路段停车时长、营收、欠费率、泊位周转率排名

## 技术栈

| 层 | 技术 |
|----|------|
| 前端 | Vue 3 + Element Plus + ECharts + Vue Router + Axios |
| 后端 | Python Flask + psycopg2 |
| 数据库 | PostgreSQL 17 |
| 部署 | Docker Compose |

## 数据库设计亮点

- **视图** `v_available_spaces` — 查询指定路段空闲车位编号、位置分布及距上次离开的间隔时长
- **触发器** `trg_vehicle_exit_billing` — 车辆出场自动计费，余额不足自动标记"欠费待缴"
- **函数** `fn_daily_statistics()` — 按路段统计当日停车总时长、应收/实收金额、欠费率、泊位周转率排名

## 快速开始

### 前提条件

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)（必须）
- [Node.js 18+](https://nodejs.org/)（仅构建前端时需要）

### 安装步骤

```bash
# 1. 克隆项目
git clone https://github.com/lanmao657/CSsql.git
cd CSsql

# 2. 构建前端
cd frontend
npm install
npm run build
cd ..

# 3. 启动服务（首次启动会自动初始化数据库）
docker compose up -d --build
```

启动完成后访问 **http://localhost:5000**

### 停止服务

```bash
docker compose down
```

停止并清除数据库数据：

```bash
docker compose down -v
```

## 项目结构

```
CSsql/
├── docker-compose.yml          # 服务编排
├── db/
│   └── init.sql                # 数据库初始化（表、视图、触发器、存储过程、种子数据）
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py                  # Flask RESTful API（23 个端点）
└── frontend/
    ├── package.json
    ├── vite.config.js
    ├── index.html
    └── src/
        ├── main.js
        ├── App.vue
        ├── router/index.js     # 路由配置
        ├── api/                # Axios API 封装（6 个模块）
        ├── components/         # 共享组件（布局、车位网格）
        └── views/              # 9 个页面
            ├── Dashboard.vue   # 系统总览（统计卡片 + ECharts 图表）
            ├── Roads.vue       # 路段管理
            ├── Spaces.vue      # 车位管理
            ├── Users.vue       # 用户管理
            ├── Entry.vue       # 车辆入场
            ├── Exit.vue        # 车辆出场
            ├── Billing.vue     # 计费记录
            ├── Arrears.vue     # 欠费追缴
            └── Statistics.vue  # 统计分析
```

## API 接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/stats/dashboard` | 仪表盘统计数据 |
| GET/POST | `/api/roads` | 路段列表 / 添加路段 |
| DELETE | `/api/roads/:id` | 删除路段 |
| GET/POST | `/api/roads/:id/standards` / `/api/standards` | 收费标准 |
| GET | `/api/spaces` | 车位列表（支持 `?road_id=` 筛选） |
| GET | `/api/spaces/available` | 空闲车位（视图查询） |
| GET/POST | `/api/users` | 用户列表 / 注册 |
| POST | `/api/users/:id/topup` | 用户充值 |
| GET | `/api/users/:id/vehicles` | 用户绑定车辆 |
| POST | `/api/vehicles` | 绑定车辆 |
| POST | `/api/entry` | 车辆入场 |
| POST | `/api/exit` | 车辆出场（触发器自动计费） |
| GET | `/api/entries` | 入场记录 |
| GET | `/api/exits` | 出场记录 |
| GET | `/api/billing` | 计费记录 |
| POST | `/api/billing/:id/pay` | 结算欠费 |
| GET | `/api/arrears` | 欠费记录（支持 `?status=` 筛选） |
| GET | `/api/stats/daily` | 每日统计（支持 `?date=` 查询） |

## 种子数据

系统首次启动会自动插入测试数据：

- 4 条路段（中山北路、人民南路、解放大道、建设路）
- 29 个停车位
- 4 个用户（张三、李四、王五、赵六）
- 5 辆绑定车辆
- 历史出入场记录和计费记录
