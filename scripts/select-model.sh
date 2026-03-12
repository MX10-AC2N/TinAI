#!/bin/sh
# ══════════════════════════════════════════════════════════════════
#  TinAI – Sélecteur de modèle interactif
#  - Interroge l'API HuggingFace
#  - Filtre : CPU uniquement (exclut F16/F32/BF16 et fichiers splittés)
#  - Affiche taille fichier + RAM estimée nécessaire
#  - Met à jour .env et redémarre llama
# ══════════════════════════════════════════════════════════════════
set -eu

# ── Couleurs ──────────────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'; Y='\033[0;33m'
B='\033[0;34m'; C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

die()  { printf "${R}✗ %s${N}\n" "$*" >&2; exit 1; }
info() { printf "${C}→ %s${N}\n" "$*"; }
ok()   { printf "${G}✓ %s${N}\n" "$*"; }
warn() { printf "${Y}⚠ %s${N}\n" "$*"; }

check_deps() {
    command -v curl >/dev/null 2>&1 || die "curl requis"
    if command -v python3 >/dev/null 2>&1; then
        PARSER="python3"
    elif command -v jq >/dev/null 2>&1; then
        PARSER="jq"
    else
        die "python3 ou jq requis pour parser l'API HuggingFace"
    fi

    # Test connectivité HuggingFace au démarrage
    printf "${C}→ Vérification de la connectivité...${N} "
    if curl -sf --max-time 8 "https://huggingface.co" -o /dev/null 2>&1; then
        printf "${G}OK${N}\n"
    else
        printf "${R}ÉCHEC${N}\n"
        die "HuggingFace inaccessible — vérifie la connexion internet de cette machine"
    fi
}

# ── Catalogue de repos GGUF connus ────────────────────────────────
# Format : "NomAffichage|HF_REPO|RAM_min_GB"
CATALOG="
Qwen3 1.7B|Qwen/Qwen3-1.7B-GGUF|2
Qwen3 4B|Qwen/Qwen3-4B-GGUF|3
Qwen3 8B|Qwen/Qwen3-8B-GGUF|6
Phi-4 Mini Instruct (Microsoft)|microsoft/Phi-4-mini-instruct-gguf|3
Phi-3 Mini 4K (Microsoft)|microsoft/Phi-3-mini-4k-instruct-gguf|3
Mistral 7B Instruct v0.3|bartowski/Mistral-7B-Instruct-v0.3-GGUF|5
Gemma 2 2B Instruct|bartowski/gemma-2-2b-it-GGUF|2
Gemma 2 9B Instruct|bartowski/gemma-2-9b-it-GGUF|7
Llama 3.2 3B Instruct|bartowski/Llama-3.2-3B-Instruct-GGUF|3
Llama 3.1 8B Instruct|bartowski/Meta-Llama-3.1-8B-Instruct-GGUF|6
SmolLM2 1.7B Instruct|bartowski/SmolLM2-1.7B-Instruct-GGUF|2
[Entrer un repo manuellement]|CUSTOM|0
"

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODELS_DIR="${MODELS_DIR:-${SCRIPT_DIR}/models}"
ENV_FILE="${SCRIPT_DIR}/.env"

# ══════════════════════════════════════════════════════════════════
banner() {
    printf "\n${W}"
    printf "╔══════════════════════════════════════════════════╗\n"
    printf "║         TinAI – Sélecteur de modèle             ║\n"
    printf "║    CPU uniquement · données HuggingFace live    ║\n"
    printf "╚══════════════════════════════════════════════════╝\n"
    printf "${N}\n"
}

# ── Vérifie si un fichier est CPU-friendly ────────────────────────
# Exclut : f16, f32, bf16 (trop gourmands), fichiers splittés (-00001-of-…)
is_cpu_friendly() {
    FNAME="$1"
    FNAME_LOWER=$(echo "$FNAME" | tr '[:upper:]' '[:lower:]')

    # Fichiers splittés (ex: model-00001-of-00004.gguf)
    case "$FNAME_LOWER" in *-of-*) return 1 ;; esac

    # Quantifications haute précision — trop lourdes pour CPU
    case "$FNAME_LOWER" in
        *-f16* | *_f16* | *.f16.* ) return 1 ;;
        *-f32* | *_f32* | *.f32.* ) return 1 ;;
        *-bf16* | *_bf16* | *.bf16.*) return 1 ;;
    esac

    return 0
}

