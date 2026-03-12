# TinAI

Stack IA locale tournant sur CPU — ZimaBoard 832 ou tout SBC x86/ARM.

```
llama-server  (ghcr.io/ggml-org/llama.cpp:server)  :8081
OpenFang      (ghcr.io/mx10-ac2n/tinai)             :4200
Open WebUI    (ghcr.io/open-webui/open-webui)       :3000  (optionnel)
```

## Déploiement

```bash
# Cloner le repo
git clone https://github.com/MX10-AC2N/TinAI.git
cd TinAI

# Déployer (sans Open WebUI)
make

# Déployer avec Open WebUI
make webui
```

À la fin du déploiement, si aucun modèle n'est présent, le sélecteur interactif
se lance automatiquement pour choisir et télécharger un modèle depuis HuggingFace.

## Commandes

| Commande      | Description                              |
|---------------|------------------------------------------|
| `make`        | Déployer sans Open WebUI                 |
| `make webui`  | Déployer avec Open WebUI                 |
| `make down`   | Arrêter tous les conteneurs              |
| `make logs`   | Suivre les logs en direct                |
| `make model`  | Changer de modèle (sélecteur interactif) |

## Changer de modèle

```bash
make model
```

Le sélecteur interroge l'API HuggingFace en temps réel, filtre les modèles
CPU-compatibles (exclut F16/F32/BF16), affiche les tailles et la RAM nécessaire,
puis télécharge et redémarre `llama-server` automatiquement.

## Configuration

Copier `.env.example` en `.env` et ajuster si besoin :

```bash
cp .env.example .env
```

Variables principales :

| Variable         | Défaut                        | Description                  |
|------------------|-------------------------------|------------------------------|
| `LLAMA_HF_REPO`  | `unsloth/Qwen3-1.7B-GGUF`    | Repo HuggingFace du modèle   |
| `LLAMA_HF_FILE`  | `Qwen3-1.7B-Q5_K_M.gguf`     | Fichier GGUF à charger       |
| `MODELS_DIR`     | `./models`                    | Dossier des modèles sur l'hôte |
| `PORT_LLAMA`     | `8081`                        | Port llama-server             |
| `PORT_OPENFANG`  | `4200`                        | Port OpenFang                 |
| `PORT_WEBUI`     | `3000`                        | Port Open WebUI               |

## Prérequis

- Docker + Docker Compose
- 4 GB RAM minimum (8 GB recommandé)
- `python3` (pour le sélecteur de modèle)
- `make`

## Architecture

```
┌─────────────────────────────────────────┐
│  tinai-net (bridge)                     │
│                                         │
│  tinai-llama  llama-server  :8080       │
│  tinai        OpenFang      :4200       │
│  tinai-webui  Open WebUI    :3000  (*)  │
└─────────────────────────────────────────┘
(*) profil optionnel : make webui
```

## Matériel testé

- ZimaBoard 832 (Intel N3450, 8 GB RAM, CasaOS)
