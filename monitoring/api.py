#!/usr/bin/env python3
"""
TinAI Monitor API — serveur HTTP minimaliste
Expose /api/system, /api/containers, /api/logs
Tourne dans le conteneur monitoring, accède au docker.sock
"""
import json, os, subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.request import urlopen, Request
from urllib.error import URLError
import socket, struct

DOCKER_SOCK = '/var/run/docker.sock'
LLAMA_HOST  = os.environ.get('LLAMA_HOST', 'tinai-llama')
LLAMA_PORT  = os.environ.get('LLAMA_PORT', '8080')
LOG_CONTAINER = 'tinai-llama'
LOG_LINES = 60


# ── Cache CPU (lecture non-bloquante) ────────────────────────────
_cpu_cache = {'idle': 0, 'total': 0, 'pct': 0.0}

def read_cpu_stat():
    try:
        with open('/host/proc/stat') as f:
            cpu = f.readline().split()
        idle  = int(cpu[4])
        total = sum(int(x) for x in cpu[1:])
        return idle, total
    except Exception:
        return 0, 1

def get_cpu_pct():
    global _cpu_cache
    idle2, total2 = read_cpu_stat()
    idle1, total1 = _cpu_cache['idle'], _cpu_cache['total']
    _cpu_cache['idle'], _cpu_cache['total'] = idle2, total2
    if total2 - total1 > 0:
        _cpu_cache['pct'] = round(100.0 * (1 - (idle2-idle1)/(total2-total1)), 1)
    return _cpu_cache['pct']

# ── Docker socket client ──────────────────────────────────────────
def docker_get(path):
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(DOCKER_SOCK)
    req = f"GET {path} HTTP/1.0\r\nHost: localhost\r\n\r\n"
    sock.sendall(req.encode())
    data = b''
    while True:
        chunk = sock.recv(4096)
        if not chunk: break
        data += chunk
    sock.close()
    # Extraire le corps JSON (après \r\n\r\n)
    body = data.split(b'\r\n\r\n', 1)[-1]
    return json.loads(body)


def get_containers():
    try:
        items = docker_get('/containers/json?all=true')
        result = []
        for c in items:
            name = c['Names'][0].lstrip('/')
            # Récupérer stats mémoire (non-bloquant)
            mem_mb = None
            try:
                stats = docker_get(f'/containers/{c["Id"]}/stats?stream=false')
                mem = stats.get('memory_stats', {})
                usage = mem.get('usage', 0)
                cache = mem.get('stats', {}).get('cache', 0)
                mem_mb = round((usage - cache) / 1048576)
            except Exception:
                pass
            result.append({
                'name': name,
                'state': c['State'],
                'status': c['Status'],
                'mem_mb': mem_mb,
            })
        return result
    except Exception as e:
        return []


def get_logs():
    try:
        # Récupérer les N dernières lignes via docker logs
        result = subprocess.run(
            ['docker', 'logs', '--tail', str(LOG_LINES), '--timestamps', LOG_CONTAINER],
            capture_output=True, text=True, timeout=5
        )
        lines = (result.stdout + result.stderr).strip().splitlines()
        return lines[-LOG_LINES:]
    except Exception:
        return []


def get_system():
    # CPU (non-bloquant — delta entre deux appels)
    try:
        cpu_pct   = get_cpu_pct()
        cpu_count = os.cpu_count() or 1
    except Exception:
        cpu_pct, cpu_count = 0.0, 1

    # Load average
    try:
        with open('/host/proc/loadavg') as f:
            load1 = float(f.read().split()[0])
    except Exception:
        load1 = 0

    # RAM
    try:
        mem = {}
        with open('/host/proc/meminfo') as f:
            for line in f:
                k, v = line.split(':')
                mem[k.strip()] = int(v.split()[0]) * 1024
        mem_total = mem.get('MemTotal', 0)
        mem_avail = mem.get('MemAvailable', 0)
        mem_used  = mem_total - mem_avail
    except Exception:
        mem_total = mem_used = 0

    # Disk
    try:
        st = os.statvfs('/host')
        disk_total = st.f_blocks * st.f_frsize
        disk_free  = st.f_bavail * st.f_frsize
        disk_used  = disk_total - disk_free
        disk_pct   = 100.0 * disk_used / disk_total if disk_total else 0
    except Exception:
        disk_total = disk_used = disk_pct = 0

    # Uptime
    try:
        with open('/host/proc/uptime') as f:
            uptime_s = int(float(f.read().split()[0]))
    except Exception:
        uptime_s = 0

    # Hostname
    try:
        with open('/host/etc/hostname') as f:
            hostname = f.read().strip()
    except Exception:
        hostname = socket.gethostname()

    return {
        'cpu_pct': round(cpu_pct, 1),
        'cpu_count': cpu_count,
        'load1': round(load1, 2),
        'mem_total': mem_total,
        'mem_used': mem_used,
        'disk_total': disk_total,
        'disk_used': disk_used,
        'disk_pct': round(disk_pct, 1),
        'uptime_s': uptime_s,
        'hostname': hostname,
    }


# ── Proxy vers llama-server ───────────────────────────────────────
def llama_proxy(path):
    url = f'http://{LLAMA_HOST}:{LLAMA_PORT}{path}'
    try:
        r = urlopen(Request(url), timeout=3)
        return json.loads(r.read())
    except Exception:
        return None


# ── Handler HTTP ──────────────────────────────────────────────────
class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args): pass  # silencieux

    def send_json(self, data, status=200):
        body = json.dumps(data).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', len(body))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        p = self.path.split('?')[0]
        if p == '/api/system':
            self.send_json(get_system())
        elif p == '/api/containers':
            self.send_json(get_containers())
        elif p == '/api/logs':
            self.send_json(get_logs())
        elif p == '/api/llama/health':
            d = llama_proxy('/health')
            self.send_json(d or {}, 200 if d else 503)
        elif p == '/api/llama/models':
            d = llama_proxy('/v1/models')
            self.send_json(d or {'data': []})
        elif p == '/health':
            self.send_json({'status': 'ok'})
        else:
            self.send_response(404)
            self.end_headers()


if __name__ == '__main__':
    port = int(os.environ.get('API_PORT', 8888))
    print(f'[tinai-monitor] API sur :{port}')
    HTTPServer(('0.0.0.0', port), Handler).serve_forever()
