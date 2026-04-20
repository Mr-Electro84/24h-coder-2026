# STATE.md — État d'avancement

> Ce fichier doit être **mis à jour à chaque fin de tâche**. C'est la source de vérité pour savoir où reprendre.

## Statut global

**Phase** : 🟢 MVP fonctionnel local — reste à valider en CI.

**Branche de travail** : `web/v0.1`.

**Dernière action** : CI + déploiement GitHub Pages en place. Runtime TIC-80 (`tic80.js` + `tic80.wasm`) factorisé dans `_shared/` pour mutualiser le cache navigateur entre jeux. Prefetch du wasm dès l'arrivée sur le site (`App.tsx`). Spinner « Chargement du jeu… » affiché après le clic « Cliquez pour jouer » jusqu'au `postMessage({ticReady: true})` émis par `Module.onRuntimeInitialized` injecté dans l'HTML patché.

**Prochaine étape** : Vérifier en prod (GitHub Pages) que : (a) prefetch démarre au chargement de la galerie ; (b) spinner disparaît quand le jeu est jouable ; (c) charger un 2ᵉ jeu est quasi-instantané grâce au cache `_shared/`.

## État du repo (snapshot à la création de ce fichier)

> Le repo contient **3 jeux d'exemple** qui servent de cas-tests du pipeline d'auto-découverte. D'autres jeux seront ajoutés par les participants du hackathon — la galerie doit gérer ça sans modif de code.

- ✅ 3 dossiers de jeux présents, chacun avec sa propre organisation :
  - `Zigoto-Quest/` : cartouche prête dans `assets/game.tic` (142 Ko).
  - `Dodge! (QBitSoft)/` : cartouche prête dans `assets/game.tic` (46 Ko).
  - `echo-clone-souls/` : **pas de cartouche consolidée** — `assets/sprites.tic` (sprites seuls) + `src/main.fnl` (code Fennel). Ce n'est pas un manque à combler : le champ `build` du `game.json` gérera l'assemblage à chaque export.
- ❌ Aucun `game.json` dans les dossiers de jeux.
- ❌ Aucun `cover.png` dans les dossiers de jeux (mais `Zigoto-Quest/image.png` et `Dodge! (QBitSoft)/images/main_game.png` existent comme sources).
- ❌ Dossier `web/` absent.
- ❌ Dossier `.github/workflows/` absent.
- ❌ `README.md` racine ne documente pas encore le guide participant.
- `.gitignore` racine présent mais ne couvre pas encore les entrées `web/`.

## Checklist d'exécution

