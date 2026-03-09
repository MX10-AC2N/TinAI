# Contributing to TinAI · Guide de contribution

[🇬🇧 English](#-english) · [🇫🇷 Français](#-français)

---

## 🇬🇧 English

### How to contribute

1. **Fork** the repository
2. **Create a branch** for your feature: `git checkout -b feat/my-feature`
3. **Commit** your changes: `git commit -m "feat: add my feature"`
4. **Push** to your branch: `git push origin feat/my-feature`
5. **Open a Pull Request** on `main`

### Commit convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat:     New feature
fix:      Bug fix
docs:     Documentation only
ci:       CI/CD changes
refactor: Code refactoring without feature change
chore:    Maintenance (deps update, etc.)
```

### Local development

```bash
git clone https://github.com/MX10-AC2N/TinAI.git && cd TinAI
cp .env.example .env
docker compose up --build
```

### Testing your changes

Before submitting a PR, verify:

```bash
# ShellCheck (requires shellcheck installed)
shellcheck scripts/*.sh

# Validate docker-compose syntax
docker compose config > /dev/null && echo "OK"

# Build the image locally
docker compose build --no-cache

# Start and check services
docker compose up -d
docker compose exec tinai supervisorctl status
docker compose logs --tail=30
```

### Areas open for contribution

- 📝 Documentation improvements (translations, examples)
- 🐛 Bug fixes (open an issue first)
- 🚀 New model presets in `.env.example`
- 🔒 Security hardening
- 🧪 Additional CI tests
- 🌍 New language support in scripts

### Code style

- Shell scripts: POSIX compatible, no `set -euo pipefail` at top level (supervisor compatibility)
- Always add `export PATH=...` at the start of scripts run by supervisord
- Comments in both French and English when possible

### Opening an issue

Please include:
- Your OS and Docker version (`docker --version`)
- Your CPU architecture (`uname -m`)
- Relevant logs (`docker compose logs --tail=50`)
- Your `.env` (without secret values)

---

## 🇫🇷 Français

### Comment contribuer

1. **Forke** le dépôt
2. **Crée une branche** : `git checkout -b feat/ma-fonctionnalite`
3. **Committe** tes changements : `git commit -m "feat: ajoute ma fonctionnalité"`
4. **Push** : `git push origin feat/ma-fonctionnalite`
5. **Ouvre une Pull Request** sur `main`

### Convention de commit

Nous utilisons [Conventional Commits](https://www.conventionalcommits.org/fr/) :

```
feat:     Nouvelle fonctionnalité
fix:      Correction de bug
docs:     Documentation uniquement
ci:       Changements CI/CD
refactor: Refactoring sans changement de fonctionnalité
chore:    Maintenance (mises à jour de dépendances, etc.)
```

### Développement local

```bash
git clone https://github.com/MX10-AC2N/TinAI.git && cd TinAI
cp .env.example .env
docker compose up --build
```

### Tester tes changements

Avant de soumettre une PR, vérifie :

```bash
# ShellCheck
shellcheck scripts/*.sh

# Valider la syntaxe docker-compose
docker compose config > /dev/null && echo "OK"

# Build local
docker compose build --no-cache

# Démarrer et vérifier les services
docker compose up -d
docker compose exec tinai supervisorctl status
docker compose logs --tail=30
```

### Domaines ouverts à contribution

- 📝 Améliorations de la documentation
- 🐛 Corrections de bugs (ouvre d'abord une issue)
- 🚀 Nouveaux presets de modèles dans `.env.example`
- 🔒 Durcissement de la sécurité
- 🧪 Tests CI supplémentaires

### Ouvrir une issue

Inclure :
- Ton OS et version Docker (`docker --version`)
- Ton architecture CPU (`uname -m`)
- Les logs pertinents (`docker compose logs --tail=50`)
- Ton `.env` (sans les valeurs secrètes)
