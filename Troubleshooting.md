# Troubleshooting / Dépannage

[🇬🇧 English](#-english) · [🇫🇷 Français](#-français)

---

## 🇬🇧 English

### llama-server keeps restarting (exit 127)

**Cause:** `set -euo pipefail` in the start script + reduced PATH in supervisord.

**Solution:** Already fixed in v3.1. Make sure you're using the latest `scripts/start-llama.sh`.

```bash
docker compose exec tinai supervisorctl status
docker compose exec tinai tail -20 /var/log/tinai/llama.err
```

### Model download fails

```bash
# Option 1: Pre-download manually
mkdir -p models
wget -O models/qwen3-1.7b-q5_k_m.gguf \
  "https://huggingface.co/Qwen/Qwen3-1.7B-GGUF/resolve/main/qwen3-1.7b-q5_k_m.gguf"

# Then start (no download needed)
docker compose up -d
```

### Open WebUI not loading (port 3000)

```bash
# Check WebUI logs
docker compose exec tinai tail -30 /var/log/tinai/webui.log

# Restart WebUI only
docker compose exec tinai supervisorctl restart webui
```

### OpenFang dashboard unreachable (port 4200)

```bash
docker compose exec tinai tail -30 /var/log/tinai/openfang.log
docker compose exec tinai supervisorctl restart openfang

# Check openfang binary
docker compose exec tinai openfang --version
```

### Out of memory (OOM)

Reduce context size and memory limit:

```dotenv
LLAMA_CTX_SIZE=2048
MEM_LIMIT=4g
```

Or switch to a lighter model:
```dotenv
LLAMA_HF_FILE=qwen3-1.7b-q4_k_m.gguf
```

### Port already in use

```bash
# Find what's using port 3000
lsof -i :3000

# Change port in .env
PORT_WEBUI=3001
```

### ARM64 / Raspberry Pi slow performance

```dotenv
LLAMA_THREADS=4        # Set to number of physical cores
LLAMA_CTX_SIZE=2048    # Reduce context
LLAMA_HF_FILE=qwen3-1.7b-q4_k_m.gguf  # Use lighter quantization
MEM_LIMIT=3g
```

### View all logs at once

```bash
docker compose logs -f
docker compose exec tinai supervisorctl status
docker stats tinai
```

---

## 🇫🇷 Français

### llama-server redémarre en boucle (exit 127)

**Cause :** `set -euo pipefail` dans le script de démarrage + PATH réduit dans supervisord.

**Solution :** Corrigé dans v3.1. Assure-toi d'utiliser le dernier `scripts/start-llama.sh`.

```bash
docker compose exec tinai supervisorctl status
docker compose exec tinai tail -20 /var/log/tinai/llama.err
```

### Le téléchargement du modèle échoue

```bash
# Option 1 : Pré-télécharger manuellement
mkdir -p models
wget -O models/qwen3-1.7b-q5_k_m.gguf \
  "https://huggingface.co/Qwen/Qwen3-1.7B-GGUF/resolve/main/qwen3-1.7b-q5_k_m.gguf"

# Lancer sans téléchargement
docker compose up -d
```

### Open WebUI ne charge pas (port 3000)

```bash
docker compose exec tinai tail -30 /var/log/tinai/webui.log
docker compose exec tinai supervisorctl restart webui
```

### Dashboard OpenFang inaccessible (port 4200)

```bash
docker compose exec tinai tail -30 /var/log/tinai/openfang.log
docker compose exec tinai supervisorctl restart openfang
docker compose exec tinai openfang --version
```

### Manque de mémoire (OOM)

```dotenv
LLAMA_CTX_SIZE=2048
MEM_LIMIT=4g
LLAMA_HF_FILE=qwen3-1.7b-q4_k_m.gguf
```

### Port déjà utilisé

```bash
lsof -i :3000
# Changer dans .env
PORT_WEBUI=3001
```

### Performances lentes sur ARM64 / Raspberry Pi

```dotenv
LLAMA_THREADS=4
LLAMA_CTX_SIZE=2048
LLAMA_HF_FILE=qwen3-1.7b-q4_k_m.gguf
MEM_LIMIT=3g
```
