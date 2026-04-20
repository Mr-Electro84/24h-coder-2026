# SPECS.md — Galerie web TIC-80 "24h pour coder 2026"

## Objectif

Construire une app web statique qui liste les jeux TIC-80 du repo en galerie et les lance directement dans le navigateur via des exports HTML TIC-80 générés en CI.

## Contrainte architecturale non négociable

**Auto-découverte.** Le nombre de jeux, leurs noms, leurs dossiers sont **dynamiques** — décidés par les participants du hackathon. Règle unique :

> Tout dossier à la racine du repo contenant un `game.json` valide est un jeu. Tout le reste est dérivé.

Toute solution qui impose d'ajouter le nom d'un jeu dans le code, la config, ou la CI est à rejeter. La CI doit rebuilder exactement pareil avec 3 jeux ou 50 jeux.

## Stack technique

- **Build** : Vite
- **Framework** : React 18 + TypeScript
- **Routing** : `react-router-dom` v6
- **Markdown** : `react-markdown` (pour les descriptions longues)
- **Scripts** : `tsx` pour exécuter les scripts TS
- **CI** : GitHub Actions (ubuntu-latest)
- **Player jeux** : binaire TIC-80 v1.1.2837 (pinné), export HTML via `--cli`

## Arborescence cible

```
24h-coder-2026/
├── CLAUDE.md
├── SPECS.md
├── STATE.md
├── README.md                   (doit pointer vers §Guide participant)
├── <dossier-jeu>/              ← N dossiers à la racine, découverts dynamiquement
│   ├── game.json               ← obligatoire : déclare le jeu
│   ├── cover.png               ← obligatoire : vignette galerie
│   ├── <cartouche .tic>        ← obligatoire : chemin indiqué par ticPath dans game.json
│   └── ...                     ← sources libres (src/, assets/, docs/, README.md, etc.)
├── .github/workflows/build.yml (NEW)
└── web/
    ├── package.json
    ├── vite.config.ts           (base path configurable via env)
    ├── tsconfig.json
    ├── index.html
    ├── scripts/
    │   ├── discover-games.ts
    │   └── build-tic-exports.ts
    ├── src/
    │   ├── main.tsx
    │   ├── App.tsx
    │   ├── types/game.ts
    │   ├── data/games.generated.ts     (généré, gitignored)
    │   ├── components/
    │   │   ├── GameCard.tsx
    │   │   ├── GameGrid.tsx
    │   │   ├── PlayerFrame.tsx
    │   │   └── Layout.tsx
    │   ├── pages/
    │   │   ├── GalleryPage.tsx
    │   │   └── GamePage.tsx
    │   └── styles/global.css
    └── public/
        ├── covers/<slug>.png           (généré)
        └── games/<slug>/
            ├── index.html              (généré)
            ├── tic80.js                (généré)
            ├── tic80.wasm              (généré)
            └── cart.tic                (généré)
```

## Schéma `game.json`

Les jeux ne sont **pas structurés de la même façon** : certains fournissent une cartouche `.tic` déjà jouable, d'autres n'ont que du code Fennel + sprites à assembler, d'autres encore un simple fichier `.lua`. Le schéma reflète cette diversité via un champ `build` qui décrit **comment obtenir une cartouche exécutable** à partir des fichiers du dossier.

```ts
// web/src/types/game.ts
export type GameMeta = {
  id: string;                 // slug kebab-case, ex "dodge"
  title: string;              // ex "Dodge!"
  team: string;               // ex "QBitSoft"
  authors: string[];          // noms individuels
  description: string;        // 1-2 phrases (pitch)
  longDescription?: string;   // markdown optionnel pour la page jeu
  genre: string;              // "Platformer" | "Roguelike" | "Arcade" | ...
  language: "Fennel" | "Lua" | "JS" | "Moon" | "Wren" | "Squirrel";
  controls: { key: string; action: string }[];

  sourceDir: string;          // nom exact du dossier, ex "Dodge! (QBitSoft)"
  coverPath: string;          // relatif à sourceDir, par défaut "cover.png"

  build: string[];            // ← séquence de commandes TIC-80 exécutées avant l'export HTML
                              //   les chemins sont relatifs à sourceDir
};
```

