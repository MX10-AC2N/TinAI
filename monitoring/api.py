#!/usr/bin/env python3
"""
TinAI Monitor API v2 — serveur HTTP minimaliste
Expose /api/system, /api/containers, /api/logs, /api/llama/*
"""
import json, os, subprocess, socket
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.request import urlopen, Request

DOCKER_SOCK   = '/var/run/docker.sock'
LLAMA_HOST    = os.environ.get('LLAMA_HOST', 'llama')
LLAMA_PORT    = os.environ.get('LLAMA_PORT', '8080')
LOG_CONTAINER = 'tinai-llama'
LOG_LINES     = 60

# ── Cache CPU (lecture non-bloquante entre deux requêtes) ─────────
_cpu = {'idle': 0, 'total': 0, 'pct': 0.0}

def _read_stat():
    try:
        with open('/host/proc/stat') as f:
            c = f.readline().split()
        return int(c[4]), sum(int(x) for x in c[1:])
    except Exception:
        return 0, 1

def get_cpu_pct():
    idle2, total2 = _read_stat()
    d_idle  = idle2  - _cpu['idle']
    d_total = total2 - _cpu['total']
    _cpu['idle'], _cpu['total'] = idle2, total2
    if d_total > 0:
        _cpu['pct'] = round(100.0 * (1 - d_idle / d_total), 1)
    return _cpu['pct']

# ── Docker socket client ──────────────────────────────────────────
def docker_get(path):
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(5)
    sock.connect(DOCKER_SOCK)
    req = f"GET {path} HTTP/1.0\r\nHost: localhost\r\n\r\n"
    sock.sendall(req.encode())
    data = b''
    while True:
        chunk = sock.recv(4096)
        if not chunk:
            break
        data += chunk
    sock.close()
    body = data.split(b'\r\n\r\n', 1)[-1]
    return json.loads(body)

def get_containers():
    try:
        items = docker_get('/containers/json?all=true')
        result = []
        for c in items:
            name = c['Names'][0].lstrip('/')
            mem_mb = None
            try:
                stats = docker_get(f'/containers/{c["Id"]}/stats?stream=false')
                mem   = stats.get('memory_stats', {})
                usage = mem.get('usage', 0)
                cache = mem.get('stats', {}).get('cache', 0)
                mem_mb = round((usage - cache) / 1048576)
            except Exception:
                pass
            result.append({
                'name':   name,
                'state':  c['State'],
                'status': c['Status'],
                'mem_mb': mem_mb,
            })
        return result
    except Exception:
        return []

def get_logs():
    try:
        r = subprocess.run(
            ['docker', 'logs', '--tail', str(LOG_LINES), '--timestamps', LOG_CONTAINER],
            capture_output=True, text=True, timeout=5
        )
        lines = (r.stdout + r.stderr).strip().splitlines()
        return lines[-LOG_LINES:]
    except Exception:
        return []

def get_system():
    # CPU
    try:
        cpu_pct   = get_cpu_pct()
        cpu_count = os.cpu_count() or 1
    except Exception:
        cpu_pct, cpu_count = 0.0, 1

    # Load
    try:
        with open('/host/proc/loadavg') as f:
            load1 = float(f.read().split()[0])
    except Exception:
        load1 = 0.0

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
        st         = os.statvfs('/host')
        disk_total = st.f_blocks * st.f_frsize
        disk_free  = st.f_bavail * st.f_frsize
        disk_used  = disk_total - disk_free
        disk_pct   = round(100.0 * disk_used / disk_total, 1) if disk_total else 0
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
        'cpu_pct':    cpu_pct,
        'cpu_count':  cpu_count,
        'load1':      round(load1, 2),
        'mem_total':  mem_total,
        'mem_used':   mem_used,
        'disk_total': disk_total,
        'disk_used':  disk_used,
        'disk_pct':   disk_pct,
        'uptime_s':   uptime_s,
        'hostname':   hostname,
    }

def llama_proxy(path):
    url = f'http://{LLAMA_HOST}:{LLAMA_PORT}{path}'
    try:
        r = urlopen(Request(url), timeout=3)
        return json.loads(r.read())
    except Exception:
        return None

# ── Handler HTTP ──────────────────────────────────────────────────
class Handler(BaseHTTPRequestHandler):
    def log_message(self, *a): pass

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
        if   p == '/api/system':       self.send_json(get_system())
        elif p == '/api/containers':   self.send_json(get_containers())
        elif p == '/api/logs':         self.send_json(get_logs())
        elif p == '/api/llama/health':
            d = llama_proxy('/health')
            self.send_json(d or {}, 200 if d else 503)
        elif p == '/api/llama/models':
            d = llama_proxy('/v1/models')
            self.send_json(d or {'data': []})
        elif p == '/health':           self.send_json({'status': 'ok'})
        else:
            self.send_response(404); self.end_headers()

if __name__ == '__main__':
    port = int(os.environ.get('API_PORT', 8888))
    print(f'[tinai-monitor] API v2 sur :{port}')
    HTTPServer(('0.0.0.0', port), Handler).serve_forever()
