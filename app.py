#!/usr/bin/env python3
"""CrossFit WOD 서버 (Flask + 정적 파일)"""

import json
import os
from flask import Flask, request, jsonify, send_from_directory
from datetime import datetime
import threading

# 설정
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
WEB_DIR = os.path.join(BASE_DIR, 'build', 'web')
DATA_FILE = os.path.join(BASE_DIR, 'user_data.json')

app = Flask(__name__, static_folder=WEB_DIR, static_url_path='')

# 데이터 관리
def load_data():
    if os.path.exists(DATA_FILE):
        try:
            with open(DATA_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        except:
            return {}
    return {}

def save_data(data):
    with open(DATA_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

user_data = load_data()
data_lock = threading.Lock()

# 정적 파일 서빙
@app.route('/')
def index():
    return send_from_directory(WEB_DIR, 'index.html')

@app.route('/<path:path>')
def static_files(path):
    if os.path.exists(os.path.join(WEB_DIR, path)):
        return send_from_directory(WEB_DIR, path)
    return send_from_directory(WEB_DIR, 'index.html')

# API 엔드포인트
@app.route('/api/check', methods=['GET'])
def check_nickname():
    nickname = request.args.get('nickname')
    if not nickname:
        return jsonify({'error': 'nickname required'}), 400

    with data_lock:
        exists = nickname in user_data

    return jsonify({'exists': exists})

@app.route('/api/user', methods=['GET'])
def get_user():
    nickname = request.args.get('nickname')
    if not nickname:
        return jsonify({'error': 'nickname required'}), 400

    with data_lock:
        data = user_data.get(nickname, {
            'nickname': nickname,
            'workoutRecords': [],
            'personalRecords': [],
            'createdAt': None
        })

    return jsonify(data)

@app.route('/api/user', methods=['POST'])
def create_user():
    data = request.get_json() or {}
    nickname = data.get('nickname')

    if not nickname:
        return jsonify({'error': 'nickname required'}), 400

    with data_lock:
        if nickname not in user_data:
            user_data[nickname] = {
                'nickname': nickname,
                'workoutRecords': [],
                'personalRecords': [],
                'createdAt': datetime.now().isoformat()
            }
        save_data(user_data)

    return jsonify({'success': True, 'nickname': nickname})

@app.route('/api/users', methods=['GET'])
def get_users():
    with data_lock:
        nicknames = list(user_data.keys())

    return jsonify({'users': nicknames})

@app.route('/api/sync/workouts', methods=['POST'])
def sync_workouts():
    data = request.get_json() or {}
    nickname = data.get('nickname')
    records = data.get('records', [])

    if not nickname:
        return jsonify({'error': 'nickname required'}), 400

    with data_lock:
        if nickname not in user_data:
            user_data[nickname] = {
                'nickname': nickname,
                'workoutRecords': [],
                'personalRecords': [],
                'createdAt': datetime.now().isoformat()
            }

        existing = {r['id']: r for r in user_data[nickname].get('workoutRecords', [])}
        for record in records:
            existing[record['id']] = record
        user_data[nickname]['workoutRecords'] = list(existing.values())
        save_data(user_data)
        result = user_data[nickname]['workoutRecords']

    return jsonify({'success': True, 'records': result})

@app.route('/api/sync/pr', methods=['POST'])
def sync_pr():
    data = request.get_json() or {}
    nickname = data.get('nickname')
    records = data.get('records', [])

    if not nickname:
        return jsonify({'error': 'nickname required'}), 400

    with data_lock:
        if nickname not in user_data:
            user_data[nickname] = {
                'nickname': nickname,
                'workoutRecords': [],
                'personalRecords': [],
                'createdAt': datetime.now().isoformat()
            }

        existing = {r['id']: r for r in user_data[nickname].get('personalRecords', [])}
        for record in records:
            existing[record['id']] = record
        user_data[nickname]['personalRecords'] = list(existing.values())
        save_data(user_data)
        result = user_data[nickname]['personalRecords']

    return jsonify({'success': True, 'records': result})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 9000))
    app.run(host='0.0.0.0', port=port, debug=False)
