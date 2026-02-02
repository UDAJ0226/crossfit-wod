#!/usr/bin/env python3
"""CrossFit WOD 통합 서버 (정적 파일 + API)"""

import json
import os
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import threading
from datetime import datetime

# 설정
WEB_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'build', 'web')
DATA_FILE = os.path.join(os.path.dirname(__file__), 'user_data.json')

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

class CombinedHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def _set_json_headers(self, status=200):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_OPTIONS(self):
        self._set_json_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path

        # API 요청 처리
        if path.startswith('/api/'):
            self._handle_api_get(path, parsed.query)
        else:
            # 정적 파일 서빙
            super().do_GET()

    def do_POST(self):
        parsed = urlparse(self.path)
        path = parsed.path

        if path.startswith('/api/'):
            self._handle_api_post(path)
        else:
            self.send_error(404)

    def _handle_api_get(self, path, query_string):
        query = parse_qs(query_string)

        if path == '/api/check':
            nickname = query.get('nickname', [None])[0]
            if not nickname:
                self._set_json_headers(400)
                self.wfile.write(json.dumps({'error': 'nickname required'}).encode())
                return

            with data_lock:
                exists = nickname in user_data

            self._set_json_headers()
            self.wfile.write(json.dumps({'exists': exists}).encode())

        elif path == '/api/user':
            nickname = query.get('nickname', [None])[0]
            if not nickname:
                self._set_json_headers(400)
                self.wfile.write(json.dumps({'error': 'nickname required'}).encode())
                return

            with data_lock:
                data = user_data.get(nickname, {
                    'nickname': nickname,
                    'workoutRecords': [],
                    'personalRecords': [],
                    'createdAt': None
                })

            self._set_json_headers()
            self.wfile.write(json.dumps(data, ensure_ascii=False).encode())

        elif path == '/api/users':
            with data_lock:
                nicknames = list(user_data.keys())

            self._set_json_headers()
            self.wfile.write(json.dumps({'users': nicknames}).encode())

        else:
            self._set_json_headers(404)
            self.wfile.write(json.dumps({'error': 'not found'}).encode())

    def _handle_api_post(self, path):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8')

        try:
            data = json.loads(body) if body else {}
        except json.JSONDecodeError:
            self._set_json_headers(400)
            self.wfile.write(json.dumps({'error': 'invalid JSON'}).encode())
            return

        if path == '/api/user':
            nickname = data.get('nickname')
            if not nickname:
                self._set_json_headers(400)
                self.wfile.write(json.dumps({'error': 'nickname required'}).encode())
                return

            with data_lock:
                if nickname not in user_data:
                    user_data[nickname] = {
                        'nickname': nickname,
                        'workoutRecords': [],
                        'personalRecords': [],
                        'createdAt': datetime.now().isoformat()
                    }
                save_data(user_data)

            self._set_json_headers()
            self.wfile.write(json.dumps({'success': True, 'nickname': nickname}).encode())

        elif path == '/api/sync/workouts':
            nickname = data.get('nickname')
            records = data.get('records', [])

            if not nickname:
                self._set_json_headers(400)
                self.wfile.write(json.dumps({'error': 'nickname required'}).encode())
                return

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

            self._set_json_headers()
            self.wfile.write(json.dumps({'success': True, 'records': result}, ensure_ascii=False).encode())

        elif path == '/api/sync/pr':
            nickname = data.get('nickname')
            records = data.get('records', [])

            if not nickname:
                self._set_json_headers(400)
                self.wfile.write(json.dumps({'error': 'nickname required'}).encode())
                return

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

            self._set_json_headers()
            self.wfile.write(json.dumps({'success': True, 'records': result}, ensure_ascii=False).encode())

        else:
            self._set_json_headers(404)
            self.wfile.write(json.dumps({'error': 'not found'}).encode())

    def log_message(self, format, *args):
        if '/api/' in args[0]:
            print(f"[API] {args[0]}")
        # 정적 파일 로그는 생략

def run_server(port=9000):
    os.chdir(WEB_DIR)
    server = HTTPServer(('0.0.0.0', port), CombinedHandler)
    print(f"========================================")
    print(f"CrossFit WOD 서버 시작")
    print(f"주소: http://localhost:{port}")
    print(f"웹 디렉토리: {WEB_DIR}")
    print(f"데이터 파일: {DATA_FILE}")
    print(f"========================================")
    server.serve_forever()

if __name__ == '__main__':
    run_server()
