import os
from datetime import datetime, date
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__, static_folder=None)
CORS(app)

STATIC_DIR = os.environ.get('STATIC_DIR', '../frontend/dist')

DB_CONFIG = {
    'host':     os.environ.get('DB_HOST', 'localhost'),
    'port':     int(os.environ.get('DB_PORT', 5432)),
    'dbname':   os.environ.get('DB_NAME', 'parking_system'),
    'user':     os.environ.get('DB_USER', 'postgres'),
    'password': os.environ.get('DB_PASSWORD', 'postgres123'),
}


def get_db():
    return psycopg2.connect(**DB_CONFIG)


def dict_fetchall(cursor):
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


def json_serial(obj):
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    raise TypeError(f"Type {type(obj)} not serializable")


@app.route('/')
def index():
    return send_from_directory(STATIC_DIR, 'index.html')




# ──────────────────────────────────────────────
# 路段管理
# ──────────────────────────────────────────────
@app.route('/api/roads', methods=['GET'])
def get_roads():
    conn = get_db()
    cur  = conn.cursor()
    cur.execute('''
        SELECT rs.*,
               (SELECT COUNT(*) FROM parking_spaces ps WHERE ps.road_id = rs.road_id) AS actual_spaces,
               (SELECT COUNT(*) FROM parking_spaces ps
                WHERE ps.road_id = rs.road_id AND ps.status = 'free') AS free_spaces
        FROM road_sections rs ORDER BY rs.road_id
    ''')
    rows = dict_fetchall(cur)
    cur.close(); conn.close()
    return jsonify(rows)


