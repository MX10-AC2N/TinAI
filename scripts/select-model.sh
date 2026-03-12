#!/bin/sh
# TinAI – Sélecteur de modèle interactif
set -eu

R='\033[0;31m'; G='\033[0;32m'; Y='\033[0;33m'
C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

die()  { printf "${R}✗ %s${N}\n" "$*" >&2; exit 1; }
ok()   { printf "${G}✓ %s${N}\n" "$*"; }
info() { printf "${C}→ %s${N}\n" "$*"; }
warn() { printf "${Y}⚠ %s${N}\n" "$*"; }

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODELS_DIR="${MODELS_DIR:-${SCRIPT_DIR}/models}"
ENV_FILE="${SCRIPT_DIR}/.env"

# Lire MODELS_DIR depuis .env si disponible
if [ -f "$ENV_FILE" ]; then
    _MD=$(grep "^MODELS_DIR=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"' | tr -d "'")
    [ -n "$_MD" ] && MODELS_DIR="$_MD"
fi
case "$MODELS_DIR" in /*) ;; *) MODELS_DIR="${SCRIPT_DIR}/${MODELS_DIR#./}" ;; esac

# ── Forcer stdin/stdout sur le terminal ──────────────────────────
exec < /dev/tty > /dev/tty 2>&1

# ── Vérifications ─────────────────────────────────────────────────
command -v curl   >/dev/null 2>&1 || die "curl requis"
command -v python3 >/dev/null 2>&1 || die "python3 requis"

printf "\n${W}"
printf "╔══════════════════════════════════════════════════╗\n"
printf "║         TinAI – Sélecteur de modèle             ║\n"
printf "║    CPU uniquement · données HuggingFace live    ║\n"
printf "╚══════════════════════════════════════════════════╝\n"
printf "${N}\n"

# RAM disponible
if [ -f /proc/meminfo ]; then
    TOTAL_KB=$(grep MemTotal     /proc/meminfo | awk '{print $2}')
    AVAIL_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    printf "${C}RAM : %s GB total, %s GB disponible${N}\n\n" \
        "$(python3 -c "print(f'{${TOTAL_KB}/1048576:.1f}')")" \
        "$(python3 -c "print(f'{${AVAIL_KB}/1048576:.1f}')")"
fi

# ── Catalogue ─────────────────────────────────────────────────────
# Format lignes : "Nom affiché|HF_REPO|RAM_min_GB"
cat > /tmp/tinai_catalog.txt << 'CATALOG'
Qwen3 1.7B (unsloth)|unsloth/Qwen3-1.7B-GGUF|2
Qwen3 4B (unsloth)|unsloth/Qwen3-4B-GGUF|3
Qwen3 8B (unsloth)|unsloth/Qwen3-8B-GGUF|6
Phi-4 Mini Instruct (bartowski)|bartowski/Phi-4-mini-instruct-GGUF|3
Phi-3 Mini 4K (bartowski)|bartowski/Phi-3-mini-4k-instruct-GGUF|3
Mistral 7B Instruct v0.3 (bartowski)|bartowski/Mistral-7B-Instruct-v0.3-GGUF|5
Gemma 2 2B Instruct (bartowski)|bartowski/gemma-2-2b-it-GGUF|2
Gemma 2 9B Instruct (bartowski)|bartowski/gemma-2-9b-it-GGUF|7
Llama 3.2 3B Instruct (bartowski)|bartowski/Llama-3.2-3B-Instruct-GGUF|3
Llama 3.1 8B Instruct (bartowski)|bartowski/Meta-Llama-3.1-8B-Instruct-GGUF|6
SmolLM2 1.7B Instruct (bartowski)|bartowski/SmolLM2-1.7B-Instruct-GGUF|2
[Entrer un repo manuellement]|CUSTOM|0
CATALOG

TOTAL=$(wc -l < /tmp/tinai_catalog.txt | tr -d ' ')

# ── Afficher le menu repos ────────────────────────────────────────
printf "${W}Modèles disponibles :${N}\n\n"
printf "  ${C}%-3s  %-42s  %s${N}\n" "N°" "Modèle" "RAM min"
printf "  %s\n" "────────────────────────────────────────────────────────"
i=1
while IFS='|' read -r NAME REPO RAM_MIN; do
    if [ "$REPO" = "CUSTOM" ]; then
        printf "  ${Y}%2d)${N}  %s\n" "$i" "$NAME"
    elif [ "$RAM_MIN" -gt 0 ] 2>/dev/null; then
        printf "  ${W}%2d)${N}  %-42s  ${C}≥ %d GB${N}\n" "$i" "$NAME" "$RAM_MIN"
    else
        printf "  ${W}%2d)${N}  %s\n" "$i" "$NAME"
    fi
    i=$((i+1))
done < /tmp/tinai_catalog.txt

printf "\n${W}Choix [1-%d] : ${N}" "$TOTAL"
read -r REPO_CHOICE

# Valider le choix
if ! echo "$REPO_CHOICE" | grep -qE '^[0-9]+$' || \
   [ "$REPO_CHOICE" -lt 1 ] || [ "$REPO_CHOICE" -gt "$TOTAL" ]; then
    die "Choix invalide : $REPO_CHOICE"
fi

# Récupérer repo et nom
HF_REPO=$(sed -n "${REPO_CHOICE}p" /tmp/tinai_catalog.txt | cut -d'|' -f2)
MODEL_NAME=$(sed -n "${REPO_CHOICE}p" /tmp/tinai_catalog.txt | cut -d'|' -f1)
rm -f /tmp/tinai_catalog.txt

if [ "$HF_REPO" = "CUSTOM" ]; then
    printf "\n${W}Repo HuggingFace (ex: TheBloke/Mistral-7B-GGUF) : ${N}"
    read -r HF_REPO
    [ -z "$HF_REPO" ] && die "Repo vide"
    MODEL_NAME="$HF_REPO"
fi

# ── Récupérer les fichiers GGUF via l'API HF ─────────────────────
printf "\n"
info "Connexion à HuggingFace..."

HTTP=$(curl -o /dev/null -sf -w "%{http_code}" --max-time 10 "https://huggingface.co" || echo "000")
[ "$HTTP" = "000" ] && die "HuggingFace inaccessible — vérifie ta connexion"
ok "Connecté"

info "Récupération des fichiers pour ${HF_REPO}..."
curl -sf --max-time 30 \
    "https://huggingface.co/api/models/${HF_REPO}" \
    -o /tmp/tinai_hf.json \
    || {
        printf "${R}✗ Repo introuvable : %s${N}\n" "$HF_REPO"
        printf "  Ce repo n'existe pas ou n'est pas encore publié.\n"
        printf "  Essaie le choix 'Entrer un repo manuellement'\n"
        printf "  ou consulte : https://huggingface.co/models?library=gguf\n\n"
        exit 1
    }

# Parser et filtrer CPU uniquement
python3 << 'PYEOF' > /tmp/tinai_gguf.txt
import json, sys, subprocess, re

with open('/tmp/tinai_hf.json') as f:
    data = json.load(f)

repo = data.get('id', '')
siblings = data.get('siblings', [])
exclude = ('f16','f32','bf16')

def is_cpu(fname):
    fl = fname.lower()
    if '-of-' in fl: return False
    for ex in exclude:
        if f'-{ex}' in fl or f'_{ex}' in fl or f'.{ex}.' in fl: return False
    return True

def order(fname):
    fl = fname.lower()
    for pat, o in [
        ('iq1',10),('iq2',20),('q2',25),('iq3',30),('q3',35),
        ('q4_k_s',40),('q4_k_m',41),('q4_k_l',42),('q4_0',43),('q4',45),
        ('q5_k_s',50),('q5_k_m',51),('q5_k_l',52),('q5',55),
        ('q6',60),('q8',80),
    ]:
        if pat in fl: return o
    return 99

def fmt(b):
    if not b: return '?'
    return f'{b/1_073_741_824:.1f} GB' if b > 1_073_741_824 else f'{b/1_048_576:.0f} MB'

def ram(b):
    if not b: return '?'
    r = b * 1.15
    return f'{r/1_073_741_824:.1f} GB' if r > 1_073_741_824 else f'{r/1_048_576:.0f} MB'

def get_size_from_header(repo, fname):
    url = f"https://huggingface.co/{repo}/resolve/main/{fname}"
    try:
        r = subprocess.run(
            ['curl', '-sI', '--max-time', '8', '-L', url],
            capture_output=True, text=True, timeout=10
        )
        for line in r.stdout.splitlines():
            if line.lower().startswith('content-length:'):
                return int(line.split(':',1)[1].strip())
    except Exception:
        pass
    return 0

files = [(s['rfilename'], s.get('size', 0))
         for s in siblings
         if s['rfilename'].endswith('.gguf') and is_cpu(s['rfilename'])]
files.sort(key=lambda x: order(x[0]))

for fname, size in files:
    # Si taille absente, récupérer via Content-Length header
    if not size:
        size = get_size_from_header(repo, fname)
    print(f"{fname}|{fmt(size)}|{ram(size)}")
PYEOF

rm -f /tmp/tinai_hf.json
FILE_TOTAL=$(wc -l < /tmp/tinai_gguf.txt | tr -d ' ')

if [ "$FILE_TOTAL" -eq 0 ]; then
    rm -f /tmp/tinai_gguf.txt
    die "Aucun fichier GGUF CPU-compatible trouvé dans ${HF_REPO}"
fi

ok "$(printf '%d fichiers trouvés' "$FILE_TOTAL")"

# ── Afficher le menu fichiers ─────────────────────────────────────
printf "\n${W}Fichiers disponibles pour ${C}%s${W} :${N}\n" "$MODEL_NAME"
printf "${Y}(F16/F32/BF16 et fichiers splittés exclus)${N}\n\n"
printf "  ${C}%-3s  %-50s  %8s  %10s${N}\n" "N°" "Fichier" "Taille" "RAM nécess."
printf "  %s\n" "────────────────────────────────────────────────────────────────────────────"

i=1
while IFS='|' read -r FNAME SIZE_FMT RAM_FMT; do
    case "$FNAME" in
        *Q4_K_M*|*q4_k_m*|*Q5_K_M*|*q5_k_m*) MARK="${G}" STAR=" ★" ;;
        *) MARK="${W}" STAR="" ;;
    esac
    printf "  ${MARK}%2d)${N}  %-50s  ${C}%8s${N}  ${Y}%10s${N}%s\n" \
        "$i" "$FNAME" "$SIZE_FMT" "$RAM_FMT" "$STAR"
    i=$((i+1))
done < /tmp/tinai_gguf.txt

printf "\n${W}Choix [1-%d] : ${N}" "$FILE_TOTAL"
read -r FILE_CHOICE

if ! echo "$FILE_CHOICE" | grep -qE '^[0-9]+$' || \
   [ "$FILE_CHOICE" -lt 1 ] || [ "$FILE_CHOICE" -gt "$FILE_TOTAL" ]; then
    rm -f /tmp/tinai_gguf.txt
    die "Choix invalide : $FILE_CHOICE"
fi

HF_FILE=$(sed -n "${FILE_CHOICE}p" /tmp/tinai_gguf.txt | cut -d'|' -f1)
SIZE_FMT=$(sed -n "${FILE_CHOICE}p" /tmp/tinai_gguf.txt | cut -d'|' -f2)
RAM_FMT=$(sed -n "${FILE_CHOICE}p" /tmp/tinai_gguf.txt | cut -d'|' -f3)
rm -f /tmp/tinai_gguf.txt

# ── Confirmation ──────────────────────────────────────────────────
printf "\n${W}══════════════════════════════════════════════════${N}\n"
printf "  Modèle  : %s\n"   "$MODEL_NAME"
printf "  Fichier : %s\n"   "$HF_FILE"
printf "  Taille  : %s\n"   "$SIZE_FMT"
printf "  RAM min : %s\n"   "$RAM_FMT"
printf "  Dest    : %s/\n"  "$MODELS_DIR"
printf "${W}══════════════════════════════════════════════════${N}\n"
printf "\nContinuer ? [O/n] : "
read -r CONFIRM
case "$CONFIRM" in [nN]) echo "Annulé."; exit 0 ;; esac

# ── Téléchargement ────────────────────────────────────────────────
mkdir -p "$MODELS_DIR"
DEST="${MODELS_DIR}/${HF_FILE}"
URL="https://huggingface.co/${HF_REPO}/resolve/main/${HF_FILE}"

if [ -f "$DEST" ]; then
    EXISTING=$(ls -lh "$DEST" | awk '{print $5}')
    warn "Déjà présent : $DEST ($EXISTING)"
    printf "Retélécharger ? [o/N] : "
    read -r REDOWNLOAD
    case "$REDOWNLOAD" in [oOyY]) ;; *) ok "Téléchargement ignoré"; exit 0 ;; esac
fi

info "Vérification de l'URL..."
HTTP=$(curl -o /dev/null -sf -w "%{http_code}" --max-time 10 --head "$URL" || echo "000")
[ "$HTTP" = "404" ] && die "Fichier introuvable sur HuggingFace (404)"
[ "$HTTP" = "000" ] && die "Impossible de joindre HuggingFace"

printf "\n"
curl -L --retry 3 --retry-delay 5 --progress-bar \
     -o "${DEST}.tmp" "$URL" \
    && mv "${DEST}.tmp" "$DEST" \
    || { rm -f "${DEST}.tmp"; die "Téléchargement échoué"; }

ok "Modèle téléchargé : $DEST"

# ── Mise à jour .env ──────────────────────────────────────────────
printf "\nMettre à jour .env avec ce modèle ? [O/n] : "
read -r UPDATE_ENV
case "$UPDATE_ENV" in [nN]) ;; *)
    [ ! -f "$ENV_FILE" ] && cp "${SCRIPT_DIR}/.env.example" "$ENV_FILE" 2>/dev/null || touch "$ENV_FILE"
    for VAR_LINE in "LLAMA_HF_REPO=${HF_REPO}" "LLAMA_HF_FILE=${HF_FILE}"; do
        VAR_NAME="${VAR_LINE%%=*}"
        if grep -q "^${VAR_NAME}=" "$ENV_FILE" 2>/dev/null; then
            sed -i.bak "s|^${VAR_NAME}=.*|${VAR_LINE}|" "$ENV_FILE" && rm -f "${ENV_FILE}.bak"
        else
            echo "$VAR_LINE" >> "$ENV_FILE"
        fi
    done
    ok ".env mis à jour (LLAMA_HF_REPO + LLAMA_HF_FILE)"
;; esac

# ── Redémarrer llama ──────────────────────────────────────────────
printf "\nRedémarrer le conteneur llama maintenant ? [O/n] : "
read -r RESTART
case "$RESTART" in [nN]) ;; *)
    if command -v docker >/dev/null 2>&1; then
        info "Redémarrage de tinai-llama..."
        docker compose -f "${SCRIPT_DIR}/docker-compose.yml" restart llama 2>/dev/null \
            && ok "tinai-llama redémarré" \
            || warn "Erreur — relance manuellement : docker compose restart llama"
    fi
;; esac

printf "\n${G}✓ Terminé !${N}\n\n"