Cocher au fur et à mesure. Référence complète dans [SPECS.md §Étapes de bootstrap](SPECS.md#étapes-de-bootstrap-one-shot-réalisées-par-les-mainteneurs-du-repo).

> ⚠️ Règle transverse à respecter sur **toutes** les étapes : aucun nom de jeu ne doit apparaître en dur dans le code, la config ou la CI. Les 3 jeux actuels sont des cas-tests, pas une liste. Voir [CLAUDE.md §Principe fondateur](CLAUDE.md#principe-fondateur--auto-découverte).

- [x] **1. Créer un `game.json` pour chacun des 3 jeux d'exemple** (avec champ `build` adapté)
  - `Zigoto-Quest/game.json` : slug `zigoto-quest`, `build: ["load assets/game.tic"]`.
  - `Dodge! (QBitSoft)/game.json` : slug `dodge`, `sourceDir: "Dodge! (QBitSoft)"`, team `QBitSoft`, `build: ["load assets/game.tic"]`.
  - `echo-clone-souls/game.json` : slug `echo-clone-souls`, language Fennel, `build: ["load assets/sprites.tic", "import code src/main.fnl"]`.
  - Schéma complet : voir [SPECS.md §Schéma game.json](SPECS.md#schéma-gamejson).
- ~~**2. Consolider la cartouche `echo-clone`**~~ — plus nécessaire, géré dynamiquement par le `build`.
- [x] **3. Créer un `cover.png` pour chacun des 3 jeux d'exemple**
  - `Zigoto-Quest/cover.png` : dérivé de `Zigoto-Quest/image.png`.
  - `Dodge! (QBitSoft)/cover.png` : dérivé de `Dodge! (QBitSoft)/images/main_game.png`.
  - `echo-clone-souls/cover.png` : capture d'une frame en jeu.
- [x] **4. Scaffold Vite**
  - `mkdir web && cd web && npm create vite@latest . -- --template react-ts`.
  - `npm i react-router-dom react-markdown` + `npm i -D tsx`.
- [x] **5. Types + scripts build (génériques)**
  - `web/src/types/game.ts` (type `GameMeta` incluant `build: string[]` + validateur runtime).
  - `web/scripts/discover-games.ts` : glob `*/game.json` depuis la racine, exclure `web/`, `node_modules/`, `.git/`, `.github/`, `.claude/`. **Jamais de liste en dur.**
  - `web/scripts/build-tic-exports.ts` :
    - pour chaque jeu découvert, copier `sourceDir/*` vers `web/.tmp/<slug>/`,
    - construire la commande `<build joined by " & "> & export html out.zip & exit`,
    - exécuter TIC-80 headless, unzip la sortie vers `web/public/games/<slug>/`,
    - en cas d'échec d'un jeu : log + skip, ne pas planter les autres.
  - Scripts `package.json` : `dev`, `build:tic`, `build`, `preview`.
- [x] **6. Test local du script d'export**
  - `npm run build:tic` → 3 dossiers sous `web/public/games/` (un par jeu découvert).
  - Vérifier spécifiquement que `echo-clone-souls` joue après son export (c'est le cas d'assemblage `sprites + code` qui valide le mécanisme `build` en plusieurs étapes).
  - Ouvrir un `index.html` directement dans le navigateur → jeu joue.
- [x] **7. Composants + pages React**
  - `Layout`, `GameCard`, `GameGrid`, `PlayerFrame`.
  - `GalleryPage` (itère sur `GAMES` depuis `games.generated.ts`), `GamePage` (lookup par `id` dans le même array).
  - Router dans `App.tsx`. Aucune référence à un jeu spécifique dans le code.
- [x] **8. Styles globaux**
  - Fonts Google (`Press Start 2P`, `Inter`).
  - Palette `#0f0f1a` / `#f2f2f2` / `#e94560`.
  - Grid responsive.
- [x] **9. Mettre à jour `.gitignore` racine**
  - Ajouter : `web/node_modules/`, `web/dist/`, `web/.tmp/`, `web/public/games/`, `web/public/covers/`, `web/src/data/games.generated.ts`.
- [x] **10. Workflow GitHub Actions**
  - `.github/workflows/build.yml` (voir [SPECS.md §GitHub Actions](SPECS.md#github-actions)).
  - Doit se déclencher sur tout push `main` (= participant qui ajoute son jeu).
- [x] **11. README racine — guide participant**
  - Reprendre/pointer vers [SPECS.md §Guide participant](SPECS.md#guide-participant--jai-fait-un-jeu-comment-lajouter-à-la-galerie-).
  - 3 étapes visibles dès l'ouverture : dépose ton dossier, ajoute `game.json` + `cover.png`, push.
- [x] **12. Test de généricité**
  - Ajouter un 4ᵉ dossier factice avec `game.json` + cartouche copiée d'un jeu existant + cover.
  - `npm run build:tic && npm run dev` → 4ᵉ card apparaît sans modif de code.
  - Supprimer → la card disparaît.
- [x] **13. Push `web/v0.1` + PR vers `main`**
  - Workflow corrigé (`xvfb-run`, job `deploy` conditionné à `main`).
  - Activer Pages dans Settings → Pages → Source = "GitHub Actions" (one-shot manuel).

## Validation end-to-end (à faire en fin de MVP)

Voir [SPECS.md §Vérification end-to-end](SPECS.md#vérification-end-to-end). Les critères :

- [ ] `npm run build:tic` génère un export par jeu découvert (actuellement 3).
- [ ] Chaque `web/public/games/<slug>/index.html` joue ouvert seul.
- [ ] `npm run dev` affiche la galerie avec autant de cards que de `game.json` valides à la racine.
- [ ] Chaque page jeu lance le player via overlay, contrôles OK.
- [ ] Build de prod (`npm run build && npm run preview`) passe le même test.
- [ ] **Test de généricité** : ajouter un jeu factice → apparaît sans modif de code ; le retirer → disparaît.
- [ ] CI verte sur push.

## Décisions en attente

- ~~**Hosting** : reporté post-MVP~~ → **Activé** : GitHub Pages, URL `https://bde-ceri.github.io/24h-coder-2026/`. Action one-shot restante : Settings → Pages → Source = "GitHub Actions".

## Journal des mises à jour

### Côté App Web
- **2026-04-20** : Optimisations perf GH Pages. (1) Factorisation `tic80.js`/`tic80.wasm` dans `public/games/_shared/` + patch regex (quotes simples **et** doubles) des chemins dans l'HTML exporté et dans le JS runtime. (2) `#game-frame` auto-caché → le JS TIC-80 démarre le fetch du wasm sans attendre de clic interne. (3) Prefetch des runtimes injecté au mount de `App.tsx`. (4) `Module.onRuntimeInitialized` patché pour `postMessage({ticReady: true})` au parent ; `PlayerFrame` écoute ce message pour masquer le spinner. (5) Préfixe `$` shell dans le `build` array essayé puis retiré (pas grave, `build.fnl` d'Echo-Clone est commité à jour).
- **2026-04-20** : Workflow CI finalisé : `xvfb-run -a` sur `build:tic` (correctif headless Linux), job `deploy` vers GitHub Pages conditionné à `main`, `concurrency` anti-concurrent. Correctif URL release TIC-80 (`.deb` Linux, pas `.zip`). Docs (SPECS, CLAUDE, STATE) mis à jour pour refléter hosting activé.
- **2026-04-19** : Implémentation complète des étapes 1, 3-12. Pipeline TIC-80 → exports HTML → galerie React validé en local (3/3 jeux, test de généricité OK avec ajout/retrait d'un 4ᵉ jeu factice). Build prod (`vite build`) passe. Reste : push + valider la CI.
- **2026-04-19** : Plan validé avec l'utilisateur. Création de `CLAUDE.md`, `SPECS.md`, `STATE.md`. Aucune tâche d'implémentation entamée.
- **2026-04-19** : Clarification — les participants du hackathon ajouteront leurs propres jeux. Architecture durcie autour de l'auto-découverte (aucune liste en dur). Ajout d'un guide participant dans SPECS, d'un test de généricité dans la checklist, et d'une étape README.
- **2026-04-19** : Clarification — les jeux n'ont pas tous une cartouche `.tic` prête. Schéma `game.json` modifié : remplacement du champ `ticPath` par `build: string[]` (séquence de commandes TIC-80). Le script de build copie tout le `sourceDir` dans un tmp et exécute la séquence avant export. L'étape de consolidation manuelle de `echo-clone-souls` devient inutile (gérée par son `build`).
### Côté Updates sur les Jeux
- **2026-04-19** : Refonte du jeu **Echo Clone** -- corrections de bugs notamment sur le système de checkpoints, division de ``main.fnl`` en 12 fichiers différents pour le trie de toute les fonctions du jeu, paramètres et SFXs. Création d'un fichier permettant de compiler tous les fichiers .fnl -> La solution a été de créer un builder en powershell qui cat tous les fichiers fnl vers un seul et unique ``build.fnl``qui est ensuite appelé lors de la compilation dans ``build.command`` ! Enfin, ajout d'une animation sur la lave afin de rendre le jeu encore plus dynamique.
