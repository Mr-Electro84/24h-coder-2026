# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projet

Jeu roguelike 2D pour **TIC-80** (fantasy console), ecrit en **Fennel** (dialecte Lisp compile en Lua). Hackathon "24h pour coder 2026" -- deadline 16 avril 2026, 11h00.

## Lancer le jeu

```bash
tic80 --skip --fs . --cmd="load assets/game.tic & import code src/main.fnl & run"
```

**Hot reload** : editer un `.fnl` -> dans TIC-80, `Ctrl+R`.

**Sauvegarder les assets** (sprites, map) : `Esc` dans TIC-80 pour acceder aux editeurs, puis `Ctrl+S`.

> Les fichiers `.lua` generes sont ignores par git (`.gitignore`). Ne committer que les `.fnl`.

## Architecture

### Boucle principale (`src/main.fnl`)

La fonction `TIC()` est appelee par TIC-80 a ~60 FPS. Elle orchestre dans l'ordre :
1. Init one-shot (`world.init-assets`)
2. Mise a jour joueur (`player.update`)
3. Mise a jour ennemis (`enemie.update`, `enemie.attack`)
4. Mise a jour projectiles (deplacement, collision ennemis, effets DoT/AoE)
5. Effets visuels (eclairs lightning)
6. Spawn de pickups (recompenses au sol, max 3 actifs, cooldown 300 frames)
7. Nettoyage des ennemis morts
8. Ecran de recompense (`item.update` si ouvert, bloque les autres updates)
9. Rendu : `world.draw` -> `enemie.draw` -> pickups -> `player.draw-ui` -> `player.draw` -> `player.draw-attack-cone` -> `item.draw`

### Modules

| Fichier | Role |
|---|---|
| `src/main.fnl` | Boucle TIC-80, etat global, projectiles, pickups, spawn ennemis |
| `src/player.fnl` | Mouvement, HP, attaques (epee + sorts + utilities), rendu joueur |
| `src/world.fnl` | Tilemap 30x17, collision AABB, generation des sprites en memoire |
| `src/enemie.fnl` | IA (pathfinding A*), combat contact avec cooldown, effets de statut (DoT, stun) |
| `src/abilities.fnl` | Definitions pures : epee (5 upgrades), sorts (2 sorts x upgrades), utilitaires (2 choix) |
| `src/astar.fnl` | Algorithme A* sur grille 8x8 (30x16), heuristique Manhattan, limite 1000 iterations |
| `src/item.fnl` | UI ecran de recompense : generation de 3 choix, selection, application |

### Systeme de collision (`world.fnl`)

- `world.wall?(x, y)` : pixel = sprite 12 ou 13 -> mur
- `world.can-move?(x, y, size)` : teste les 4 coins du carre 8x8
- `world.collide?(ax, ay, aw, ah, bx, by, bw, bh)` : AABB entre deux rectangles
- Le mouvement joueur/ennemis teste X et Y separement -> effet de glissement contre les murs

### Systeme de combat

**Epee** (`player.fnl`) :
- Attaque en arc (120 deg par defaut) devant le joueur, direction basee sur `facing-angle`
- Animation de sweep sur 8 frames, multi-hit possible
- Stats calculees dynamiquement via `abilities.compute-sword-stats`

**Sorts** (`player.fnl` + `main.fnl`) :
- **Fireball** (ID 1) : projectile(s), AoE optionnel, DoT (burn)
- **Lightning** (ID 2) : cible directe, chain bounce vers ennemis proches, stun
- Projectiles geres dans `main.fnl` : deplacement, collision, lifetime

**Utilitaires** (`player.fnl`) :
- **Dash** (ID 1) : teleportation 32px + i-frames
- **Thorn Shield** (ID 2) : degats reflechis passifs au contact ennemi

### Systeme d'abilities (`abilities.fnl`)

Module de **definition pure** expose :
- `compute-sword-stats [upgrade-ids]` : accumule les effets sur les stats de base
- `compute-spell-stats [spell-state]` : calcule stats du sort equipe
- `get-available-spell-upgrade-ids [spell-state]` : upgrades non appliquees
- Accesseurs : `get-sword-upgrade`, `get-spell`, `get-utility`, `get-spell-upgrade`

**Upgrades epee** : Damage+ (ID 1), Speed+ (ID 2), Range+ (ID 3), Sharp Arc (ID 4), Double Hit (ID 5)
**Sorts** : Fireball avec upgrades Explosion/Burn/Triple Shot ; Lightning avec upgrades Chain/Paralysis
**Utilitaires** : Dash (actif), Thorn Shield (passif)

**Etat des abilities dans le joueur** (`player.fnl`) :
```fennel
:id-sword-upgrades [0]                        ;; [0] = epee de base, 0 est sentinelle
:id-spell-upgrades {:id nil :applied-upgrades []} ;; nil = pas de sort equipe
:id-utility -1                                ;; -1 = pas d'utilitaire
```

### Systeme de recompenses (`item.fnl`)

- Apres pickup, affiche 3 cartes : 1 upgrade epee, 1 sort (nouveau ou upgrade), 1 utilitaire
- Selection avec fleches + bouton X, deduplication des choix
- Le jeu se met en pause pendant la selection

### Pathfinding A* (`astar.fnl`)

- Grille 8x8 (30x16 tiles), 4 directions
- Les ennemis recalculent leur chemin toutes les ~60 frames (desynchronises via randomisation)
- Fonction wall custom qui considere les autres ennemis comme obstacles
- Limite a 1000 iterations pour eviter les freezes

### Ce qui n'est pas encore implemente

Selon `specs.md` : progression par etages (4 combats -> shop -> boss), boutique, detection game over, collecte d'or, boss, machine a etats de jeu (IN_ROOM_COMBAT, ROOM_CLEARED_REWARD, IN_SHOP, etc.).

## Conventions Fennel

- Ne pas utiliser `(lua "return ...")` -- restructurer avec `if`/`when` natif Fennel
- Les modules exportent une table locale (ex: `(local player {})` ... `player`)
- Refs utiles : `docs/cheatsheet_fennel.md`, `docs/api_tic80.md`