@app.route('/api/roads', methods=['POST'])
def add_road():
    data = request.json
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute(
            'INSERT INTO road_sections (road_name, section_code, total_spaces, address) '
            'VALUES (%s,%s,%s,%s) RETURNING road_id',
            (data['road_name'], data['section_code'],
             data['total_spaces'], data.get('address', ''))
        )
        road_id = cur.fetchone()[0]
        conn.commit()
        return jsonify({'road_id': road_id, 'message': '添加成功'}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close(); conn.close()


@app.route('/api/roads/<int:road_id>', methods=['DELETE'])
def delete_road(road_id):
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute('DELETE FROM road_sections WHERE road_id = %s', (road_id,))
        conn.commit()
        return jsonify({'message': '删除成功'})
    except Exception as e:
        conn.rollback()
        return jsonify({'error': '该路段下存在关联数据，无法删除: ' + str(e)}), 400
    finally:
        cur.close(); conn.close()


# ──────────────────────────────────────────────
# 收费标准
# ──────────────────────────────────────────────
@app.route('/api/roads/<int:road_id>/standards', methods=['GET'])
def get_standards(road_id):
    conn = get_db()
    cur  = conn.cursor()
    cur.execute(
        'SELECT * FROM charging_standards WHERE road_id=%s ORDER BY start_hour',
        (road_id,)
    )
    rows = dict_fetchall(cur)
    cur.close(); conn.close()
    return jsonify(rows)


@app.route('/api/standards', methods=['POST'])
def add_standard():
    data = request.json
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute(
            'INSERT INTO charging_standards (road_id, period_name, start_hour, end_hour, price_per_hour) '
            'VALUES (%s,%s,%s,%s,%s) RETURNING standard_id',
            (data['road_id'], data['period_name'],
             data['start_hour'], data['end_hour'], data['price_per_hour'])
        )
        sid = cur.fetchone()[0]
        conn.commit()
        return jsonify({'standard_id': sid, 'message': '添加成功'}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close(); conn.close()


# ──────────────────────────────────────────────
# 停车位管理
# ──────────────────────────────────────────────
@app.route('/api/spaces', methods=['GET'])
def get_spaces():
    road_id = request.args.get('road_id')
    conn = get_db()
    cur  = conn.cursor()
    if road_id:
        cur.execute('''
            SELECT ps.*, rs.road_name
            FROM parking_spaces ps
            JOIN road_sections rs ON ps.road_id = rs.road_id
            WHERE ps.road_id = %s
            ORDER BY ps.space_number
        ''', (road_id,))
    else:
        cur.execute('''
            SELECT ps.*, rs.road_name
            FROM parking_spaces ps
            JOIN road_sections rs ON ps.road_id = rs.road_id
            ORDER BY ps.road_id, ps.space_number
        ''')
    rows = dict_fetchall(cur)
    cur.close(); conn.close()
    return jsonify(rows)


@app.route('/api/spaces/available', methods=['GET'])
def get_available_spaces():
    road_id = request.args.get('road_id')
    conn = get_db()
    cur  = conn.cursor()
    if road_id:
        cur.execute(
            'SELECT * FROM v_available_spaces WHERE road_id = %s',
            (road_id,)
        )
    else:
        cur.execute('SELECT * FROM v_available_spaces')
    rows = dict_fetchall(cur)
    cur.close(); conn.close()
    return jsonify(rows)


# ──────────────────────────────────────────────
# 用户管理
# ──────────────────────────────────────────────
@app.route('/api/users', methods=['GET'])
def get_users():
    conn = get_db()
    cur  = conn.cursor()
    cur.execute('''
        SELECT u.*,
               (SELECT COUNT(*) FROM user_vehicles uv WHERE uv.user_id = u.user_id) AS vehicle_count,
               (SELECT COALESCE(SUM(ar.arrears_amount), 0)
                FROM arrears_records ar
                WHERE ar.user_id = u.user_id AND ar.status = 'pending') AS total_arrears
        FROM users u ORDER BY u.user_id
    ''')
    rows = dict_fetchall(cur)
    cur.close(); conn.close()
    return jsonify(rows)


@app.route('/api/users', methods=['POST'])
def add_user():
    data = request.json
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute(
            'INSERT INTO users (username, phone, balance) VALUES (%s,%s,%s) RETURNING user_id',
            (data['username'], data['phone'], data.get('balance', 0))
        )
        uid = cur.fetchone()[0]
        conn.commit()
        return jsonify({'user_id': uid, 'message': '注册成功'}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close(); conn.close()


@app.route('/api/users/<int:user_id>/topup', methods=['POST'])
def topup_user(user_id):
    amount = request.json.get('amount', 0)
    if amount <= 0:
        return jsonify({'error': '充值金额必须大于 0'}), 400
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute(
            'UPDATE users SET balance = balance + %s WHERE user_id = %s RETURNING balance',
            (amount, user_id)
        )
        new_balance = cur.fetchone()[0]
        conn.commit()
        return jsonify({'balance': str(new_balance), 'message': f'充值成功，当前余额 ¥{new_balance}'})
    finally:
        cur.close(); conn.close()


# ──────────────────────────────────────────────
# 车辆绑定
# ──────────────────────────────────────────────
@app.route('/api/users/<int:user_id>/vehicles', methods=['GET'])
def get_user_vehicles(user_id):
    conn = get_db()
    cur  = conn.cursor()
    cur.execute(
        'SELECT * FROM user_vehicles WHERE user_id = %s ORDER BY bind_time DESC',
        (user_id,)
    )
    rows = dict_fetchall(cur)
    cur.close(); conn.close()
    return jsonify(rows)


@app.route('/api/vehicles', methods=['POST'])
def bind_vehicle():
    data = request.json
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute(
            'INSERT INTO user_vehicles (user_id, plate_number) VALUES (%s,%s) RETURNING binding_id',
            (data['user_id'], data['plate_number'])
        )
        bid = cur.fetchone()[0]
        conn.commit()
        return jsonify({'binding_id': bid, 'message': '绑定成功'}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close(); conn.close()


# ──────────────────────────────────────────────
# 车辆入场
# ──────────────────────────────────────────────
@app.route('/api/entry', methods=['POST'])
def vehicle_entry():
    data = request.json
    plate = data['plate_number']
    road_id  = int(data['road_id'])
    space_id = int(data['space_id'])

    conn = get_db()
    cur  = conn.cursor()
    try:
        # 检查车位是否空闲
        cur.execute(
            "SELECT status FROM parking_spaces WHERE space_id = %s",
            (space_id,)
        )
        space = cur.fetchone()
        if not space:
            return jsonify({'error': '车位不存在'}), 404
        if space[0] != 'free':
            return jsonify({'error': '该车位当前不可用'}), 400

        # 检查是否已入场未出场
        cur.execute(
            '''SELECT er.entry_id FROM entry_records er
               WHERE er.plate_number = %s
                 AND er.entry_id NOT IN (SELECT entry_id FROM exit_records)''',
            (plate,)
        )
        if cur.fetchone():
            return jsonify({'error': f'车牌 {plate} 已入场，尚未出场'}), 400

        # 写入入场记录
        cur.execute(
            'INSERT INTO entry_records (plate_number, road_id, space_id) '
            'VALUES (%s,%s,%s) RETURNING entry_id, entry_time',
            (plate, road_id, space_id)
        )
        entry_id, entry_time = cur.fetchone()

        # 更新车位状态
        cur.execute(
            '''UPDATE parking_spaces
               SET status='occupied', plate_number=%s, occupied_at=%s, updated_at=%s
               WHERE space_id = %s''',
            (plate, entry_time, entry_time, space_id)
        )

        conn.commit()
        return jsonify({
            'entry_id': entry_id,
            'entry_time': entry_time.isoformat(),
            'message': f'车牌 {plate} 入场成功，车位 {space_id}'
        }), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close(); conn.close()


# ──────────────────────────────────────────────
# 车辆出场（触发器自动计费 + 余额判断）
# ──────────────────────────────────────────────
@app.route('/api/exit', methods=['POST'])
def vehicle_exit():
    data = request.json
    plate = data['plate_number']

    conn = get_db()
    cur  = conn.cursor()
    try:
        # 查找当前未出场的入场记录
        cur.execute(
            '''SELECT er.entry_id, er.road_id, er.space_id, er.entry_time
               FROM entry_records er
               WHERE er.plate_number = %s
                 AND er.entry_id NOT IN (SELECT entry_id FROM exit_records)
               ORDER BY er.entry_time DESC LIMIT 1''',
            (plate,)
        )
        entry = cur.fetchone()
        if not entry:
            return jsonify({'error': f'未找到车牌 {plate} 的有效入场记录'}), 404

        entry_id, road_id, space_id, entry_time = entry

        # 写入出场记录（触发器自动完成计费、扣款、欠费处理）
        cur.execute(
            '''INSERT INTO exit_records (entry_id, plate_number, road_id, space_id, entry_time)
               VALUES (%s,%s,%s,%s,%s)
               RETURNING exit_id''',
            (entry_id, plate, road_id, space_id, entry_time)
        )
        exit_id = cur.fetchone()[0]

        # 触发器已更新 duration_minutes 和 fee，重新查询获取
        cur.execute(
            'SELECT exit_id, exit_time, duration_minutes, fee FROM exit_records WHERE exit_id = %s',
            (exit_id,)
        )
        exit_row = cur.fetchone()
        exit_id, exit_time, duration, fee = exit_row

        # 查询计费结果
        cur.execute(
            'SELECT * FROM billing_records WHERE exit_id = %s',
            (exit_id,)
        )
        billing = dict_fetchall(cur)
        billing = billing[0] if billing else {}

        # 查询是否产生欠费
        cur.execute(
            'SELECT * FROM arrears_records WHERE billing_id = %s',
            (billing.get('billing_id'),)
        )
        arrears = dict_fetchall(cur)

        conn.commit()

        result = {
            'exit_id': exit_id,
            'exit_time': exit_time.isoformat() if exit_time else None,
            'duration_minutes': duration,
            'fee': str(fee) if fee else '0.00',
            'billing': billing,
            'arrears': arrears,
            'message': f'出场成功 | 时长 {duration} 分钟 | 费用 ¥{fee}'
        }

        if billing.get('payment_status') == 'arrears':
            result['warning'] = '账户余额不足，已生成欠费记录，请及时充值缴费'

        return jsonify(result)
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close(); conn.close()


# ──────────────────────────────────────────────
# 入场 / 出场记录
# ──────────────────────────────────────────────
@app.route('/api/entries', methods=['GET'])
def get_entries():
    conn = get_db()
    cur  = conn.cursor()
    cur.execute('''
        SELECT er.*, rs.road_name,
               CASE WHEN xr.exit_id IS NULL THEN '在场' ELSE '已出场' END AS current_status
        FROM entry_records er
        JOIN road_sections rs ON er.road_id = rs.road_id
        LEFT JOIN exit_records xr ON er.entry_id = xr.entry_id
        ORDER BY er.entry_time DESC LIMIT 100
    ''')
    rows = dict_fetchall(cur)
    cur.close(); conn.close()
    return jsonify(rows)


@app.route('/api/exits', methods=['GET'])
def get_exits():
    conn = get_db()
    cur  = conn.cursor()
    cur.execute('''
        SELECT xr.*, rs.road_name,
               ps.space_number
        FROM exit_records xr
        JOIN road_sections rs ON xr.road_id = rs.road_id
        JOIN parking_spaces ps ON xr.space_id = ps.space_id
        ORDER BY xr.exit_time DESC LIMIT 100
    ''')
    rows = dict_fetchall(cur)
    cur.close(); conn.close()
    return jsonify(rows)


# ──────────────────────────────────────────────
# 计费记录
# ──────────────────────────────────────────────
@app.route('/api/billing', methods=['GET'])
def get_billing():
    conn = get_db()
    cur  = conn.cursor()
    cur.execute('''
        SELECT br.*,
               u.username,
               xr.entry_time, xr.exit_time, xr.duration_minutes,
               xr.road_id, rs.road_name, ps.space_number
        FROM billing_records br
        LEFT JOIN users u ON br.user_id = u.user_id
        LEFT JOIN exit_records xr ON br.exit_id = xr.exit_id
        LEFT JOIN road_sections rs ON xr.road_id = rs.road_id
        LEFT JOIN parking_spaces ps ON xr.space_id = ps.space_id
        ORDER BY br.created_at DESC LIMIT 100
    ''')
    rows = dict_fetchall(cur)
    cur.close(); conn.close()
    return jsonify(rows)


@app.route('/api/billing/<int:billing_id>/pay', methods=['POST'])
def pay_billing(billing_id):
    """手动结算（补缴）"""
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute(
            'SELECT billing_id, user_id, total_fee, actual_paid, payment_status '
            'FROM billing_records WHERE billing_id = %s',
            (billing_id,)
        )
        bill = cur.fetchone()
        if not bill:
            return jsonify({'error': '计费记录不存在'}), 404

        _, user_id, total_fee, actual_paid, status = bill
        remaining = total_fee - actual_paid

        if status == 'paid':
            return jsonify({'message': '该记录已结清'}), 400

        cur.execute('SELECT balance FROM users WHERE user_id = %s', (user_id,))
        bal = cur.fetchone()
        if not bal:
            return jsonify({'error': '用户不存在'}), 404

        balance = bal[0]
        if balance < remaining:
            return jsonify({'error': f'余额不足，需 ¥{remaining}，当前余额 ¥{balance}'}), 400

        # 扣款
        cur.execute(
            'UPDATE users SET balance = balance - %s WHERE user_id = %s',
            (remaining, user_id)
        )
        cur.execute(
            '''UPDATE billing_records
               SET actual_paid = total_fee, payment_status = 'paid',
                   payment_method = 'wallet', payment_time = CURRENT_TIMESTAMP
               WHERE billing_id = %s''',
            (billing_id,)
        )
        cur.execute(
            "UPDATE arrears_records SET status='paid', paid_at=CURRENT_TIMESTAMP "
            "WHERE billing_id = %s AND status='pending'",
            (billing_id,)
        )

        # 检查用户是否还有其他欠费
        cur.execute(
            "SELECT COUNT(*) FROM arrears_records WHERE user_id=%s AND status='pending'",
            (user_id,)
        )
        if cur.fetchone()[0] == 0:
            cur.execute(
                "UPDATE users SET status='active' WHERE user_id=%s AND status='arrears'",
                (user_id,)
            )

        conn.commit()
        return jsonify({'message': '缴费成功'})
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        cur.close(); conn.close()


# ──────────────────────────────────────────────
# 欠费追缴记录
# ──────────────────────────────────────────────
@app.route('/api/arrears', methods=['GET'])
def get_arrears():
    status = request.args.get('status')
    conn = get_db()
    cur  = conn.cursor()
    if status:
        cur.execute('''
            SELECT ar.*, u.username, u.phone
            FROM arrears_records ar
            LEFT JOIN users u ON ar.user_id = u.user_id
            WHERE ar.status = %s
            ORDER BY ar.created_at DESC
        ''', (status,))
    else:
        cur.execute('''
            SELECT ar.*, u.username, u.phone
            FROM arrears_records ar
            LEFT JOIN users u ON ar.user_id = u.user_id
            ORDER BY ar.created_at DESC
        ''')
    rows = dict_fetchall(cur)
    cur.close(); conn.close()
    return jsonify(rows)


# ──────────────────────────────────────────────
# 统计仪表盘
# ──────────────────────────────────────────────
@app.route('/api/stats/dashboard', methods=['GET'])
def dashboard_stats():
    conn = get_db()
    cur  = conn.cursor()
    today = date.today()

    # 总路段数
    cur.execute('SELECT COUNT(*) FROM road_sections')
    total_roads = cur.fetchone()[0]

    # 总车位数
    cur.execute('SELECT COUNT(*) FROM parking_spaces')
    total_spaces = cur.fetchone()[0]

    # 空闲车位
    cur.execute("SELECT COUNT(*) FROM parking_spaces WHERE status='free'")
    free_spaces = cur.fetchone()[0]

    # 今日出场次数
    cur.execute(
        "SELECT COUNT(*) FROM exit_records WHERE exit_time >= %s",
        (today,)
    )
    today_exits = cur.fetchone()[0]

    # 今日营收
    cur.execute(
        "SELECT COALESCE(SUM(actual_paid), 0) FROM billing_records WHERE created_at >= %s",
        (today,)
    )
    today_revenue = cur.fetchone()[0]

    # 今日欠费总额
    cur.execute(
        "SELECT COALESCE(SUM(arrears_amount), 0) FROM arrears_records WHERE created_at >= %s AND status='pending'",
        (today,)
    )
    today_arrears = cur.fetchone()[0]

    # 总用户数
    cur.execute('SELECT COUNT(*) FROM users')
    total_users = cur.fetchone()[0]

    cur.close(); conn.close()
    return jsonify({
        'total_roads':   total_roads,
        'total_spaces':  total_spaces,
        'free_spaces':   free_spaces,
        'occupied_spaces': total_spaces - free_spaces,
        'occupancy_rate': round((total_spaces - free_spaces) / total_spaces * 100, 1) if total_spaces else 0,
        'today_exits':   today_exits,
        'today_revenue': str(today_revenue),
        'today_arrears': str(today_arrears),
        'total_users':   total_users,
    })


# ──────────────────────────────────────────────
# 存储过程调用：每日统计
# ──────────────────────────────────────────────
@app.route('/api/stats/daily', methods=['GET'])
def daily_stats():
    d = request.args.get('date', date.today().isoformat())
    conn = get_db()
    cur  = conn.cursor()
    cur.execute('SELECT * FROM fn_daily_statistics(%s::date)', (d,))
    rows = dict_fetchall(cur)
    cur.close(); conn.close()
    return jsonify(rows)


# ──────────────────────────────────────────────
# 地磁状态查询（模拟）
# ──────────────────────────────────────────────
@app.route('/api/geomagnetic', methods=['GET'])
def get_geomagnetic():
    conn = get_db()
    cur  = conn.cursor()
    cur.execute('''
        SELECT ps.space_id, ps.space_number, ps.space_position,
               ps.status, ps.plate_number, ps.occupied_at,
               rs.road_name, rs.section_code,
               CASE WHEN er.entry_id IS NOT NULL THEN er.geomagnetic_status
                    ELSE 'vacant' END AS geomagnetic_status
        FROM parking_spaces ps
        JOIN road_sections rs ON ps.road_id = rs.road_id
        LEFT JOIN entry_records er ON er.space_id = ps.space_id
            AND er.entry_id NOT IN (SELECT entry_id FROM exit_records)
        ORDER BY ps.road_id, ps.space_number
    ''')
    rows = dict_fetchall(cur)
    cur.close(); conn.close()
    return jsonify(rows)


# SPA catch-all: serve index.html for non-API routes (Vue Router history mode)
@app.route('/<path:path>')
def catch_all(path):
    file_path = os.path.join(STATIC_DIR, path)
    if os.path.isfile(file_path):
        return send_from_directory(STATIC_DIR, path)
    return send_from_directory(STATIC_DIR, 'index.html')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