# ── Ordre de tri des quantifications (du plus léger au plus lourd) ─
quant_order() {
    FNAME_LOWER=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$FNAME_LOWER" in
        *iq1*)   echo 10 ;;
        *iq2*)   echo 20 ;;
        *q2*)    echo 25 ;;
        *iq3*)   echo 30 ;;
        *q3*)    echo 35 ;;
        *q4_k_s*)echo 40 ;;
        *q4_k_m*)echo 41 ;;
        *q4_k_l*)echo 42 ;;
        *q4_0*)  echo 43 ;;
        *q4_1*)  echo 44 ;;
        *q4*)    echo 45 ;;
        *q5_k_s*)echo 50 ;;
        *q5_k_m*)echo 51 ;;
        *q5_k_l*)echo 52 ;;
        *q5_0*)  echo 53 ;;
        *q5*)    echo 55 ;;
        *q6*)    echo 60 ;;
        *q8*)    echo 80 ;;
        *)       echo 99 ;;
    esac
}

# ── Description et RAM overhead d'une quantification ──────────────
quant_desc() {
    FNAME_LOWER=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$FNAME_LOWER" in
        *iq1*)   echo "IQ1  · ultra-compact, perte qualité élevée" ;;
        *iq2*)   echo "IQ2  · très compact, qualité réduite" ;;
        *iq3*)   echo "IQ3  · compact, qualité correcte" ;;
        *q2*)    echo "Q2   · très compact, qualité réduite" ;;
        *q3*)    echo "Q3   · compact, qualité correcte" ;;
        *q4_k_s*)echo "Q4_K_S · léger, bon équilibre" ;;
        *q4_k_m*)echo "Q4_K_M · recommandé SBC ★" ;;
        *q4_k_l*)echo "Q4_K_L · Q4 amélioré" ;;
        *q4*)    echo "Q4   · compact" ;;
        *q5_k_s*)echo "Q5_K_S · équilibré compact" ;;
        *q5_k_m*)echo "Q5_K_M · défaut TinAI ★" ;;
        *q5_k_l*)echo "Q5_K_L · Q5 amélioré" ;;
        *q5*)    echo "Q5   · équilibré" ;;
        *q6*)    echo "Q6   · haute qualité" ;;
        *q8*)    echo "Q8   · quasi-original, lourd" ;;
        *)       echo "" ;;
    esac
}

# ── RAM nécessaire = taille fichier + ~15% overhead ───────────────
# Retourne une chaîne "X.X GB" depuis une taille en octets
ram_needed() {
    SIZE_BYTES="$1"
    python3 -c "
size = ${SIZE_BYTES}
ram  = size * 1.15          # overhead contexte + KV cache minimal
gb   = ram / 1_073_741_824
if gb < 1:
    print(f'{ram/1_048_576:.0f} MB RAM')
else:
    print(f'{gb:.1f} GB RAM')
" 2>/dev/null || echo "? RAM"
}

fmt_size() {
    SIZE_BYTES="$1"
    python3 -c "
s = ${SIZE_BYTES}
if s == 0:
    print('?')
elif s > 1_073_741_824:
    print(f'{s/1_073_741_824:.1f} GB')
else:
    print(f'{s/1_048_576:.0f} MB')
" 2>/dev/null || echo "?"
}

