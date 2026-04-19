# Echo Clone

Echo Clone est un platformer TIC-80 écrit en Fennel. Le cœur du jeu repose sur les clones de runs précédentes, les compétences débloquées par fragments, et des pièges dynamiques.

## Stack

- TIC-80
- Fennel
- Une seule source principale : src/main.fnl

## Lancer le jeu

Depuis la racine du projet :

```bash
/Applications/tic80.app/Contents/MacOS/tic80 --skip --fs . --cmd="new fennel & load assets/sprites & import code src/main.fnl & run"
```

## Contrôles

- Gauche / Droite : déplacement
- Haut : saut
- A : mode spectateur on/off
- S : mort simulée (debug)
- Z / X : dash (après déblocage)
- Y / V : tir de boule de feu (après déblocage)
- K : interaction avec la structure de fin

## Gameplay

- Le joueur peut enregistrer et rejouer des runs fantômes (max 3 clones).
- Les clones immobiles servent de plateformes.
- 4 fragments à collecter pour débloquer les capacités principales.
- Systèmes d’ennemis : patrouilleurs, tireurs, chasseurs, rollers, flyers, projectiles.
- Checkpoints actifs avec respawn sur le dernier checkpoint touché.
- Interaction de fin : sur la structure finale, touche K change le skin du joueur vers sprite 448 et déclenche la victoire.

## Écran de fin

Après la victoire, un menu YOU WIN apparaît :

- RESTART : relance une partie
- MENU : retour à l’écran titre

Navigation : Haut/Bas, validation Z/X.

## Structure du projet

- src/main.fnl : logique complète du jeu
- assets/sprites.tic : cartouche sprites
- docs : notes de conception et docs annexes

## État actuel

- Compteur fragments aligné sur 4
- Bloc de structure de fin en place (tiles 171-173, y 15-18)
- Écran YOU WIN interactif intégré



