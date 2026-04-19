# 24 heures pour coder — Dépôt des projets

Bienvenue sur le dépôt des projets du hackathon **24 heures pour coder** organisé par le BDE.

Ce dépôt sert à regrouper les projets des équipes participantes dans un seul **monorepo**.

## Organisation du dépôt

Chaque équipe doit placer son projet dans **un dossier unique portant le nom de l’équipe**.

Le nom du dossier doit respecter ce format :

- lettres `a-z`
- chiffres `0-9`
- tiret `-`
- underscore `_`

Merci de **ne pas utiliser** :

- d’espace
- d’accent
- de caractères spéciaux

### Exemples valides

- `team_rocket`
- `code-breakers`
- `equipe42`

### Exemples invalides

- `Équipe 42`
- `Les Devs!`
- `team rocket`

## Structure attendue

```text
/
├─ README.md
├─ team_rocket/
│  ├─ README.md
│  ├─ src/
│  └─ ...
├─ code-breakers/
│  ├─ README.md
│  ├─ app/
│  └─ ...
└─ equipe42/
   ├─ README.md
   └─ ...