# ── Récupère et filtre les fichiers GGUF d'un repo ────────────────
list_gguf_files() {
    HF_REPO="$1"
    API_URL="https://huggingface.co/api/models/${HF_REPO}"

    # Spinner pendant l'appel API
    printf "${C}→ Interrogation de l'API HuggingFace...${N} "
    SPIN='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    i=0
    curl -sf --max-time 30 "$API_URL" -o /tmp/hf_response.json &
    CURL_PID=$!
    while kill -0 $CURL_PID 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r${C}→ Interrogation de l'API HuggingFace... %s${N}" "$(echo "$SPIN" | cut -c$((i+1)))"
        sleep 0.1
    done
    wait $CURL_PID
    CURL_EXIT=$?
    printf "\r${C}→ Interrogation de l'API HuggingFace... ${G}done${N}\n"

    if [ $CURL_EXIT -ne 0 ] || [ ! -s /tmp/hf_response.json ]; then
        printf "${R}✗ Impossible de joindre l'API HuggingFace${N}\n"
        printf "  URL testée : %s\n" "$API_URL"
        printf "  Test réseau : "
        if curl -sf --max-time 5 "https://huggingface.co" -o /dev/null; then
            printf "${G}HuggingFace accessible${N}\n"
            printf "  Le repo '%s' existe-t-il ?\n" "$HF_REPO"
        else
            printf "${R}HuggingFace inaccessible${N} — vérifie ta connexion\n"
        fi
        exit 1
    fi
    RESPONSE=$(cat /tmp/hf_response.json)
    rm -f /tmp/hf_response.json

    if [ "$PARSER" = "python3" ]; then
        # Retourne : "FNAME|SIZE_BYTES|SIZE_FMT|RAM_FMT|ORDER"
        echo "$RESPONSE" | python3 -c "
import sys, json

data = json.load(sys.stdin)
siblings = data.get('siblings', [])

cpu_exclude = ('f16','f32','bf16')

def is_cpu(fname):
    fl = fname.lower()
    if '-of-' in fl:
        return False
    for ex in cpu_exclude:
        if f'-{ex}' in fl or f'_{ex}' in fl or f'.{ex}.' in fl:
            return False
    return True

def order(fname):
    fl = fname.lower()
    for pat, o in [
        ('iq1',10),('iq2',20),('q2',25),('iq3',30),('q3',35),
        ('q4_k_s',40),('q4_k_m',41),('q4_k_l',42),('q4_0',43),('q4',45),
        ('q5_k_s',50),('q5_k_m',51),('q5_k_l',52),('q5_0',53),('q5',55),
        ('q6',60),('q8',80),
    ]:
        if pat in fl: return o
    return 99

def fmt_size(b):
    if not b: return '?'
    if b > 1_073_741_824: return f'{b/1_073_741_824:.1f} GB'
    return f'{b/1_048_576:.0f} MB'

def ram_needed(b):
    if not b: return '?'
    ram = b * 1.15
    if ram > 1_073_741_824: return f'{ram/1_073_741_824:.1f} GB'
    return f'{ram/1_048_576:.0f} MB'

files = [(s['rfilename'], s.get('size', 0)) for s in siblings
         if s['rfilename'].endswith('.gguf') and is_cpu(s['rfilename'])]
files.sort(key=lambda x: order(x[0]))

for fname, size in files:
    print(f'{fname}|{size}|{fmt_size(size)}|{ram_needed(size)}')
" 2>/dev/null
    else
        # Fallback jq — sans calcul RAM
        echo "$RESPONSE" | jq -r '
            .siblings[]
            | select(
                (.rfilename | endswith(".gguf")) and
                (.rfilename | ascii_downcase | test("-of-|-f16|-f32|-bf16") | not)
              )
            | .rfilename + "|" + (.size // 0 | tostring) + "|" +
              (if .size and .size > 1073741824
               then (.size/1073741824*10|round/10|tostring) + " GB"
               else "?" end) + "|?"
        ' 2>/dev/null
    fi
}

# ── Menu de sélection du repo ─────────────────────────────────────
select_repo() {
    # Construire le catalogue dans un fichier tmp (évite les subshells/pipes)
    CATALOG_FILE=$(mktemp /tmp/tinai_catalog.XXXXXX)
    echo "$CATALOG" | grep -v "^$" > "$CATALOG_FILE"
    TOTAL=$(wc -l < "$CATALOG_FILE" | tr -d ' ')

    printf "${W}Modèles disponibles :${N}\n\n"
    printf "  ${C}%-3s  %-40s  %s${N}\n" "N°" "Modèle" "RAM min (Q4_K_M)"
    printf "  %s\n" "──────────────────────────────────────────────────────────"

    i=1
    while IFS='|' read -r NAME REPO RAM_MIN; do
        if [ "$REPO" = "CUSTOM" ]; then
            printf "  ${Y}%2d)${N}  %s\n" "$i" "$NAME"
        else
            if [ "$RAM_MIN" -gt 0 ] 2>/dev/null; then
                printf "  ${W}%2d)${N}  %-40s  ${C}≥ %d GB${N}\n" "$i" "$NAME" "$RAM_MIN"
            else
                printf "  ${W}%2d)${N}  %s\n" "$i" "$NAME"
            fi
        fi
        i=$((i+1))
    done < "$CATALOG_FILE"

    printf "\n${W}Choix [1-%d] : ${N}" "$TOTAL"
    read -r CHOICE </dev/tty

    # Récupérer la ligne choisie
    RESULT=$(sed -n "${CHOICE}p" "$CATALOG_FILE")
    rm -f "$CATALOG_FILE"

    REPO=$(echo "$RESULT" | cut -d'|' -f2)
    NAME=$(echo "$RESULT" | cut -d'|' -f1)
    echo "$REPO|$NAME"
}

# ── Menu de sélection du fichier GGUF ────────────────────────────
select_file() {
    HF_REPO="$1"
    GGUF_LIST="$2"

    GGUF_FILE=$(mktemp /tmp/tinai_gguf.XXXXXX)
    echo "$GGUF_LIST" | grep -v "^$" > "$GGUF_FILE"
    COUNT=$(wc -l < "$GGUF_FILE" | tr -d ' ')

    if [ "$COUNT" -eq 0 ]; then
        rm -f "$GGUF_FILE"
        die "Aucun fichier .gguf CPU-compatible trouvé dans ${HF_REPO}"
    fi

    printf "\n${W}Fichiers CPU disponibles pour ${C}%s${W} :${N}\n" "$HF_REPO"
    printf "${Y}(F16/F32/BF16 et fichiers splittés exclus)${N}\n\n"
    printf "  ${C}%-3s  %-48s  %7s  %10s  %s${N}\n" \
        "N°" "Fichier" "Taille" "RAM nécess." "Description"
    printf "  %s\n" "─────────────────────────────────────────────────────────────────────────────────"

    i=1
    while IFS='|' read -r FNAME SIZE_B SIZE_FMT RAM_FMT; do
        DESC=$(quant_desc "$FNAME")
        case "$FNAME" in
            *Q4_K_M* | *q4_k_m*) MARK="${G}" ;;
            *Q5_K_M* | *q5_k_m*) MARK="${G}" ;;
            *)                    MARK="${W}" ;;
        esac
        printf "  ${MARK}%2d)${N}  %-48s  ${C}%7s${N}  ${Y}%10s${N}  %s\n" \
            "$i" "$FNAME" "$SIZE_FMT" "$RAM_FMT" "$DESC"
        i=$((i+1))
    done < "$GGUF_FILE"

    printf "\n${W}Choix [1-%d] : ${N}" "$COUNT"
    read -r FCHOICE </dev/tty

    RESULT=$(sed -n "${FCHOICE}p" "$GGUF_FILE")
    rm -f "$GGUF_FILE"
    echo "$RESULT"
}


