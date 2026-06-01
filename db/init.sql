-- ============================================================
-- 城市路侧停车位动态感知与结算系统 - 数据库初始化
-- PostgreSQL 17
-- ============================================================

-- ==================== 1. 路段信息表 ====================
CREATE TABLE road_sections (
    road_id      SERIAL PRIMARY KEY,
    road_name    VARCHAR(100) NOT NULL,
    section_code VARCHAR(50)  NOT NULL UNIQUE,
    total_spaces INTEGER NOT NULL CHECK (total_spaces > 0),
    address      VARCHAR(200),
    status       VARCHAR(20) DEFAULT 'normal' CHECK (status IN ('normal','closed','maintenance')),
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== 2. 收费标准表 ====================
CREATE TABLE charging_standards (
    standard_id  SERIAL PRIMARY KEY,
    road_id      INTEGER NOT NULL REFERENCES road_sections(road_id),
    period_name  VARCHAR(50)  NOT NULL,
    start_hour   INTEGER NOT NULL CHECK (start_hour BETWEEN 0 AND 23),
    end_hour     INTEGER NOT NULL CHECK (end_hour BETWEEN 0 AND 24),
    price_per_hour NUMERIC(8,2) NOT NULL CHECK (price_per_hour >= 0),
    UNIQUE(road_id, period_name)
);

-- ==================== 3. 停车位表 ====================
CREATE TABLE parking_spaces (
    space_id       SERIAL PRIMARY KEY,
    road_id        INTEGER NOT NULL REFERENCES road_sections(road_id),
    space_number   VARCHAR(20)  NOT NULL,
    space_position VARCHAR(50),
    status         VARCHAR(20) DEFAULT 'free' CHECK (status IN ('free','occupied','reserved','fault')),
    plate_number   VARCHAR(20),
    occupied_at    TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(road_id, space_number)
);

-- ==================== 4. 用户表 ====================
CREATE TABLE users (
    user_id      SERIAL PRIMARY KEY,
    username     VARCHAR(50)  NOT NULL UNIQUE,
    phone        VARCHAR(20)  NOT NULL UNIQUE,
    balance      NUMERIC(10,2) DEFAULT 0.00 CHECK (balance >= 0),
    status       VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active','frozen','arrears')),
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== 5. 用户车辆绑定表 ====================
CREATE TABLE user_vehicles (
    binding_id  SERIAL PRIMARY KEY,
    user_id     INTEGER NOT NULL REFERENCES users(user_id),
    plate_number VARCHAR(20) NOT NULL UNIQUE,
    bind_time   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== 6. 停车入场记录表 ====================
CREATE TABLE entry_records (
    entry_id     SERIAL PRIMARY KEY,
    plate_number VARCHAR(20) NOT NULL,
    road_id      INTEGER NOT NULL REFERENCES road_sections(road_id),
    space_id     INTEGER NOT NULL REFERENCES parking_spaces(space_id),
    entry_time   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    geomagnetic_status VARCHAR(20) DEFAULT 'occupied'
);

-- ==================== 7. 停车出场记录表 ====================
CREATE TABLE exit_records (
    exit_id      SERIAL PRIMARY KEY,
    entry_id     INTEGER NOT NULL REFERENCES entry_records(entry_id),
    plate_number VARCHAR(20) NOT NULL,
    road_id      INTEGER NOT NULL REFERENCES road_sections(road_id),
    space_id     INTEGER NOT NULL REFERENCES parking_spaces(space_id),
    entry_time   TIMESTAMP NOT NULL,
    exit_time    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    duration_minutes INTEGER,
    fee          NUMERIC(10,2)
);

-- ==================== 8. 停车计费记录表 ====================
CREATE TABLE billing_records (
    billing_id   SERIAL PRIMARY KEY,
    exit_id      INTEGER REFERENCES exit_records(exit_id),
    plate_number VARCHAR(20) NOT NULL,
    user_id      INTEGER REFERENCES users(user_id),
    total_fee    NUMERIC(10,2) NOT NULL,
    actual_paid  NUMERIC(10,2) DEFAULT 0.00,
    payment_status VARCHAR(20) DEFAULT 'unpaid'
                 CHECK (payment_status IN ('paid','unpaid','partial','arrears')),
    payment_method VARCHAR(20),
    payment_time TIMESTAMP,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== 9. 欠费追缴记录表 ====================
CREATE TABLE arrears_records (
    arrears_id   SERIAL PRIMARY KEY,
    billing_id   INTEGER REFERENCES billing_records(billing_id),
    plate_number VARCHAR(20) NOT NULL,
    user_id      INTEGER REFERENCES users(user_id),
    arrears_amount NUMERIC(10,2) NOT NULL,
    status       VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','paid','waived')),
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    paid_at      TIMESTAMP
);

-- ==================== 索引 ====================
CREATE INDEX idx_parking_spaces_road   ON parking_spaces(road_id, status);
CREATE INDEX idx_entry_records_plate   ON entry_records(plate_number);
CREATE INDEX idx_entry_records_time    ON entry_records(entry_time);
CREATE INDEX idx_exit_records_plate    ON exit_records(plate_number);
CREATE INDEX idx_exit_records_time     ON exit_records(exit_time);
CREATE INDEX idx_billing_records_user  ON billing_records(user_id);
CREATE INDEX idx_arrears_records_user  ON arrears_records(user_id, status);
CREATE INDEX idx_user_vehicles_plate   ON user_vehicles(plate_number);


-- ============================================================
-- 视图：查询指定路段当前所有空闲车位编号、位置分布
--       及距上次车辆离开的间隔时长
-- ============================================================
CREATE OR REPLACE VIEW v_available_spaces AS
SELECT
    ps.space_id,
    ps.road_id,
    rs.road_name,
    rs.section_code,
    ps.space_number,
    ps.space_position,
    ps.updated_at AS last_freed_at,
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - ps.updated_at)) / 60 AS minutes_since_freed
FROM parking_spaces ps
JOIN road_sections rs ON ps.road_id = rs.road_id
WHERE ps.status = 'free'
ORDER BY ps.road_id, ps.space_number;


-- ============================================================
-- 触发器函数：车辆出场时自动计费
-- 逻辑：
--   1. 计算停车时长（分钟）
--   2. 按时间段累加计费（跨日自动分段）
--   3. 将车位状态更新为 'free'
--   4. 查询用户账户余额
--   5. 余额充足则自动扣款，不足则生成欠费记录
-- ============================================================
CREATE OR REPLACE FUNCTION fn_vehicle_exit_billing()
RETURNS TRIGGER AS $$
DECLARE
    v_duration   INTEGER;
    v_fee        NUMERIC(10,2) := 0;
    v_hour       INTEGER;
    v_cursor     TIMESTAMP;
    v_end        TIMESTAMP;
    v_price      NUMERIC(8,2);
    v_user_id    INTEGER;
    v_balance    NUMERIC(10,2);
    v_billing_id INTEGER;
BEGIN
    -- 计算停车总时长（分钟）
    v_duration := EXTRACT(EPOCH FROM (NEW.exit_time - NEW.entry_time)) / 60;

    -- ===== 分时段累加计算费用 =====
    v_cursor := NEW.entry_time;
    v_end    := NEW.exit_time;

    WHILE v_cursor < v_end LOOP
        v_hour := EXTRACT(HOUR FROM v_cursor)::INTEGER;

        -- 查找当前小时对应的收费标准
        SELECT COALESCE(cs.price_per_hour, 0) INTO v_price
        FROM charging_standards cs
        WHERE cs.road_id = NEW.road_id
          AND (
              (cs.start_hour <= cs.end_hour AND v_hour >= cs.start_hour AND v_hour < cs.end_hour)
              OR
              (cs.start_hour > cs.end_hour AND (v_hour >= cs.start_hour OR v_hour < cs.end_hour))
          )
        ORDER BY cs.price_per_hour DESC
        LIMIT 1;

        v_fee := v_fee + COALESCE(v_price, 0) / 60;  -- 按分钟计费
        v_cursor := v_cursor + INTERVAL '1 minute';
    END LOOP;

    -- 保留两位小数
    v_fee := ROUND(v_fee, 2);

    -- ===== 回写时长和费用到出场记录 =====
    UPDATE exit_records
    SET duration_minutes = v_duration,
        fee = v_fee
    WHERE exit_id = NEW.exit_id;

    -- ===== 更新车位状态为空闲 =====
    UPDATE parking_spaces
    SET status       = 'free',
        plate_number = NULL,
        occupied_at  = NULL,
        updated_at   = CURRENT_TIMESTAMP
    WHERE space_id = NEW.space_id;

    -- ===== 查询车主用户信息 =====
    SELECT uv.user_id INTO v_user_id
    FROM user_vehicles uv
    WHERE uv.plate_number = NEW.plate_number
    LIMIT 1;

    -- ===== 创建计费记录 =====
    INSERT INTO billing_records (exit_id, plate_number, user_id, total_fee)
    VALUES (NEW.exit_id, NEW.plate_number, v_user_id, v_fee)
    RETURNING billing_id INTO v_billing_id;

    -- ===== 判断用户余额并处理支付 =====
    IF v_user_id IS NOT NULL THEN
        SELECT balance INTO v_balance
        FROM users WHERE user_id = v_user_id;

        IF v_balance >= v_fee AND v_fee > 0 THEN
            -- 余额充足：自动扣款
            UPDATE users SET balance = balance - v_fee WHERE user_id = v_user_id;
            UPDATE billing_records
            SET actual_paid    = v_fee,
                payment_status = 'paid',
                payment_method = 'wallet',
                payment_time   = CURRENT_TIMESTAMP
            WHERE billing_id = v_billing_id;
        ELSIF v_fee > 0 THEN
            -- 余额不足：生成欠费记录
            UPDATE billing_records
            SET actual_paid    = 0,
                payment_status = 'arrears'
            WHERE billing_id = v_billing_id;

            INSERT INTO arrears_records (billing_id, plate_number, user_id, arrears_amount)
            VALUES (v_billing_id, NEW.plate_number, v_user_id, v_fee);

            -- 标记用户状态为欠费待缴
            UPDATE users SET status = 'arrears' WHERE user_id = v_user_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_vehicle_exit_billing
    AFTER INSERT ON exit_records
    FOR EACH ROW
    EXECUTE FUNCTION fn_vehicle_exit_billing();


-- ============================================================
-- 存储过程：按路段统计当日停车数据 + 路段泊位周转率排名
-- 使用函数形式以便返回结果集
-- ============================================================
CREATE OR REPLACE FUNCTION fn_daily_statistics(
    p_date DATE
)
RETURNS TABLE(
    road_id            INTEGER,
    road_name          VARCHAR,
    total_park_minutes BIGINT,
    total_hours        NUMERIC,
    expected_revenue   NUMERIC,
    actual_revenue     NUMERIC,
    arrears_amount     NUMERIC,
    arrears_rate       NUMERIC,
    turnover_rate      NUMERIC,
    rank               INTEGER
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH daily_data AS (
        SELECT
            er.road_id,
            rs.road_name,
            rs.total_spaces,
            SUM(COALESCE(xr.duration_minutes,
                CASE WHEN xr.exit_id IS NULL
                     THEN EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - er.entry_time))/60
                     ELSE 0 END
            ))::BIGINT AS total_minutes,
            COUNT(xr.exit_id)::INTEGER AS exit_count
        FROM entry_records er
        JOIN road_sections rs ON er.road_id = rs.road_id
        LEFT JOIN exit_records xr ON xr.entry_id = er.entry_id
        WHERE er.entry_time >= p_date
          AND er.entry_time <  p_date + INTERVAL '1 day'
        GROUP BY er.road_id, rs.road_name, rs.total_spaces
    ),
    billing_data AS (
        SELECT
            xr.road_id,
            COALESCE(SUM(br.total_fee), 0)   AS expected,
            COALESCE(SUM(br.actual_paid), 0) AS actual,
            COALESCE(SUM(
                CASE WHEN br.payment_status = 'arrears' THEN br.total_fee ELSE 0 END
            ), 0) AS arrears_amt
        FROM billing_records br
        JOIN exit_records xr ON br.exit_id = xr.exit_id
        WHERE xr.exit_time >= p_date
          AND xr.exit_time <  p_date + INTERVAL '1 day'
        GROUP BY xr.road_id
    )
    SELECT
        dd.road_id,
        dd.road_name,
        dd.total_minutes,
        ROUND(dd.total_minutes / 60.0, 2),
        ROUND(COALESCE(bd.expected, 0), 2),
        ROUND(COALESCE(bd.actual, 0), 2),
        ROUND(COALESCE(bd.arrears_amt, 0), 2),
        CASE WHEN COALESCE(bd.expected, 0) > 0
             THEN ROUND(bd.arrears_amt / bd.expected * 100, 2)
             ELSE 0 END,
        ROUND(COALESCE(dd.exit_count, 0)::NUMERIC / NULLIF(dd.total_spaces, 0), 2),
        RANK() OVER (ORDER BY COALESCE(dd.exit_count, 0)::NUMERIC
                                  / NULLIF(dd.total_spaces, 0) DESC)::INTEGER
    FROM daily_data dd
    LEFT JOIN billing_data bd ON dd.road_id = bd.road_id
    ORDER BY RANK() OVER (ORDER BY COALESCE(dd.exit_count, 0)::NUMERIC
                                          / NULLIF(dd.total_spaces, 0) DESC);
END;
$$;


-- ============================================================
-- 种子数据
-- ============================================================

-- 路段
INSERT INTO road_sections (road_name, section_code, total_spaces, address) VALUES
    ('中山北路',   'ZSBL-001', 8,  '中山北路100-200号东侧'),
    ('人民南路',   'RMNL-002', 6,  '人民南路50-150号西侧'),
    ('解放大道',   'JFDD-003', 10, '解放大道300-500号南侧'),
    ('建设路',     'JSLU-004', 5,  '建设路1-80号两侧'),
    ('文化路',     'WHLU-005', 8,  '文化路10-120号南侧'),
    ('滨江大道',   'BJDD-006', 10, '滨江大道1000-1200号沿江侧'),
    ('科技园南路', 'KJYN-007', 8,  '科技园南路1-60号东侧'),
    ('湖滨北路',   'HBBN-008', 6,  '湖滨北路200-350号西侧');

-- 收费标准（按路段 × 时段）
INSERT INTO charging_standards (road_id, period_name, start_hour, end_hour, price_per_hour) VALUES
    -- 中山北路
    (1, '早高峰', 7, 9,   10.00),
    (1, '日间',   9, 17,   8.00),
    (1, '晚高峰', 17, 19, 10.00),
    (1, '夜间',   19, 7,   3.00),
    -- 人民南路
    (2, '日间',   8, 20,   6.00),
    (2, '夜间',   20, 8,   2.00),
    -- 解放大道
    (3, '早高峰', 7, 9,   12.00),
    (3, '日间',   9, 17,  10.00),
    (3, '晚高峰', 17, 19, 12.00),
    (3, '夜间',   19, 7,   4.00),
    -- 建设路
    (4, '全天',   0, 24,   5.00),
    -- 文化路
    (5, '日间',   8, 20,   8.00),
    (5, '夜间',   20, 8,   3.00),
    -- 滨江大道
    (6, '早高峰', 7, 9,   15.00),
    (6, '日间',   9, 17,  12.00),
    (6, '晚高峰', 17, 19, 15.00),
    (6, '夜间',   19, 7,   5.00),
    -- 科技园南路
    (7, '工作日白天', 8, 18,  6.00),
    (7, '工作日夜间', 18, 8,  2.00),
    (7, '周末全天',   0, 24,  4.00),
    -- 湖滨北路
    (8, '日间',   9, 21,   7.00),
    (8, '夜间',   21, 9,   2.50);

-- 停车位（中山北路 A01-A08）
INSERT INTO parking_spaces (road_id, space_number, space_position) VALUES
    (1, 'A01', '路段起点东侧'),
    (1, 'A02', '路段起点东侧'),
    (1, 'A03', '路段中段东侧'),
    (1, 'A04', '路段中段东侧'),
    (1, 'A05', '路段中段东侧'),
    (1, 'A06', '路段中段东侧'),
    (1, 'A07', '路段末端东侧'),
    (1, 'A08', '路段末端东侧');

-- 停车位（人民南路 B01-B06）
INSERT INTO parking_spaces (road_id, space_number, space_position) VALUES
    (2, 'B01', '路段起点西侧'),
    (2, 'B02', '路段起点西侧'),
    (2, 'B03', '路段中段西侧'),
    (2, 'B04', '路段中段西侧'),
    (2, 'B05', '路段末端西侧'),
    (2, 'B06', '路段末端西侧');

-- 停车位（解放大道 C01-C10）
INSERT INTO parking_spaces (road_id, space_number, space_position) VALUES
    (3, 'C01', '路段起点南侧'),
    (3, 'C02', '路段起点南侧'),
    (3, 'C03', '路段中段南侧'),
    (3, 'C04', '路段中段南侧'),
    (3, 'C05', '路段中段南侧'),
    (3, 'C06', '路段中段南侧'),
    (3, 'C07', '路段中段南侧'),
    (3, 'C08', '路段末端南侧'),
    (3, 'C09', '路段末端南侧'),
    (3, 'C10', '路段末端南侧');

-- 停车位（建设路 D01-D05）
INSERT INTO parking_spaces (road_id, space_number, space_position) VALUES
    (4, 'D01', '路段起点'),
    (4, 'D02', '路段中段'),
    (4, 'D03', '路段中段'),
    (4, 'D04', '路段末端'),
    (4, 'D05', '路段末端');

-- 停车位（文化路 E01-E08）
INSERT INTO parking_spaces (road_id, space_number, space_position) VALUES
    (5, 'E01', '路段起点南侧'),
    (5, 'E02', '路段起点南侧'),
    (5, 'E03', '路段中段南侧'),
    (5, 'E04', '路段中段南侧'),
    (5, 'E05', '路段中段南侧'),
    (5, 'E06', '路段中段南侧'),
    (5, 'E07', '路段末端南侧'),
    (5, 'E08', '路段末端南侧');

-- 停车位（滨江大道 F01-F10）
INSERT INTO parking_spaces (road_id, space_number, space_position) VALUES
    (6, 'F01', '路段起点沿江侧'),
    (6, 'F02', '路段起点沿江侧'),
    (6, 'F03', '路段中段沿江侧'),
    (6, 'F04', '路段中段沿江侧'),
    (6, 'F05', '路段中段沿江侧'),
    (6, 'F06', '路段中段沿江侧'),
    (6, 'F07', '路段中段沿江侧'),
    (6, 'F08', '路段末端沿江侧'),
    (6, 'F09', '路段末端沿江侧'),
    (6, 'F10', '路段末端沿江侧');

-- 停车位（科技园南路 G01-G08）
INSERT INTO parking_spaces (road_id, space_number, space_position) VALUES
    (7, 'G01', '路段起点东侧'),
    (7, 'G02', '路段起点东侧'),
    (7, 'G03', '路段中段东侧'),
    (7, 'G04', '路段中段东侧'),
    (7, 'G05', '路段中段东侧'),
    (7, 'G06', '路段中段东侧'),
    (7, 'G07', '路段末端东侧'),
    (7, 'G08', '路段末端东侧');

-- 停车位（湖滨北路 H01-H06）
INSERT INTO parking_spaces (road_id, space_number, space_position) VALUES
    (8, 'H01', '路段起点西侧'),
    (8, 'H02', '路段起点西侧'),
    (8, 'H03', '路段中段西侧'),
    (8, 'H04', '路段中段西侧'),
    (8, 'H05', '路段末端西侧'),
    (8, 'H06', '路段末端西侧');

-- 用户
INSERT INTO users (username, phone, balance) VALUES
    ('张三', '13800001111', 200.00),
    ('李四', '13800002222',  15.00),
    ('王五', '13800003333', 500.00),
    ('赵六', '13800004444',   0.00),
    ('钱七', '13800005555',   5.00),
    ('孙八', '13800006666',  80.00),
    ('周九', '13800007777', 300.00),
    ('吴十', '13800008888',  25.00),
    ('郑婷', '13800009999',  10.00);

-- 用户车辆绑定
INSERT INTO user_vehicles (user_id, plate_number) VALUES
    (1, '京A·12345'),
    (1, '京A·67890'),
    (2, '沪B·88888'),
    (3, '粤C·66666'),
    (4, '浙D·99999'),
    (5, '苏E·55555'),
    (6, '闽F·77777'),
    (7, '赣G·33333'),
    (8, '鄂H·22222'),
    (9, '湘J·11111');

-- 模拟当前占用（部分车位已被占用）
INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status) VALUES
    ('京A·12345', 1, 1,  CURRENT_TIMESTAMP - INTERVAL '45 minutes', 'occupied'),
    ('沪B·88888', 1, 3,  CURRENT_TIMESTAMP - INTERVAL '2 hours',    'occupied'),
    ('粤C·66666', 2, 9,  CURRENT_TIMESTAMP - INTERVAL '30 minutes', 'occupied'),
    ('京A·67890', 3, 15, CURRENT_TIMESTAMP - INTERVAL '1 hour',     'occupied'),
    ('苏E·55555', 5, 30, CURRENT_TIMESTAMP - INTERVAL '1.5 hours',  'occupied'),
    ('闽F·77777', 6, 36, CURRENT_TIMESTAMP - INTERVAL '2 hours',    'occupied'),
    ('赣G·33333', 7, 38, CURRENT_TIMESTAMP - INTERVAL '40 minutes', 'occupied'),
    ('鄂H·22222', 8, 42, CURRENT_TIMESTAMP - INTERVAL '1 hour',     'occupied'),
    ('湘J·11111', 3, 22, CURRENT_TIMESTAMP - INTERVAL '3 hours',    'occupied'),
    ('浙D·99999', 4, 27, CURRENT_TIMESTAMP - INTERVAL '50 minutes', 'occupied');

