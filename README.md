# 24 heures pour coder 2026 — Galerie TIC-80

Bienvenue sur le dépôt des projets du hackathon **24 heures pour coder** (édition 2026), organisé par le BDE.

Tous les jeux livrés ici sont des cartouches **[TIC-80](https://tic80.com/)**. Une galerie web statique (auto-générée à partir des dossiers de ce repo) les liste et les fait jouer directement dans le navigateur.

## J'ai fait un jeu, comment l'ajouter à la galerie ?

Trois étapes, **sans toucher à aucun fichier de code côté web** :

### 1. Dépose ton dossier à la racine du repo

Crée un dossier avec le nom de ton choix (espaces, majuscules, ponctuation tolérés). Peu importe son organisation interne — tu décris au pipeline comment construire ta cartouche à l'étape 3.

### 2. Ajoute `cover.png`

Image PNG à la racine de ton dossier. Idéalement 240×136 (résolution native TIC-80) ou un multiple. Affichée avec `image-rendering: pixelated`.

### 3. Ajoute `game.json`

Fichier à la racine de ton dossier. Template minimal :

```json
{
  "id": "mon-super-jeu",
  "title": "Mon Super Jeu",
  "team": "Nom d'équipe",
  "authors": ["Prénom Nom"],
  "description": "Pitch en une ou deux phrases.",
  "genre": "Arcade",
  "language": "Fennel",
  "controls": [
    { "key": "←/→", "action": "Se déplacer" },
    { "key": "X", "action": "Sauter" }
  ],
  "sourceDir": "Mon Super Jeu",
  "coverPath": "cover.png",
  "build": ["load assets/game.tic"]
}
```

- **`id`** : slug kebab-case unique (`[a-z0-9-]`). Sert d'URL.
- **`sourceDir`** : nom **exact** de ton dossier.
- **`language`** : `"Fennel" | "Lua" | "JS" | "Moon" | "Wren" | "Squirrel"`.
- **`build`** : voir ci-dessous.

#### Le champ `build` — adapter à ton organisation

Liste de commandes TIC-80 (celles de la console) qui amènent l'éditeur à un état jouable. Le pipeline ajoute `export html` et `exit` à la fin. **N'écris ni `run`, ni `exit`, ni `export html`.**

**a) Cartouche `.tic` complète** (cas le plus simple)

```json
"build": ["load assets/game.tic"]
```

**b) Sprites en cartouche + code séparé**

```json
"build": ["load assets/sprites.tic", "import code src/main.fnl"]
```

**c) Code seul**

```json
"build": ["new fennel", "import code src/main.fnl"]
```

**d) Assets multiples**

```json
"build": [
  "new lua",
  "import tiles assets/tiles.gif",
  "import sprites assets/sprites.gif",
  "import map assets/map.txt",
  "import code src/main.lua"
]
```

Référence des commandes TIC-80 : <https://github.com/nesbox/TIC-80/wiki/Console>.

### 4. Push

La CI :
- détecte ton `game.json`,
- exécute ta séquence `build` dans TIC-80 headless,
- génère l'export HTML,
- régénère la galerie.

Si ton jeu n'apparaît pas, regarde les logs CI : champ manquant, fichier introuvable, commande TIC-80 en échec — chaque erreur est loggée explicitement.

## Tester en local

```bash
cd web
npm install
npm run build:tic   # exécute TIC-80 sur chaque jeu
npm run dev         # http://localhost:5173
```

Sur macOS, le script cherche TIC-80 dans `/Applications/tic80.app`. Sur Linux, `tic80` doit être dans le `PATH` (la CI le télécharge automatiquement). Sinon, définir `TIC80_BIN=/chemin/vers/tic80`.

## Documentation interne

- [SPECS.md](SPECS.md) — spécifications complètes.
- [STATE.md](STATE.md) — état d'avancement.
- [CLAUDE.md](CLAUDE.md) — guide pour les agents IA qui reprennent le projet.

## Crédits

Hackathon **24h pour coder 2026** — organisé par le BDE.