Le `sourceDir` relie la métadonnée au dossier physique même lorsque le nom contient espaces/`!`. Le `id` (slug) est la seule chose utilisée dans les URLs et chemins de build.

### Le champ `build`

C'est une liste de commandes TIC-80 (syntaxe de la console TIC-80) exécutées dans l'ordre avant l'export HTML. L'état final de la mémoire TIC-80 juste après la dernière commande doit être **un jeu jouable** — le script de build enchaîne alors `export html` puis `exit`.

Exemples typiques :

```json
// Cas 1 — cartouche déjà prête (Zigoto-Quest, Dodge!)
"build": ["load assets/game.tic"]
```

```json
// Cas 2 — sprites + code séparés à assembler (echo-clone-souls)
"build": [
  "load assets/sprites.tic",
  "import code src/main.fnl"
]
```

```json
// Cas 3 — code seul, pas de cartouche de base
"build": [
  "new fennel",
  "import code src/main.fnl"
]
```

```json
// Cas 4 — assemblage multi-assets
"build": [
  "new lua",
  "import tiles assets/tiles.gif",
  "import sprites assets/sprites.gif",
  "import map assets/map.txt",
  "import code src/main.lua"
]
```

Règles :

- Tableau non vide de strings.
- Les chemins sont relatifs à `sourceDir`.
- Ne pas inclure `export html ...` ni `exit` — le script les ajoute.
- Ne pas inclure `run` — l'export se fait en statique, pas besoin d'exécuter le jeu.
- Si une commande échoue, la CI logue la sortie TIC-80 et skippe ce jeu (mais continue les autres).

## Script de build des exports TIC-80

`web/scripts/build-tic-exports.ts` (exécuté via `tsx`) :

1. **Auto-découverte** : glob tous les `*/game.json` depuis la racine du repo (exclure `web/`, `node_modules/`, `.git/`, `.github/`, `.claude/`). Ne jamais maintenir une liste codée en dur.
2. **Validation** de chaque `game.json` :
   - Champs obligatoires présents (voir schéma).
   - `id` unique parmi tous les jeux (rejeter sinon avec un message clair).
   - `build` est un tableau non vide de strings, ne contient pas `export html` ni `exit` ni `run` (le script les ajoute).
   - `<sourceDir>/<coverPath>` existe.
   - **Pas de vérification d'existence d'une cartouche** : le `build` peut partir de rien (`new fennel`) ou référencer des fichiers que seul TIC-80 comprendra. La validation "ça marche" se fait à l'exécution de TIC-80.
   - Un jeu invalide **log un warning + est skippé**, il ne fait pas planter le build des autres jeux (sauf en CI stricte — voir §CI).