-- 更新被占用车位状态
UPDATE parking_spaces SET status='occupied', plate_number='京A·12345',
    occupied_at=CURRENT_TIMESTAMP - INTERVAL '45 minutes' WHERE space_id=1;
UPDATE parking_spaces SET status='occupied', plate_number='沪B·88888',
    occupied_at=CURRENT_TIMESTAMP - INTERVAL '2 hours' WHERE space_id=3;
UPDATE parking_spaces SET status='occupied', plate_number='粤C·66666',
    occupied_at=CURRENT_TIMESTAMP - INTERVAL '30 minutes' WHERE space_id=9;
UPDATE parking_spaces SET status='occupied', plate_number='京A·67890',
    occupied_at=CURRENT_TIMESTAMP - INTERVAL '1 hour' WHERE space_id=15;
UPDATE parking_spaces SET status='occupied', plate_number='苏E·55555',
    occupied_at=CURRENT_TIMESTAMP - INTERVAL '1.5 hours' WHERE space_id=30;
UPDATE parking_spaces SET status='occupied', plate_number='闽F·77777',
    occupied_at=CURRENT_TIMESTAMP - INTERVAL '2 hours' WHERE space_id=36;
UPDATE parking_spaces SET status='occupied', plate_number='赣G·33333',
    occupied_at=CURRENT_TIMESTAMP - INTERVAL '40 minutes' WHERE space_id=38;