# ── Téléchargement ────────────────────────────────────────────────
download_model() {
    HF_REPO="$1"
    HF_FILE="$2"
    FILE_SIZE="$3"    # en octets (pour affichage)
    FILE_SIZE_FMT="$4"
    DEST="${MODELS_DIR}/${HF_FILE}"

    mkdir -p "$MODELS_DIR"

    if [ -f "$DEST" ]; then
        EXISTING=$(ls -lh "$DEST" | awk '{print $5}')
        printf "\n${Y}Fichier déjà présent : %s (%s)${N}\n" "$DEST" "$EXISTING"
        printf "Retélécharger ? [o/N] : "
        read -r REDOWNLOAD </dev/tty
        case "$REDOWNLOAD" in [oOyY]) ;; *) ok "Téléchargement ignoré"; return 0 ;; esac
    fi

    URL="https://huggingface.co/${HF_REPO}/resolve/main/${HF_FILE}"
    TMP="${DEST}.tmp"

    printf "\n${W}Téléchargement :${N}\n"
    printf "  Fichier : %s\n" "$HF_FILE"
    printf "  Taille  : %s\n" "$FILE_SIZE_FMT"
    printf "  URL     : %s\n\n" "$URL"

    # Vérifier l'URL avant de lancer
    HTTP=$(curl -o /dev/null -sf -w "%{http_code}" --max-time 10 --head "$URL" || echo "000")
    [ "$HTTP" = "404" ] && die "Fichier introuvable sur HuggingFace (404)"
    [ "$HTTP" = "000" ] && die "Impossible de joindre HuggingFace"

    curl -L --retry 3 --retry-delay 5 --progress-bar \
         -o "$TMP" "$URL" \
        && mv "$TMP" "$DEST" \
        || { rm -f "$TMP"; die "Téléchargement échoué"; }

    FINAL_SIZE=$(ls -lh "$DEST" | awk '{print $5}')
    ok "Modèle téléchargé : $DEST ($FINAL_SIZE)"
}

# ── Mise à jour .env ──────────────────────────────────────────────
update_env() {
    HF_REPO="$1"
    HF_FILE="$2"

    if [ ! -f "$ENV_FILE" ]; then
        warn ".env absent — copie depuis .env.example"
        cp "${SCRIPT_DIR}/.env.example" "$ENV_FILE" 2>/dev/null \
            || { warn "Pas de .env.example — création minimale"; touch "$ENV_FILE"; }
    fi

    for VAR_LINE in "LLAMA_HF_REPO=${HF_REPO}" "LLAMA_HF_FILE=${HF_FILE}"; do
        VAR_NAME="${VAR_LINE%%=*}"
        if grep -q "^${VAR_NAME}=" "$ENV_FILE" 2>/dev/null; then
            sed -i.bak "s|^${VAR_NAME}=.*|${VAR_LINE}|" "$ENV_FILE" && rm -f "${ENV_FILE}.bak"
        else
            echo "$VAR_LINE" >> "$ENV_FILE"
        fi
    done

    ok ".env mis à jour"
    printf "  LLAMA_HF_REPO=%s\n" "$HF_REPO"
    printf "  LLAMA_HF_FILE=%s\n" "$HF_FILE"
}