3. Pour chaque jeu valide :
   - `mkdir web/.tmp/<slug>/`.
   - **Copier tout le `sourceDir`** dans `web/.tmp/<slug>/` (pas seulement la cartouche — on ne sait pas à l'avance quels fichiers la séquence `build` va lire). Ignorer `node_modules/`, `.git/` si jamais présents.
   - Construire la commande TIC-80 :

     ```
     <build[0]> & <build[1]> & ... & <build[n]> & export html out.zip & exit
     ```

   - Lancer `tic80 --cli --fs web/.tmp/<slug> --cmd "<commande>"` (préfixé `xvfb-run -a` sur Linux CI).
   - Vérifier que `out.zip` existe et contient un `index.html`. Sinon, log l'erreur + skip ce jeu.
   - Unzip `out.zip` vers `web/public/games/<slug>/`.
   - Copier `<sourceDir>/<coverPath>` vers `web/public/covers/<slug>.png`.
4. Écrire `web/src/data/games.generated.ts` :

   ```ts
   import type { GameMeta } from "../types/game";
   export const GAMES: GameMeta[] = [ /* ... issus du glob, triés par title ... */ ];
   ```

Si TIC-80 n'est pas trouvé en local (dev mac) : message d'aide + exit 1. Sur macOS, chercher `/Applications/tic80.app/Contents/MacOS/tic80`.

### Pourquoi ne pas imposer une cartouche prête ?

Imposer `ticPath` obligerait chaque participant à maintenir une cartouche binaire à jour à chaque modification de code/sprites — source d'erreurs (cartouche oubliée, désynchro avec le source). Avec `build` qui décrit la recette, **la source de vérité reste le dossier du participant** dans l'état où il l'a organisé. La cartouche finale est un artefact reproductible.

## Cas concrets des jeux présents

Le champ `build` doit être renseigné cas par cas selon la forme du projet :

- **`Zigoto-Quest/`** : cartouche prête dans `assets/game.tic` → `build: ["load assets/game.tic"]`.
- **`Dodge! (QBitSoft)/`** : cartouche prête dans `assets/game.tic` → `build: ["load assets/game.tic"]`.
- **`echo-clone-souls/`** : pas de cartouche consolidée ; seulement `assets/sprites.tic` (sprites uniquement) + `src/main.fnl` (code). Le README du jeu donne la marche à suivre : `load assets/sprites & import code src/main.fnl & run`. Traduction en `build` :

  ```json
  "build": [
    "load assets/sprites.tic",
    "import code src/main.fnl"
  ]
  ```

  Plus besoin de consolider manuellement en `game.tic` — le pipeline le fait à chaque build.

Pour tout nouveau jeu ajouté par un participant, voir le §Guide participant.

## App React

### Routing

- `/` → `GalleryPage`
- `/games/:id` → `GamePage`
- `*` → 404

### Composants

- **`GameCard`** : cover en `image-rendering: pixelated`, titre, genre, équipe, `Link` vers `/games/:id`.
- **`GameGrid`** : CSS grid responsive `repeat(auto-fill, minmax(240px, 1fr))`.
- **`PlayerFrame`** : `<iframe src="{base}/games/{slug}/index.html">`, taille native scalée (720×408 desktop, fluide sur mobile), overlay "Cliquez pour jouer" (focus + fullscreen possible), bouton `Fullscreen`.
- **`GamePage`** : titre, équipe, `PlayerFrame`, tableau des contrôles, `longDescription` rendu markdown via `react-markdown`, lien vers le dossier source sur GitHub.
- **`Layout`** : header (titre du site, lien repo) + footer + `<Outlet />`.

### Style

- CSS modules + custom properties globales.
- Thème pixel : police `"Press Start 2P"` (Google Fonts) pour les titres, `"Inter"` pour le corps.
- Palette sombre : fond `#0f0f1a`, texte `#f2f2f2`, accent `#e94560`.
- **Pas de Tailwind** — trop lourd pour un site de 2 pages.

### Base path

`vite.config.ts` lit `process.env.BASE_URL` (défaut `/`). En GH Pages on passera `/24h-coder-2026/`.

## GitHub Actions

`.github/workflows/build.yml` :

```yaml
name: Build and Deploy
on:
  push: { branches: ["main", "web/**"] }
  pull_request:
  workflow_dispatch:
concurrency:
  group: "pages"
  cancel-in-progress: false
permissions: { contents: read, pages: write, id-token: write }
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"
          cache-dependency-path: web/package-lock.json
      - name: Install TIC-80
        run: |
          sudo apt-get update
          sudo apt-get install -y xvfb unzip
          curl -L -o tic80.zip https://github.com/nesbox/TIC-80/releases/download/v1.1.2837/tic80-v1.1.2837-linux.zip
          unzip tic80.zip -d "$HOME/tic80"
          chmod +x "$HOME/tic80/tic80"
          echo "$HOME/tic80" >> "$GITHUB_PATH"
      - name: Install web deps
        working-directory: web
        run: npm ci
      - name: Build TIC-80 exports
        working-directory: web
        run: xvfb-run -a npm run build:tic
      - name: Build site
        working-directory: web
        env: { BASE_URL: "/24h-coder-2026/" }
        run: npx tsc -b && npx vite build
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with: { path: web/dist }

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

Le job `deploy` est **conditionné à `main`** : les PRs et branches `web/**` valident le build sans publier. Le déploiement cible **https://bde-ceri.github.io/24h-coder-2026/**.

### Activation GitHub Pages (one-shot, à faire une seule fois)

Dans **Settings → Pages** du repo GitHub :
- **Source** : sélectionner **"GitHub Actions"** (pas "Deploy from a branch").

Sans cette configuration, le job `deploy` échoue. Cette action est manuelle et ne peut pas être scriptée.

## Points de vigilance

- **Hétérogénéité des projets** : certains jeux arrivent avec une cartouche `.tic`, d'autres avec uniquement du code Fennel/Lua, d'autres avec des assets séparés. Le champ `build` absorbe toutes ces variantes — jamais faire d'hypothèse type "il y aura un `.tic` dans `assets/`".
- **`build` exécuté dans un tmp** : le script copie `sourceDir/*` vers `web/.tmp/<slug>/` avant de lancer TIC-80. Conséquence : le `build` peut référencer n'importe quel fichier du dossier du jeu sans risquer de polluer les sources.
- **Commandes TIC-80 bloquantes** : éviter `run` dans `build` (lance l'exécution, pas besoin pour l'export). Éviter aussi tout ce qui ouvre un dialogue interactif.
- **TIC-80 headless** : `--cli` seul ne suffit pas sur Linux, toujours `xvfb-run`. Pinner la version TIC-80 (v1.1.2837).
- **Slug ≠ nom de dossier** : `Dodge! (QBitSoft)` → slug `dodge`. Le script doit URL-encoder les chemins quand il lit des fichiers dans un dossier avec espaces/`!`, et n'utiliser que le slug pour les sorties.
- **Taille** : `tic80.wasm` ~1 Mo, dupliqué par jeu. OK à 3 jeux (~3 Mo total). Au-delà de 20 jeux, factoriser dans `public/games/_shared/` et patcher les `index.html` générés.
- **Iframe focus** : l'iframe capte le clavier uniquement avec focus. Overlay "Cliquez pour jouer" obligatoire sinon le joueur tape dans le vide. Gérer `Escape` pour rendre le focus à la page parent.
- **Arrow keys scroll** : la page parent ne doit pas scroller avec les flèches quand l'iframe a le focus. Soit le player a son propre scroll, soit `preventDefault` côté parent quand focus iframe.
- **Mobile** : TIC-80 web n'a pas de contrôles tactiles. Afficher un bandeau "Clavier requis — jouer sur desktop". Téléchargement du `.tic` non prioritaire MVP.
- **Cross-origin** : tout servi depuis le même domaine → RAS.
- **Échelle** : TIC-80 natif 240×136. Scaler à ×3 desktop (720×408), fluide max-width sur mobile.

## Guide participant — "J'ai fait un jeu, comment l'ajouter à la galerie ?"

> À reproduire dans le `README.md` racine une fois la galerie en place. Doit rester court et autosuffisant.

### 1. Déposer le dossier

Créer un dossier à la racine du repo avec le nom de votre choix (espaces/majuscules/ponctuation tolérés). Peu importe son organisation interne — vous allez décrire au pipeline comment construire votre cartouche à l'étape 3.

### 2. Ajouter `cover.png`

Image au format PNG à la racine du dossier jeu (chemin configurable via `coverPath` si besoin). Idéalement 240×136 (résolution native TIC-80) ou un multiple. Affichée avec `image-rendering: pixelated`.

### 3. Ajouter `game.json`

Fichier à la racine de votre dossier jeu. Template minimal :

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

Règles :

- **`id`** : slug kebab-case, uniquement `[a-z0-9-]`. Il sert d'URL (`/games/<id>`) et de nom de dossier de build. Doit être unique.
- **`sourceDir`** : nom **exact** de votre dossier (respecter majuscules, espaces, ponctuation).
- **`coverPath`** : chemin relatif depuis `sourceDir`.
- **`language`** : une valeur parmi `"Fennel" | "Lua" | "JS" | "Moon" | "Wren" | "Squirrel"`.
- **`build`** : voir ci-dessous.
- Le schéma complet est dans [web/src/types/game.ts](web/src/types/game.ts) (champ `longDescription` optionnel en markdown pour la page jeu).

### Le champ `build` — adapter à votre organisation

`build` est une **liste de commandes TIC-80** (celles que vous tapez dans la console TIC-80) qui amènent l'éditeur à un état jouable. Le pipeline ajoutera automatiquement `export html` et `exit` à la fin. **N'écrivez ni `run`, ni `exit`, ni `export html`.**

Choisissez le cas qui correspond à votre projet :

**a) Vous avez une cartouche `.tic` complète et jouable** (le cas le plus simple)

```json
"build": ["load assets/game.tic"]
```

**b) Vos sprites/sfx sont dans une cartouche, votre code dans un fichier séparé** (cas `echo-clone-souls`)

```json
"build": [
  "load assets/sprites.tic",
  "import code src/main.fnl"
]
```

**c) Vous n'avez que du code, aucune cartouche de base**

```json
"build": [
  "new fennel",
  "import code src/main.fnl"
]
```

Remplacez `fennel` par `lua`, `js`, `moon`, `wren`, ou `squirrel` selon votre langage.

**d) Vous voulez assembler plusieurs assets séparés**

```json
"build": [
  "new lua",
  "import tiles assets/tiles.gif",
  "import sprites assets/sprites.gif",
  "import map assets/map.txt",
  "import code src/main.lua"
]
```

Les chemins sont relatifs à votre `sourceDir`. Référence des commandes TIC-80 : <https://github.com/nesbox/TIC-80/wiki/Console>.

### 4. Vérifier en local (optionnel mais recommandé)

Depuis le dossier `web/` du repo : `npm run build:tic`. Si votre jeu apparaît dans `web/public/games/<votre-id>/`, c'est bon. Ouvrez `index.html` pour tester.

### 5. Push

La CI :

- détecte votre `game.json`,
- exécute votre séquence `build` dans TIC-80 headless,
- génère l'export HTML,
- régénère la galerie.

Aucun fichier de code côté web n'est à modifier. Si votre jeu n'apparaît pas : regarder les logs CI — chaque étape loggue une ligne explicite (champ manquant, fichier introuvable, commande TIC-80 en échec).

## Checklist d'exécution (ordre à suivre)

### Étapes de bootstrap (one-shot, réalisées par les mainteneurs du repo)

1. **Créer les `game.json` des 3 jeux d'exemple** avec un champ `build` adapté à chaque cas :
   - `Zigoto-Quest/game.json` → `build: ["load assets/game.tic"]`.
   - `Dodge! (QBitSoft)/game.json` → `build: ["load assets/game.tic"]`.
   - `echo-clone-souls/game.json` → `build: ["load assets/sprites.tic", "import code src/main.fnl"]`.
   - Ces 3 jeux couvrent les deux patterns principaux (cartouche prête / assemblage code+sprites) et servent de cas-tests.
2. (Supprimé — plus besoin de consolider `echo-clone-souls/assets/game.tic` à la main : le `build` le fait à chaque run.)
3. **Créer les `cover.png`** pour les 3 jeux d'exemple (réutiliser `Zigoto-Quest/image.png` et `Dodge! (QBitSoft)/images/main_game.png`, capturer une frame d'echo-clone).
4. **Scaffold Vite** : `cd web && npm create vite@latest . -- --template react-ts`. Ajouter `react-router-dom`, `react-markdown`, `tsx`.
5. **Types + scripts** :
   - `web/src/types/game.ts` (type `GameMeta` + fonction de validation runtime d'un `game.json`).
   - `web/scripts/discover-games.ts` (glob `*/game.json`, exclure `web/`, `node_modules/`, `.git/`, `.github/`, `.claude/`).
   - `web/scripts/build-tic-exports.ts` (itère sur le résultat du discover — jamais de liste en dur).
   - Scripts npm : `"dev": "vite"`, `"build:tic": "tsx scripts/build-tic-exports.ts"`, `"build": "npm run build:tic && vite build"`.
6. **Test local de l'auto-découverte** :
   - Avec les 3 jeux d'exemple, `npm run build:tic` produit 3 exports et un `games.generated.ts` avec 3 entrées.
   - **Test de généricité** : créer un 4ᵉ dossier factice (`fake-game/` avec une cartouche copiée + `game.json`), relancer `npm run build:tic`, vérifier qu'il apparaît sans aucune modif de code. Supprimer ensuite.
7. **Composants React + pages** : Layout, GameCard, GameGrid, PlayerFrame, GalleryPage, GamePage. `GalleryPage` mappe sur `GAMES` importé depuis `games.generated.ts` — le composant ne connaît aucun nom de jeu.
8. **Styles globaux** : fonts Google, palette, grid responsive.
9. **`.gitignore`** (racine) : ajouter `web/node_modules/`, `web/dist/`, `web/.tmp/`, `web/public/games/`, `web/public/covers/`, `web/src/data/games.generated.ts`.
10. **Workflow** : `.github/workflows/build.yml`. Le trigger doit s'activer sur tout push vers `main` (= un participant qui push son jeu).
11. **README racine** : inclure/pointer vers le §Guide participant pour que les contributeurs sachent quoi faire.
12. **Commit et push sur `web/v0.1`** ; ouvrir une PR vers `main` quand stable.

## Vérification end-to-end

**Local (mac)** :

1. `cd web && npm install`
2. `npm run build:tic` → un dossier `web/public/games/<slug>/` est créé **par jeu présent à la racine du repo** (pas de liste codée en dur).
3. Ouvrir directement l'un des `web/public/games/<slug>/index.html` dans le navigateur → le jeu joue.
4. `npm run dev` → <http://localhost:5173> → galerie contenant **exactement autant de cards qu'il y a de `game.json` valides** à la racine.
5. Cliquer une card → page jeu → cliquer l'overlay → jeu tourne, contrôles OK.
6. `npm run build && npm run preview` → même test sur le build de prod.

**Test de généricité (obligatoire avant de considérer le MVP terminé)** :

1. Ajouter un faux 4ᵉ jeu (dossier `test-game/` + `game.json` + cover + cartouche copiée depuis un jeu existant) à la racine.
2. `npm run build:tic && npm run dev` → la 4ᵉ card apparaît sans aucune modification de code/config.
3. Supprimer le dossier de test, relancer → la card disparaît.

**CI** :

1. Push sur `web/v0.1` → workflow vert dans l'onglet Actions.
2. Télécharger l'artifact `github-pages` → décompresser → tester qu'un `index.html` joue hors-ligne.
3. Simuler un ajout de jeu par un participant : push un 5ᵉ jeu sur une branche feature → la CI doit builder sans modification d'un fichier hors du dossier du jeu.
4. Quand hosting décidé : ajouter job `deploy` + activer Pages source = "GitHub Actions", visiter l'URL publique et rejouer le scénario.

## Hors scope MVP (à reporter)

- Code source viewer inline, screenshots multiples, galerie d'images par jeu
- Contrôles tactiles mobiles
- Recherche / filtres / tri dans la galerie
- Leaderboard, comptes, sauvegardes
- Déploiement (décision à prendre après le MVP)