UPDATE parking_spaces SET status='occupied', plate_number='鄂H·22222',
    occupied_at=CURRENT_TIMESTAMP - INTERVAL '1 hour' WHERE space_id=42;
UPDATE parking_spaces SET status='occupied', plate_number='湘J·11111',
    occupied_at=CURRENT_TIMESTAMP - INTERVAL '3 hours' WHERE space_id=22;
UPDATE parking_spaces SET status='occupied', plate_number='浙D·99999',
    occupied_at=CURRENT_TIMESTAMP - INTERVAL '50 minutes' WHERE space_id=27;

-- 模拟历史出场和计费记录（今天已完成的停车）
-- 触发器自动：计算费用 → 生成计费记录 → 余额充足自动扣款/不足生成欠费
DO $$
DECLARE
    v_entry_id   INTEGER;
    v_exit_id    INTEGER;
    v_billing_id INTEGER;
BEGIN
    -- ===== 原有3条历史记录 =====

    -- 记录1: 浙D·99999 在中山北路 A02 停了2小时（张三余额200→自动扣款）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('浙D·99999', 1, 2, CURRENT_DATE + INTERVAL '8 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '浙D·99999', 1, 2,
            CURRENT_DATE + INTERVAL '8 hours',
            CURRENT_DATE + INTERVAL '10 hours');

    -- 记录2: 粤C·66666 在解放大道 C03 停了1小时（王五余额500→自动扣款）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('粤C·66666', 3, 17, CURRENT_DATE + INTERVAL '9 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '粤C·66666', 3, 17,
            CURRENT_DATE + INTERVAL '9 hours',
            CURRENT_DATE + INTERVAL '10 hours');

    -- 记录3: 京A·12345 在人民南路 B05 停了3小时（张三余额充足→自动扣款）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('京A·12345', 2, 13, CURRENT_DATE + INTERVAL '7 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '京A·12345', 2, 13,
            CURRENT_DATE + INTERVAL '7 hours',
            CURRENT_DATE + INTERVAL '10 hours');

    -- ===== 新增8条历史记录（覆盖更多路段和用户） =====

    -- 记录4: 苏E·55555 在文化路 E02 停45分钟（钱七余额5.00→自动扣款6.00，余额不足→欠费）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('苏E·55555', 5, 31, CURRENT_DATE + INTERVAL '10 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '苏E·55555', 5, 31,
            CURRENT_DATE + INTERVAL '10 hours',
            CURRENT_DATE + INTERVAL '10 hours 45 minutes');

    -- 记录5: 赣G·33333 在滨江大道 F04 停1小时晚高峰（周九余额300→自动扣款15.00）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('赣G·33333', 6, 37, CURRENT_DATE + INTERVAL '17 hours 30 minutes', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '赣G·33333', 6, 37,
            CURRENT_DATE + INTERVAL '17 hours 30 minutes',
            CURRENT_DATE + INTERVAL '18 hours 30 minutes');

    -- 记录6: 鄂H·22222 在湖滨北路 H03 停2小时（吴十余额25.00→自动扣款14.00）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('鄂H·22222', 8, 44, CURRENT_DATE + INTERVAL '10 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '鄂H·22222', 8, 44,
            CURRENT_DATE + INTERVAL '10 hours',
            CURRENT_DATE + INTERVAL '12 hours');

    -- 记录7: 湘J·11111 在建设路 D03 停3小时（郑婷余额10.00→扣款15.00，不足→欠费）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('湘J·11111', 4, 28, CURRENT_DATE + INTERVAL '9 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '湘J·11111', 4, 28,
            CURRENT_DATE + INTERVAL '9 hours',
            CURRENT_DATE + INTERVAL '12 hours');

    -- 记录8: 闽F·77777 在科技园南路 G05 停1小时白天（孙八余额80.00→自动扣款6.00）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('闽F·77777', 7, 41, CURRENT_DATE + INTERVAL '14 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '闽F·77777', 7, 41,
            CURRENT_DATE + INTERVAL '14 hours',
            CURRENT_DATE + INTERVAL '15 hours');

    -- 记录9: 苏E·55555 再次在文化路 E06 停1.5小时（钱七余额0.00→欠费12.00）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('苏E·55555', 5, 35, CURRENT_DATE + INTERVAL '13 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '苏E·55555', 5, 35,
            CURRENT_DATE + INTERVAL '13 hours',
            CURRENT_DATE + INTERVAL '14 hours 30 minutes');

    -- 记录10: 京A·67890 在解放大道 C09 停2小时晚高峰（张三余额充足→自动扣款24.00）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('京A·67890', 3, 23, CURRENT_DATE + INTERVAL '17 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '京A·67890', 3, 23,
            CURRENT_DATE + INTERVAL '17 hours',
            CURRENT_DATE + INTERVAL '19 hours');

    -- 记录11: 浙D·99999 在建设路 D04 停2小时（赵六余额0.00→欠费10.00）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('浙D·99999', 4, 29, CURRENT_DATE + INTERVAL '10 hours 30 minutes', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '浙D·99999', 4, 29,
            CURRENT_DATE + INTERVAL '10 hours 30 minutes',
            CURRENT_DATE + INTERVAL '12 hours 30 minutes');

    -- 记录12: 沪B·88888 在人民南路 B04 停4小时（李四余额15.00→扣款24.00，不足→欠费）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('沪B·88888', 2, 12, CURRENT_DATE + INTERVAL '8 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '沪B·88888', 2, 12,
            CURRENT_DATE + INTERVAL '8 hours',
            CURRENT_DATE + INTERVAL '12 hours');

    -- 记录13: 粤C·66666 在文化路 E03 停4小时（王五余额充足→自动扣款32.00）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('粤C·66666', 5, 33, CURRENT_DATE + INTERVAL '11 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '粤C·66666', 5, 33,
            CURRENT_DATE + INTERVAL '11 hours',
            CURRENT_DATE + INTERVAL '15 hours');

    -- 记录14: 湘J·11111 在湖滨北路 H05 停3小时（郑婷余额0.00→欠费21.00）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('湘J·11111', 8, 46, CURRENT_DATE + INTERVAL '14 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '湘J·11111', 8, 46,
            CURRENT_DATE + INTERVAL '14 hours',
            CURRENT_DATE + INTERVAL '17 hours');

    -- 记录15: 浙D·99999 再次在人民南路 B06 停1小时（赵六余额0.00→欠费6.00）
    INSERT INTO entry_records (plate_number, road_id, space_id, entry_time, geomagnetic_status)
    VALUES ('浙D·99999', 2, 14, CURRENT_DATE + INTERVAL '15 hours', 'occupied')
    RETURNING entry_id INTO v_entry_id;

    INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time, exit_time)
    VALUES (v_entry_id, '浙D·99999', 2, 14,
            CURRENT_DATE + INTERVAL '15 hours',
            CURRENT_DATE + INTERVAL '16 hours');
END $$;
