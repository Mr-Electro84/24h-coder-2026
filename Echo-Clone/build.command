#!/bin/bash
set -e  # arrêt immédiat si une commande échoue

cd Nextcloud/cours/projets-perso/24h-coder-2026/Echo-Clone

cat \
  src/constants.fnl \
  src/state.fnl \
  src/basics.fnl \
  src/sfx.fnl \
  src/map.fnl \
  src/physics.fnl \
  src/clones.fnl \
  src/player.fnl \
  src/traps.fnl \
  src/draw.fnl \
  src/screens.fnl \
  src/main.fnl \
  > src/build.fnl

grep "^(fn " src/build.fnl \
  | sed 's/^(fn \([a-zA-Z0-9?!_-]*\).*/\1/' \
  | while IFS= read -r name; do
      key=$(printf '%s' "$name" | sed 's/-/_2d/g; s/?/_3f/g; s/!/_21/g')
      printf '(tset _G "__fnl_global__%s" %s)\n' "$key" "$name"
    done >> src/build.fnl


/Applications/tic80.app/Contents/MacOS/tic80 --skip --fs . --cmd="load assets/game & import code src/build.fnl & run"