# ── Point d'entrée ────────────────────────────────────────────────
main() {
    check_deps
    banner

    # Afficher la RAM disponible sur la machine
    if [ -f /proc/meminfo ]; then
        TOTAL_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        AVAIL_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        TOTAL_GB=$(python3 -c "print(f'{${TOTAL_KB}/1048576:.1f}')" 2>/dev/null || echo "?")
        AVAIL_GB=$(python3 -c "print(f'{${AVAIL_KB}/1048576:.1f}')" 2>/dev/null || echo "?")
        printf "${C}RAM de cette machine : %s GB total, %s GB disponible${N}\n\n" \
            "$TOTAL_GB" "$AVAIL_GB"
    fi

    # 1. Sélection du repo
    REPO_CHOICE=$(select_repo)
    HF_REPO=$(echo "$REPO_CHOICE" | cut -d'|' -f1)
    SELECTED_NAME=$(echo "$REPO_CHOICE" | cut -d'|' -f2)

    [ -z "$HF_REPO" ] && die "Choix invalide"

    if [ "$HF_REPO" = "CUSTOM" ]; then
        printf "\n${W}Repo HuggingFace (ex: TheBloke/Mistral-7B-GGUF) : ${N}"
        read -r HF_REPO
        [ -z "$HF_REPO" ] && die "Repo vide"
        SELECTED_NAME="$HF_REPO"
    fi

    # 2. Lister les fichiers GGUF filtrés
    GGUF_LIST=$(list_gguf_files "$HF_REPO")

    # 3. Sélection du fichier
    FILE_CHOICE=$(select_file "$HF_REPO" "$GGUF_LIST")

    HF_FILE=$(echo "$FILE_CHOICE"     | cut -d'|' -f1)
    FILE_SIZE=$(echo "$FILE_CHOICE"   | cut -d'|' -f2)
    FILE_SIZE_FMT=$(echo "$FILE_CHOICE" | cut -d'|' -f3)
    RAM_FMT=$(echo "$FILE_CHOICE"     | cut -d'|' -f4)

    [ -z "$HF_FILE" ] && die "Choix invalide"

    # 4. Récapitulatif + confirmation
    printf "\n${W}══════════════════════════════════════════════${N}\n"
    printf "  Modèle  : %s\n"  "$SELECTED_NAME"
    printf "  Repo    : %s\n"  "$HF_REPO"
    printf "  Fichier : %s\n"  "$HF_FILE"
    printf "  Taille  : %s\n"  "$FILE_SIZE_FMT"
    printf "  RAM min : %s\n"  "$RAM_FMT"
    printf "  Dest    : %s/%s\n" "$MODELS_DIR" "$HF_FILE"
    printf "${W}══════════════════════════════════════════════${N}\n"
    printf "\nContinuer ? [O/n] : "
    read -r CONFIRM </dev/tty
    case "$CONFIRM" in [nN]) echo "Annulé."; exit 0 ;; esac

    # 5. Téléchargement
    download_model "$HF_REPO" "$HF_FILE" "$FILE_SIZE" "$FILE_SIZE_FMT"

    # 6. Mise à jour .env
    printf "\nMettre à jour .env avec ce modèle ? [O/n] : "
    read -r UPDATE_ENV_Q </dev/tty
    case "$UPDATE_ENV_Q" in [nN]) ;; *) update_env "$HF_REPO" "$HF_FILE" ;; esac

    # 7. Redémarrer le conteneur llama
    printf "\nRedémarrer le conteneur llama maintenant ? [O/n] : "
    read -r RESTART </dev/tty
    case "$RESTART" in
        [nN]) ;;
        *)
            if command -v docker >/dev/null 2>&1; then
                info "Redémarrage de tinai-llama..."
                docker compose -f "${SCRIPT_DIR}/docker-compose.yml" restart llama 2>/dev/null \
                    && ok "tinai-llama redémarré" \
                    || warn "Erreur — redémarre manuellement : docker compose restart llama"
            else
                warn "docker non disponible — redémarre manuellement : docker compose restart llama"
            fi
            ;;
    esac

    printf "\n${G}✓ Terminé !${N}\n\n"
}

main "$@"
