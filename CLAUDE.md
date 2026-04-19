# CLAUDE.md — Guide de reprise pour Claude

## À lire en premier

Ce fichier est le point d'entrée pour toute instance de Claude qui reprend le projet. Avant toute action :

1. Lire **ce fichier** en entier (contexte global + conventions).
2. Lire [SPECS.md](SPECS.md) (objectifs, architecture cible, décisions figées).
3. Lire [STATE.md](STATE.md) (où en est le projet, quelle est la prochaine étape).

Ces trois fichiers sont la source de vérité. Si une info manque, demander à l'utilisateur avant d'improviser.

## Contexte global

Le repo agrège les jeux TIC-80 produits pendant le hackathon annuel **"24h pour coder"** (édition 2026). **Les participants pushent leurs propres dossiers de jeux dans ce repo pendant/après le hackathon.** Au moment d'écrire ces lignes il y a 3 jeux d'exemple (`echo-clone-souls/`, `Zigoto-Quest/`, `Dodge! (QBitSoft)/`), mais **le nombre et les noms des jeux sont dynamiques** — ne jamais les hardcoder.

Aucun moyen aujourd'hui de découvrir ou jouer ces jeux sans cloner le repo et installer TIC-80. **L'objectif du projet courant est de construire une galerie web statique** qui liste les jeux et les lance directement dans le navigateur via des exports HTML TIC-80 générés en CI.

## Principe fondateur : auto-découverte

L'architecture **doit être générique**. La règle unique :

> Tout dossier à la racine du repo contenant un `game.json` valide est un jeu. La galerie se construit automatiquement à partir de ces fichiers, sans modification de code.

Conséquences directes :

- Les scripts de build (`discover-games.ts`, `build-tic-exports.ts`) **globent** les `*/game.json`, jamais une liste codée en dur.
- La liste des jeux côté React vient de `games.generated.ts` (produit par le build), jamais d'un import statique.
- Pour ajouter un jeu : un participant dépose son dossier + `game.json` + `cover.png` à la racine, push, et la CI rebuild. Aucun fichier de code à toucher.
- Les 3 jeux actuels sont des **exemples de validation** de ce pipeline, pas une liste exhaustive.

Cette contrainte d'auto-découverte est plus importante que n'importe quel raccourci d'implémentation. Si une solution "marche" mais impose d'ajouter le nom d'un jeu quelque part dans le code → refuser, retravailler.

### Corollaire : les jeux ne sont pas structurés pareil

Chaque dossier de jeu a sa propre organisation interne (arbre, noms de fichiers, présence ou non d'une cartouche `.tic` prête). Certains livrent `assets/game.tic` déjà jouable, d'autres uniquement des sources Fennel/Lua + sprites à assembler à la volée, d'autres du code brut sans cartouche.

Le pipeline gère cette hétérogénéité via un champ **`build`** dans `game.json` : une **liste de commandes TIC-80** que le script joue dans un tmp pour produire la cartouche finale, puis export HTML. Cf. [SPECS §Schéma game.json](SPECS.md#schéma-gamejson) et §Guide participant. Ne pas supposer qu'un jeu a une cartouche pré-construite.

## Décisions figées (ne pas rediscuter sans raison)

- **Stack web** : Vite + React + TypeScript, dans un dossier `web/` à la racine.
- **Player** : export HTML par jeu via CLI TIC-80, chargé en iframe.
- **Métadonnées** : un `game.json` par dossier jeu.
- **Covers** : un `cover.png` manuel par dossier jeu.
- **CI** : GitHub Actions pour builder les exports + le site.
- **Hosting** : reporté (probablement GitHub Pages plus tard — le workflow valide juste le build pour l'instant).
- **Scope MVP** : galerie (cards) + page jeu (player + contrôles + description). Pas de recherche, pas de filtres, pas de mobile tactile.

Détails complets → [SPECS.md](SPECS.md).

## Arborescence (vue d'ensemble)

```
24h-coder-2026/
├── CLAUDE.md              ← ce fichier
├── SPECS.md               ← specs détaillées + guide "Ajouter un jeu"
├── STATE.md               ← état d'avancement
├── <dossier-jeu-1>/       ← N dossiers de jeux à la racine (N dynamique)
│   ├── game.json          ← métadonnée + recette de build (champ `build`)
│   ├── cover.png          ← vignette pour la galerie
│   └── ...                ← organisation interne libre (sources, .tic, assets…)
├── <dossier-jeu-2>/
├── ...
├── .github/workflows/     ← CI (build + déploiement)
└── web/                   ← app React qui auto-découvre les jeux
```

Actuellement 3 dossiers de jeux (exemples) : `echo-clone-souls/`, `Zigoto-Quest/`, `Dodge! (QBitSoft)/`. Les participants ajouteront le leur.

## Conventions importantes

- **Slug ≠ nom de dossier** : `Dodge! (QBitSoft)` → slug `dodge`. Le slug est la seule chose utilisée dans les URLs et chemins de build. Le lien dossier ↔ slug se fait via le champ `sourceDir` dans `game.json`.
- **Pinner TIC-80** : version `v1.1.2837` en CI, pour reproductibilité.
- **Headless Linux** : toujours préfixer `tic80 --cli` par `xvfb-run -a` en CI.
- **Fichiers générés gitignorés** : `web/public/games/`, `web/public/covers/`, `web/src/data/games.generated.ts`, `web/.tmp/`, `web/dist/`, `web/node_modules/`.
- **Branche de dev** : `web/v0.1` pour l'itération initiale, PR vers `main` quand stable.

## Comment reprendre le travail

1. Lire [STATE.md](STATE.md) → identifier la case non cochée la plus haute dans la checklist.
2. Vérifier (via `git status` + `ls`) que l'état décrit correspond à la réalité du repo.
3. Exécuter la tâche.
4. **Mettre à jour [STATE.md](STATE.md)** : cocher la case, mettre à jour "Dernière action" et "Prochaine étape".
5. Commit avec un message clair.

Si l'utilisateur demande de repartir d'un endroit précis, ignorer la checklist et suivre sa demande — mais toujours mettre à jour `STATE.md` ensuite.

## Commandes clés (une fois `web/` créé)

```bash
cd web
npm install              # installer les deps
npm run build:tic        # générer les exports HTML TIC-80
npm run dev              # dev server Vite sur :5173
npm run build            # build:tic + vite build
npm run preview          # servir le build de prod
```

## À ne PAS faire

- **Ne jamais hardcoder une liste de jeux** dans le code, la config, ou la CI. Toujours globber les `*/game.json`.
- **Ne jamais casser un jeu existant** quand on ajoute une feature. Le pipeline doit rester "dossier + game.json = jeu".
- Ne pas utiliser Tailwind (trop lourd pour 2 pages — voir SPECS).
- Ne pas introduire un job de déploiement CI tant que l'hosting n'est pas décidé.
- Ne pas modifier les jeux eux-mêmes (code Fennel/Lua, cartouches `.tic`, assets). Si un jeu n'a pas de cartouche prête, ce n'est pas un bug à corriger côté jeu : c'est au `build` du `game.json` de décrire comment l'assembler.
- Ne pas commit les fichiers générés (`games.generated.ts`, `public/games/`, `public/covers/`).
