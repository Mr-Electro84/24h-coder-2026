;; title:  Echo Clone
;; author: Equipe 7
;; desc:   Platformer TIC-80 en Fennel avec clones rejouant les runs precedentes.
;; script: fennel
;; /Applications/tic80.app/Contents/MacOS/tic80 --skip --fs . --cmd="load assets/sprites & import code src/main2.fnl & run"

(global SCREEN-W 240)
(global SCREEN-H 136)
(global TILE-SIZE 8)
(global LEVEL-W 30)
(global LEVEL-H 17)
(global MAP-TILES-W 240)
(global MAP-TILES-H 136)
(global MAX-CLONES 3)
(global USE-CART-SPRITES true)
(global USE-CART-SFX true)

(global GRAVITY 0.3)
(global WALK-SPEED 1.5)
(global JUMP-FORCE -3.5)
(global MAX-FALL 4.0)
(global SPECTATOR-SPEED 2.5)
(global FOLLOW-SEGMENTS 9)
(global FOLLOW-LERP 0.45)

(global FLAG-SOLID 0)
(global FLAG-DEADLY 1)
(global FLAG-PATROLLER 2)
(global FLAG-SHOOTER 3)
(global FLAG-EXIT 4)

(global SPR-PLAYER-A 256)
(global SPR-PLAYER-B 288)
(global SPR-CLONE-A 256)
(global SPR-PATROLLER 4)
(global SPR-SHOOTER 324)
(global SPR-PROJECTILE 16)
(global SPR-GOBLIN-FIRE 392)
(global SPR-HUNTER-TL 260)
(global SPR-HUNTER-TR 261)
(global SPR-HUNTER-BL 276)
(global SPR-HUNTER-BR 277)
(global SPR-CHECKPOINT-OFF 16)
(global SPR-CHECKPOINT-ON 32)

(global SPAWN-X 952)
(global SPAWN-Y 520)
(global SPAWN-TX (// SPAWN-X TILE-SIZE))
(global SPAWN-TY (// SPAWN-Y TILE-SIZE))
(global CHECKPOINT-A-TX 231)
(global CHECKPOINT-A-TY 25)
(global CHECKPOINT-B-TX 119)
(global CHECKPOINT-B-TY 64)
(global CHECKPOINT-C-TX 30)
(global CHECKPOINT-C-TY 36)
(global CHECKPOINT-D-TX 213)
(global CHECKPOINT-D-TY 87)
(global DOOR-TX 118)
(global DOOR-TY 65)
(global DOOR-TRIGGER-TX 117)
(global DOOR-TRIGGER-TY 65)
(global DOOR2-TX 74)
(global DOOR2-TY 53)
(global DOOR2-TRIGGER-TX 73)
(global DOOR2-TRIGGER-TY 53)
(global DOOR3-TX 180)
(global DOOR3-TY 78)
(global DOOR4-TX 69)
(global DOOR4-TY 117)
(global DOOR-CLOSED-TL 4)
(global DOOR-CLOSED-TR 5)
(global DOOR-CLOSED-BL 20)
(global DOOR-CLOSED-BR 21)
(global DOOR-OPEN-TL 36)
(global DOOR-OPEN-TR 37)
(global DOOR-OPEN-BL 52)
(global DOOR-OPEN-BR 53)
(global FIXED-TILE-X 45)
(global FIXED-TILE-Y 26)
(global FIXED-TILE-ID 1)
(global FIXED-TILE-2-Y 27)
(global EXTRA-TILE-X 44)
(global EXTRA-TILE-Y 27)
(global EXTRA-TILE-ID 81)
(global EXTRA-TILE-2-X 46)
(global EXTRA-TILE-2-Y 27)
(global EXTRA-TILE-2-ID 97)
(global CUSTOM-TILE-X 209)
(global CUSTOM-TILE-Y 19)
(global CUSTOM-TILE-ID 95)
(global SOLO-BLACK-BLOCK-X 126)
(global SOLO-BLACK-BLOCK-Y 121)
(global SOLO-BLACK-BLOCK-ID 81)
(global SOLO-RIGHT-BLOCK-ID 1)
(global SOLO-RIGHT2-BLOCK-ID 102)
(global STELE2-X 65)
(global STELE2-Y 118)
(global STELE2-BASE-ID 81)
(global STELE2-TOP-L-ID 1)
(global STELE2-TOP-R-ID 102)
(global STELE2-FRAGMENT-TILE-X 64)
(global STELE2-FRAGMENT-TILE-Y 118)
(global STELE2-FRAGMENT-TILE-ID 94)
(global END-FINISH-X-LEFT 171)
(global END-FINISH-X-MID 172)
(global END-FINISH-X-RIGHT 173)
(global END-FINISH-Y-TOP 15)
(global END-FINISH-Y-ROW2 16)
(global END-FINISH-Y-ROW3 17)
(global END-FINISH-Y-BOTTOM 18)
(global FIRE-FRAGMENT-TILE-X (+ SOLO-BLACK-BLOCK-X 3))
(global FIRE-FRAGMENT-TILE-Y SOLO-BLACK-BLOCK-Y)
(global FIRE-FRAGMENT-TILE-ID 110)
(global DASH-FRAGMENT-TILE-X 43)
(global DASH-FRAGMENT-TILE-Y 27)
(global DASH-FRAGMENT-TILE-ID 111)
(global FRAGMENT-TOTAL 4)
(global FIREBALL-SPR-A 212)
(global FIREBALL-SPR-B 213)
(global HUNTER-START-TX 209)
(global HUNTER-START-TY 18)
(global HUNTER-STOP-TX 158)
(global HUNTER-STOP-TY 48)
(global SENTRY-TX 196)
(global SENTRY-TY 15)
(global SENTRY-L-TL 296)
(global SENTRY-L-TR 297)
(global SENTRY-L-BL 312)
(global SENTRY-L-BR 313)
(global SENTRY-R-TL 328)
(global SENTRY-R-TR 329)
(global SENTRY-R-BL 344)
(global SENTRY-R-BR 345)
(global ROLLER-SPRITE 320)
(global ROLLER-START-TX 7)
(global ROLLER-START-TY 32)
(global ROLLER-MIN-TX 7)
(global ROLLER-MAX-TX 13)
(global ROLLER2-START-TX 16)
(global ROLLER2-START-TY 33)
(global ROLLER2-MIN-TX 16)
(global ROLLER2-MAX-TX 22)
(global ROLLER3-SPRITE 336)
(global ROLLER3-START-TX 137)
(global ROLLER3-START-TY 89)
(global ROLLER3-MIN-TX 137)
(global ROLLER3-MAX-TX 143)
(global ROLLER4-SPRITE 336)
(global ROLLER4-START-TX 157)
(global ROLLER4-START-TY 99)
(global ROLLER4-MIN-TX 157)
(global ROLLER4-MAX-TX 164)
(global ROLLER5-SPRITE 336)
(global ROLLER5-START-TX 145)
(global ROLLER5-START-TY 90)
(global ROLLER5-MIN-TX 145)
(global ROLLER5-MAX-TX 158)
(global FLYER-SPRITE 336)
(global FLYER-START-TX 126)
(global FLYER-START-TY 106)
(global FLYER-MIN-TX 126)
(global FLYER-MAX-TX 137)
(global GOBLIN2-TX 188)
(global GOBLIN2-TY 22)
(global GOBLIN3-START-TX 174)
(global GOBLIN3-TY 112)
(global GOBLIN3-MIN-TX 174)
(global GOBLIN3-MAX-TX 178)
(global GOBLIN3-SPRITE 16)
(global GOBLIN4-TX 47)
(global GOBLIN4-TY 121)
(global GOBLIN5-TX 51)
(global GOBLIN5-TY 121)
(global FLAME-TILE-X 45)
(global FLAME-TILE-Y 25)
(global FIXED-TILE-B-X 212)
(global FIXED-TILE-B-Y 18)
(global FIXED-TILE-B-2-Y 19)
(global EXTRA-TILE-B-L-X 211)
(global EXTRA-TILE-B-R-X 213)
(global EXTRA-TILE-B-Y 19)
(global FLAME-TILE-B-X 212)
(global FLAME-TILE-B-Y 17)
(global FLAME-TILE-C-X (+ SOLO-BLACK-BLOCK-X 1))
(global FLAME-TILE-C-Y (- SOLO-BLACK-BLOCK-Y 2))
(global FLAME-TILE-D-X 66)
(global FLAME-TILE-D-Y 116)
(global FLAME-DRAW-OFFSET-X 1)
(global FLAME-DRAW-OFFSET-Y 1)

(var state
  {:mode :menu
   :timer 0
   :flash 0
   :flash-color 15
   :message-timer 0
   :prev-start false
   :prev-choice false
   :music-started false})

(var ghost-recordings [])
(var current-recording [])
(var current-start-x 0)
(var current-start-y 0)
(var respawn-x SPAWN-X)
(var respawn-y SPAWN-Y)
(var player {:x 0 :y 0 :vx 0 :vy 0 :on-ground false :dir 1 :alive true :kind :player})
(var active-clones [])
(var patrollers [])
(var shooters [])
(var hunters [])
(var sentries [])
(var rollers [])
(var flyers [])
(var projectiles [])
(var solid-clones [])
(var sound-sequence nil)
(var stars [])
(var mouse-released true)
(var title-time 0)
(var shake-timer 0)
(var shake-x 0)
(var shake-y 0)
(var cam-x 0)
(var cam-y 0)
(var player-trail [])
(var show-player-tail true)
(var show-player-wings false)
(var options-selection 1)
(var checkpoint-a-touched false)
(var checkpoint-b-touched false)
(var checkpoint-c-touched false)
(var checkpoint-d-touched false)
(var door-open false)
(var door-system-armed false)
(var spectator-mode false)
(var flame-sprite 432)
(var lava-sprite 47)
(var fragment-collected false)
(var dash-fragment-collected false)
(var fire-fragment-collected false)
(var stele2-fragment-collected false)
(var fragment-count 0)
(var clone-system-unlocked false)
(var dash-unlocked false)
(var fire-skill-unlocked false)
(var ladder-unlocked false)
(var fireball-cooldown 0)
(var dash-active-timer 0)
(var dash-cooldown 0)
(var dash-dir 1)
(var dash-speed-steps 6)
(var impact-flames [])
(global player-skin-sprite SPR-PLAYER-B)
(global win-selection 1)

;; Retourne la valeur absolue de n.
(fn abs [n]
  (if (< n 0) (- 0 n) n))

;; Contraint value entre low et high inclus.
(fn clamp [value low high]
  (math.min high (math.max low value)))

;; Retourne la longueur d'une table sequentielle (equivalent de #xs).
(fn list-length [xs]
  (# xs))

;; Retourne true si le point (mx,my) se trouve dans le rectangle (x,y,w,h).
;; Utilise pour la detection de survol souris sur les boutons du menu.
(fn in-rect? [mx my x y w h]
  (and (>= mx x) (<= mx (+ x w))
       (>= my y) (<= my (+ y h))))

;; Dessine un rectangle avec des coins arrondis de rayon r et de couleur color.
;; Utilise plusieurs rect et circ pour simuler l'arrondi.
(fn rounded-rect [x y w h color radius]
  (rect (+ x radius) y (- w (* 2 radius)) h color)
  (rect x (+ y radius) w (- h (* 2 radius)) color)
  (circ (+ x radius) (+ y radius) radius color)
  (circ (- (+ x w) radius) (+ y radius) radius color)
  (circ (+ x radius) (- (+ y h) radius) radius color)
  (circ (- (+ x w) radius) (- (+ y h) radius) radius color))

;; Retourne true si deux rectangles AABB se chevauchent.
;; Utilise pour toutes les collisions entre entites (joueur, ennemis, projectiles).
(fn aabb-overlap [ax ay aw ah bx by bw bh]
  (and (< ax (+ bx bw))
       (< bx (+ ax aw))
       (< ay (+ by bh))
       (< by (+ ay ah))))

;; Decode un bitmask 3 bits en [gauche droite saut].
;; Bit 0 = gauche, bit 1 = droite, bit 2 = saut.
;; Utilise pour rejouer les inputs enregistres des clones.
(fn decode-bitmask [mask]
  [(= (% mask 2) 1)
   (>= (% mask 4) 2)
   (>= mask 4)])

;; Demarre une sequence sonore composee de plusieurs notes jouees en ordre.
;; Chaque step contient id, note, duration, channel, volume, speed et wait.
(fn start-sound-sequence [steps]
  (set sound-sequence {:steps steps :index 1 :timer 0}))

;; Avance la sequence sonore d'un tick : attend le bon moment puis joue le sfx suivant.
;; Appelee chaque frame dans TIC() pour gerer les sons multi-notes.
(fn update-sound-sequence []
  (when sound-sequence
    (if (> sound-sequence.timer 0)
      (set sound-sequence.timer (- sound-sequence.timer 1))
      (if (<= sound-sequence.index (list-length sound-sequence.steps))
        (let [step (. sound-sequence.steps sound-sequence.index)]
          (sfx step.id step.note step.duration step.channel step.volume step.speed)
          (set sound-sequence.index (+ sound-sequence.index 1))
          (set sound-sequence.timer step.wait))
        (set sound-sequence nil)))))

;; Joue le son de saut du joueur.
;; Utilise sfx 0 si la cartouche a des sons, sinon joue une sequence montante.
(fn play-jump-sound []
  (if USE-CART-SFX (sfx 0)
    (start-sound-sequence
      [{:id 0 :note "C-5" :duration 5 :channel 0 :volume 9  :speed 0 :wait 2}
       {:id 0 :note "E-5" :duration 5 :channel 0 :volume 10 :speed 0 :wait 2}
       {:id 0 :note "G-5" :duration 6 :channel 0 :volume 11 :speed 0 :wait 3}
       {:id 0 :note "C-6" :duration 8 :channel 0 :volume 12 :speed 0 :wait 4}])))

;; Joue le son de mort du joueur.
;; Sequence descendante dramatique si pas de sons en cartouche.
(fn play-death-sound []
  (if USE-CART-SFX (sfx 1)
    (start-sound-sequence
      [{:id 1 :note "A-4" :duration 6  :channel 1 :volume 15 :speed -1 :wait 2}
       {:id 1 :note "F-4" :duration 6  :channel 1 :volume 15 :speed -1 :wait 2}
       {:id 1 :note "D-4" :duration 8  :channel 1 :volume 14 :speed -2 :wait 3}
       {:id 1 :note "C-4" :duration 9  :channel 1 :volume 14 :speed -2 :wait 3}
       {:id 1 :note "A-3" :duration 12 :channel 1 :volume 15 :speed -3 :wait 4}
       {:id 1 :note "F-3" :duration 16 :channel 1 :volume 15 :speed -4 :wait 8}])))

;; Joue le son de victoire (sortie du niveau atteinte).
;; Sequence montante joyeuse si pas de sons en cartouche.
(fn play-win-sound []
  (if USE-CART-SFX (sfx 3)
    (start-sound-sequence
      [{:id 3 :note "C-5" :duration 5  :channel 2 :volume 11 :speed 1 :wait 2}
       {:id 3 :note "E-5" :duration 5  :channel 2 :volume 11 :speed 1 :wait 2}
       {:id 3 :note "G-5" :duration 6  :channel 2 :volume 12 :speed 1 :wait 2}
       {:id 3 :note "C-6" :duration 7  :channel 2 :volume 13 :speed 1 :wait 2}
       {:id 3 :note "E-6" :duration 8  :channel 2 :volume 14 :speed 1 :wait 2}
       {:id 3 :note "G-6" :duration 12 :channel 2 :volume 15 :speed 1 :wait 6}])))

;; Joue le son de creation d'un clone fantome.
;; Accord montant doux si pas de sons en cartouche.
(fn play-clone-sound []
  (if USE-CART-SFX (sfx 2)
    (start-sound-sequence
      [{:id 2 :note "E-4" :duration 4 :channel 3 :volume 9  :speed 0 :wait 2}
       {:id 2 :note "G-4" :duration 4 :channel 3 :volume 10 :speed 0 :wait 2}
       {:id 2 :note "B-4" :duration 5 :channel 3 :volume 11 :speed 0 :wait 2}
       {:id 2 :note "E-5" :duration 8 :channel 3 :volume 12 :speed 0 :wait 4}])))

;; Retourne le point central [x y] d'une entite en pixels.
;; Tient compte de la largeur et hauteur de l'entite (defaut 8x8).
(fn entity-midpoint [entity]
  (let [w (or entity.w 8)
        h (or entity.h 8)]
    [(+ entity.x (/ w 2)) (+ entity.y (/ h 2))]))

;; Retourne la distance au carre entre deux points.
;; Evite un sqrt couteux pour les comparaisons de distance.
(fn dist2 [ax ay bx by]
  (let [dx (- ax bx) dy (- ay by)]
    (+ (* dx dx) (* dy dy))))

;; Retourne l'ID du tile TIC-80 aux coordonnees tile (tx,ty).
;; Retourne 0 si hors limites de la map.
(fn map-tile [tx ty]
  (if (or (< tx 0) (< ty 0) (>= tx MAP-TILES-W) (>= ty MAP-TILES-H))
    0
    (mget tx ty)))

;; Retourne true si le tile en (tx,ty) a le flag FLAG-SOLID coche.
;; Les bords gauche/droite/haut de la map sont toujours solides.
(fn tile-solid? [tx ty]
  (if (or (< tx 0) (>= tx MAP-TILES-W) (< ty 0))
    true
    (if (>= ty MAP-TILES-H)
      false
      (fget (map-tile tx ty) FLAG-SOLID))))

;; Retourne true si le tile en (tx,ty) est mortel (flag ou ID specifique).
;; Liste les IDs de tiles mortels hardcodes (piques, lave, etc.).
(fn tile-deadly? [tx ty]
  (if (or (< tx 0) (>= tx MAP-TILES-W) (< ty 0) (>= ty MAP-TILES-H))
    false
    (let [tile (map-tile tx ty)]
      (or (fget tile FLAG-DEADLY)
          (= tile 100) (= tile 101) (= tile 47) (= tile 159)
          (= tile 116) (= tile 117) (= tile 132)
          (= tile 149) (= tile 164) (= tile 181)))))

;; Retourne true si le tile en (tx,ty) est une sortie de niveau (flag EXIT).
(fn tile-exit? [tx ty]
  (if (or (< tx 0) (>= tx MAP-TILES-W) (< ty 0) (>= ty MAP-TILES-H))
    false
    (fget (map-tile tx ty) FLAG-EXIT)))

;; Retourne true si le pixel (px,py) est sur un tile solide.
(fn point-solid? [px py]
  (tile-solid? (// px TILE-SIZE) (// py TILE-SIZE)))

;; Retourne true si le pixel (px,py) est sur un tile echelle (ID 48).
;; Utilise pour detecter si le joueur peut grimper.
(fn point-ladder? [px py]
  (= (map-tile (// px TILE-SIZE) (// py TILE-SIZE)) 48))

;; Cherche si une entite en mouvement chevauche un clone immobile (plateforme).
;; Retourne le clone touche ou nil. Ignore self pour eviter l'auto-collision.
(fn solid-platform-overlap [self nx ny w h]
  (var hit nil)
  (each [_ clone (ipairs solid-clones)]
    (when (and clone.alive (not= clone self)
               (aabb-overlap nx ny w h clone.x clone.y (or clone.w 8) (or clone.h 8)))
      (set hit clone)))
  hit)

;; Retourne true si l'entite self serait en collision a la position (nx,ny).
;; Teste les 4 coins de la hitbox contre les tiles solides et les clones immobiles.
(fn collides-at? [self nx ny]
  (let [w (or self.w 8)
        h (or self.h 8)
        rx (+ nx (- w 1))
        by (+ ny (- h 1))]
    (or (point-solid? nx ny)
        (point-solid? rx ny)
        (point-solid? nx by)
        (point-solid? rx by)
        (solid-platform-overlap self nx ny w h))))

;; Retourne true si l'entite chevauche un tile mortel ou est tombee hors de la map.
;; Scanne tous les tiles couverts par la hitbox de l'entite.
(fn entity-on-deadly-tile? [entity]
  (if (> entity.y (* MAP-TILES-H TILE-SIZE))
    true
    (let [w (or entity.w 8)
          h (or entity.h 8)
          left   (// entity.x TILE-SIZE)
          right  (// (+ entity.x (- w 1)) TILE-SIZE)
          top    (// entity.y TILE-SIZE)
          bottom (// (+ entity.y (- h 1)) TILE-SIZE)]
      (var deadly false)
      (for [ty top bottom]
        (for [tx left right]
          (when (tile-deadly? tx ty) (set deadly true))))
      deadly)))

;; Retourne true si l'entite touche un tile de sortie de niveau.
;; Scanne tous les tiles couverts par la hitbox.
(fn entity-on-exit? [entity]
  (let [w (or entity.w 8)
        h (or entity.h 8)
        left   (// entity.x TILE-SIZE)
        right  (// (+ entity.x (- w 1)) TILE-SIZE)
        top    (// entity.y TILE-SIZE)
        bottom (// (+ entity.y (- h 1)) TILE-SIZE)]
    (var found false)
    (for [ty top bottom]
      (for [tx left right]
        (when (tile-exit? tx ty) (set found true))))
    found))

;; Retourne true si l'entite couvre le tile (tx,ty).
;; Utilise pour la collecte de fragments et la detection de checkpoints.
(fn entity-covers-tile? [entity tx ty]
  (let [w (or entity.w 8)
        h (or entity.h 8)
        left   (// entity.x TILE-SIZE)
        right  (// (+ entity.x (- w 1)) TILE-SIZE)
        top    (// entity.y TILE-SIZE)
        bottom (// (+ entity.y (- h 1)) TILE-SIZE)]
    (and (>= tx left) (<= tx right)
         (>= ty top) (<= ty bottom))))

;; Retourne true si un mur solide se trouve devant l'entite dans la direction dir.
;; Utilise pour le dash afin de decider si on tente de traverser un bloc fin.
(fn dash-wall-ahead? [entity dir]
  (let [probe-x (+ entity.x (* dir 4))]
    (collides-at? entity probe-x entity.y)))

;; Tente de faire avancer l'entite d'un pixel dans dir, en traversant un mur fin.
;; Si le mur fait au plus 1 tile d'epaisseur, l'entite le traverse et retourne true.
;; Retourne false si le mur est trop epais.
(fn dash-step-through-thin-wall [entity dir]
  (let [next-x (+ entity.x dir)]
    (if (not (collides-at? entity next-x entity.y))
      (do (set entity.x next-x) true)
      (do
        (var probe next-x)
        (let [max-thickness (+ TILE-SIZE (or entity.w 8))]
          (var thickness 0)
          (while (and (<= thickness max-thickness)
                      (collides-at? entity probe entity.y))
            (set probe (+ probe dir))
            (set thickness (+ thickness 1)))
          (if (and (<= thickness max-thickness)
                   (not (collides-at? entity probe entity.y)))
            (do (set entity.x probe) true)
            false))))))

;; Remet a zero toutes les variables de fragments et de competences debloquees.
;; Appelee au debut d'une nouvelle partie via init-game.
(fn reset-fragments []
  (set fragment-collected false)
  (set dash-fragment-collected false)
  (set fire-fragment-collected false)
  (set stele2-fragment-collected false)
  (set fragment-count 0)
  (set clone-system-unlocked false)
  (set dash-unlocked false)
  (set fire-skill-unlocked false)
  (set ladder-unlocked false)
  (set fireball-cooldown 0)
  (set dash-active-timer 0)
  (set dash-cooldown 0)
  (set dash-dir 1))

;; Collecte le premier fragment de tablette (stele principale).
;; Debloque le systeme de clones et efface le tile de la map.
(fn collect-fragment []
  (when (not fragment-collected)
    (set fragment-collected true)
    (set fragment-count (+ fragment-count 1))
    (set clone-system-unlocked true)
    (mset CUSTOM-TILE-X CUSTOM-TILE-Y 0)
    (sfx 8)))

;; Collecte le fragment qui debloque le dash.
;; Efface le tile de la map et active la competence de dash.
(fn collect-dash-fragment []
  (when (not dash-fragment-collected)
    (set dash-fragment-collected true)
    (set fragment-count (+ fragment-count 1))
    (set dash-unlocked true)
    (mset DASH-FRAGMENT-TILE-X DASH-FRAGMENT-TILE-Y 0)
    (sfx 8)))

;; Collecte le fragment qui debloque le tir de boules de feu.
;; Efface le tile de la map et active la competence fire.
(fn collect-fire-fragment []
  (when (not fire-fragment-collected)
    (set fire-fragment-collected true)
    (set fire-skill-unlocked true)
    (set fragment-count (+ fragment-count 1))
    (mset FIRE-FRAGMENT-TILE-X FIRE-FRAGMENT-TILE-Y 0)
    (sfx 8)))

;; Collecte le fragment de la deuxieme stele qui debloque l'escalade d'echelles.
;; Efface le tile de la map et active la competence echelle.
(fn collect-stele2-fragment []
  (when (not stele2-fragment-collected)
    (set stele2-fragment-collected true)
    (set ladder-unlocked true)
    (set fragment-count (+ fragment-count 1))
    (mset STELE2-FRAGMENT-TILE-X STELE2-FRAGMENT-TILE-Y 0)
    (sfx 8)))

;; Retourne true si le joueur est en contact avec un tile echelle (ID 48).
;; Teste 9 points de la hitbox pour une detection robuste.
(fn entity-on-ladder? [entity]
  (let [w (or entity.w 8)
        h (or entity.h 8)
        x-left (+ entity.x 1)
        x-mid (+ entity.x (// w 2))
        x-right (+ entity.x (- w 2))
        y-top (+ entity.y 1)
        y-mid (+ entity.y (// h 2))
        y-bot (+ entity.y (- h 1))]
    (or (point-ladder? x-left y-top)
        (point-ladder? x-mid y-top)
        (point-ladder? x-right y-top)
        (point-ladder? x-left y-mid)
        (point-ladder? x-mid y-mid)
        (point-ladder? x-right y-mid)
        (point-ladder? x-left y-bot)
        (point-ladder? x-mid y-bot)
        (point-ladder? x-right y-bot))))

;; Verifie chaque frame si le joueur touche un fragment et le collecte.
;; Gere les 4 types de fragments : clone, dash, feu, echelle.
(fn update-fragments []
  (when (and player.alive (not fragment-collected)
             (entity-covers-tile? player CUSTOM-TILE-X CUSTOM-TILE-Y))
    (collect-fragment))
  (when (and player.alive (not dash-fragment-collected)
             (entity-covers-tile? player DASH-FRAGMENT-TILE-X DASH-FRAGMENT-TILE-Y))
    (collect-dash-fragment))
  (when (and player.alive (not fire-fragment-collected)
             (entity-covers-tile? player FIRE-FRAGMENT-TILE-X FIRE-FRAGMENT-TILE-Y))
    (collect-fire-fragment))
  (when (and player.alive (not stele2-fragment-collected)
             (entity-covers-tile? player STELE2-FRAGMENT-TILE-X STELE2-FRAGMENT-TILE-Y))
    (collect-stele2-fragment)))

;; Declenche un dash dans la direction courante du joueur.
;; Determine si le joueur doit traverser un mur (dash long) ou non (dash court).
;; Necessite dash-unlocked et qu'aucun dash ne soit en cours.
(fn start-dash []
  (when (and dash-unlocked player.alive (not spectator-mode)
             (= dash-active-timer 0) (= dash-cooldown 0))
    (set dash-dir (if (= player.dir 0) 1 player.dir))
    (set dash-speed-steps (if (dash-wall-ahead? player dash-dir) 8 6))
    (set dash-active-timer (if (= dash-speed-steps 8) 10 8))
    (set dash-cooldown 24)
    (set player.dir dash-dir)
    (sfx 9)))

;; Execute le deplacement du dash frame par frame.
;; Avance le joueur de dash-speed-steps pixels en traversant les murs fins.
(fn update-dash []
  (when (> dash-active-timer 0)
    (set dash-active-timer (- dash-active-timer 1))
    (var stepped 0)
    (while (< stepped dash-speed-steps)
      (if (dash-step-through-thin-wall player dash-dir)
        (set stepped (+ stepped 1))
        (set stepped dash-speed-steps)))
    (set player.vx (* dash-dir dash-speed-steps))
    (set player.vy 0)
    (set player.on-ground false)))

;; Retourne true si le joueur est actuellement en train de dasher.
(fn player-dashing? []
  (> dash-active-timer 0))

;; Trouve l'entite vivante (joueur ou clone) la plus proche du point (pos-x, pos-y).
;; Utilise la distance au carre pour eviter le sqrt. Retourne nil si aucune entite.
(fn closest-target [pos-x pos-y player-ref clones-ref]
  (var best nil)
  (var best-dist nil)
  (when player-ref.alive
    (let [[px py] (entity-midpoint player-ref)
          d (dist2 pos-x pos-y px py)]
      (set best player-ref)
      (set best-dist d)))
  (each [_ clone (ipairs clones-ref)]
    (when clone.alive
      (let [[cx cy] (entity-midpoint clone)
            d (dist2 pos-x pos-y cx cy)]
        (when (or (= best nil) (< d best-dist))
          (set best clone)
          (set best-dist d)))))
  best)

;; Reinitialise l'entite joueur a la position (x,y) avec toutes les vitesses a zero.
;; La hitbox du joueur est 8x16 pixels (plus haute que large).
(fn reset-player [x y]
  (set player {:x x :y y :vx 0 :vy 0 :on-ground false :dir 1
               :alive true :kind :player :w 8 :h 16}))

;; Reinitialise la trainee visuelle du joueur a sa position actuelle.
;; Remplit tous les segments de la trainee au point pied du joueur.
(fn reset-player-follow []
  (set player-trail [])
  (for [_ 1 FOLLOW-SEGMENTS]
    (table.insert player-trail {:x (+ player.x 4) :y (+ player.y 14)})))

;; Met a jour la liste solid-clones avec les clones immobiles et vivants.
;; Appelee apres chaque changement d'etat des clones pour maintenir les plateformes.
(fn rebuild-solid-clones []
  (set solid-clones [])
  (each [_ clone (ipairs active-clones)]
    (when (and clone.alive clone.immobile)
      (table.insert solid-clones clone))))

;; Instancie les clones actifs depuis les enregistrements de runs precedentes.
;; Chaque clone repart de la position de spawn de sa run originale.
(fn spawn-clones-from-recordings []
  (set active-clones [])
  (each [_ recording (ipairs ghost-recordings)]
    (table.insert active-clones
      {:x recording.start-x :y recording.start-y
       :vx 0 :vy 0 :on-ground false :dir 1
       :alive true :kind :clone :w 8 :h 16
       :frame 1 :inputs recording.inputs :immobile false}))
  (rebuild-solid-clones))

;; Scanne toute la map pour creer les ennemis patrouileurs et tireurs depuis leurs tiles.
;; Instancie egalement les ennemis speciaux (hunter, sentinelles, rollers, flyers, goblins)
;; a leurs positions fixes definies par les constantes globales.
(fn scan-level-traps []
  (set patrollers []) (set shooters []) (set hunters [])
  (set sentries []) (set rollers []) (set flyers []) (set projectiles [])
  (for [ty 0 (- MAP-TILES-H 1)]
    (for [tx 0 (- MAP-TILES-W 1)]
      (let [tile (map-tile tx ty)
            px   (* tx TILE-SIZE)
            py   (* ty TILE-SIZE)]
        (when (fget tile FLAG-PATROLLER)
          (table.insert patrollers
            {:x px :y py :base-x px :vx 0.5 :dir 1
             :patrol-left (- px 24) :patrol-right (+ px 24)
             :detect-radius 48 :alive true}))
        (when (fget tile FLAG-SHOOTER)
          (table.insert shooters
            {:x px :y py :timer 0 :fire-interval 90 :alive true})))))
  (table.insert hunters
    {:x (* HUNTER-START-TX TILE-SIZE) :y (* HUNTER-START-TY TILE-SIZE)
     :vx 0 :vy 0 :on-ground false :dir 1 :alive true
     :active false :armed false :kind :hunter :w 16 :h 16 :reached-stop false})
  (table.insert shooters
    {:x (* GOBLIN2-TX TILE-SIZE) :y (* GOBLIN2-TY TILE-SIZE)
     :timer 0 :fire-interval 90 :alive true :big true :facing-right false :w 16 :h 16})
  (table.insert shooters
    {:x (* SENTRY-TX TILE-SIZE) :y (* SENTRY-TY TILE-SIZE)
     :timer 0 :fire-interval 90 :alive true :big true :facing-right false :w 16 :h 16})
  (table.insert shooters
    {:x (* GOBLIN4-TX TILE-SIZE) :y (* GOBLIN4-TY TILE-SIZE)
     :timer 0 :fire-interval 90 :alive true :big true :facing-right false :w 16 :h 16})
  (table.insert shooters
    {:x (* GOBLIN5-TX TILE-SIZE) :y (* GOBLIN5-TY TILE-SIZE)
     :timer 0 :fire-interval 90 :alive true :big true :facing-right false :w 16 :h 16})
  (table.insert patrollers
    {:x (* GOBLIN3-START-TX TILE-SIZE) :y (* GOBLIN3-TY TILE-SIZE)
     :base-x (* GOBLIN3-START-TX TILE-SIZE) :vx 0.5 :dir 1
     :patrol-left (* GOBLIN3-MIN-TX TILE-SIZE)
     :patrol-right (* GOBLIN3-MAX-TX TILE-SIZE)
     :sprite GOBLIN3-SPRITE
     :detect-radius 48 :alive true})
  (table.insert rollers
    {:x (* ROLLER-START-TX TILE-SIZE) :y (* ROLLER-START-TY TILE-SIZE)
     :vx 0.6 :min-x (* ROLLER-MIN-TX TILE-SIZE) :max-x (* ROLLER-MAX-TX TILE-SIZE) :alive true})
  (table.insert rollers
    {:x (* ROLLER2-START-TX TILE-SIZE) :y (* ROLLER2-START-TY TILE-SIZE)
     :vx 0.6 :min-x (* ROLLER2-MIN-TX TILE-SIZE) :max-x (* ROLLER2-MAX-TX TILE-SIZE) :alive true})
  (table.insert rollers
    {:x (* ROLLER3-START-TX TILE-SIZE) :y (* ROLLER3-START-TY TILE-SIZE)
     :vx 0.6 :min-x (* ROLLER3-MIN-TX TILE-SIZE) :max-x (* ROLLER3-MAX-TX TILE-SIZE)
     :sprite ROLLER3-SPRITE :alive true})
  (table.insert rollers
    {:x (* ROLLER4-START-TX TILE-SIZE) :y (* ROLLER4-START-TY TILE-SIZE)
     :vx 0.6 :min-x (* ROLLER4-MIN-TX TILE-SIZE) :max-x (* ROLLER4-MAX-TX TILE-SIZE)
     :sprite ROLLER4-SPRITE :alive true})
  (table.insert rollers
    {:x (* ROLLER5-START-TX TILE-SIZE) :y (* ROLLER5-START-TY TILE-SIZE)
     :vx 0.6 :min-x (* ROLLER5-MIN-TX TILE-SIZE) :max-x (* ROLLER5-MAX-TX TILE-SIZE)
     :sprite ROLLER5-SPRITE :alive true})
  (table.insert flyers
    {:x (* FLYER-START-TX TILE-SIZE) :y (* FLYER-START-TY TILE-SIZE)
     :vx 0.6 :min-x (* FLYER-MIN-TX TILE-SIZE) :max-x (* FLYER-MAX-TX TILE-SIZE)
     :sprite FLYER-SPRITE :alive true}))

;; Demarre une nouvelle tentative : reinitialise le joueur au dernier checkpoint,
;; vide l'enregistrement courant et instancie les clones depuis les runs precedentes.
(fn start-attempt []
  (set current-recording [])
  (set current-start-x respawn-x)
  (set current-start-y respawn-y)
  (reset-player respawn-x respawn-y)
  (set cam-x (- (+ player.x 4) (/ SCREEN-W 2)))
  (set cam-y (- (+ player.y 4) (/ SCREEN-H 2)))
  (spawn-clones-from-recordings))

;; Initialise une partie complete depuis le debut : reset tous les etats,
;; remet les tiles de la map a leur etat initial et scan les pieges.
(fn init-game []
  (set state.timer 0) (set state.flash 0) (set state.message-timer 0)
  (set state.prev-start false) (set state.prev-choice false)
  (set player-skin-sprite SPR-PLAYER-B)
  (set win-selection 1)
  (set ghost-recordings [])
  (set respawn-x SPAWN-X) (set respawn-y SPAWN-Y)
  (set checkpoint-a-touched false) (set checkpoint-b-touched false)
  (set checkpoint-c-touched false) (set checkpoint-d-touched false)
  (set door-open false) (set door-system-armed false)
  (set flame-sprite 432)
  (set lava-sprite 47)
  (reset-fragments)
  (mset FIXED-TILE-X FIXED-TILE-Y FIXED-TILE-ID)
  (mset FIXED-TILE-X FIXED-TILE-2-Y FIXED-TILE-ID)
  (mset EXTRA-TILE-X EXTRA-TILE-Y EXTRA-TILE-ID)
  (mset EXTRA-TILE-2-X EXTRA-TILE-2-Y EXTRA-TILE-2-ID)
  (mset FIXED-TILE-B-X FIXED-TILE-B-Y FIXED-TILE-ID)
  (mset FIXED-TILE-B-X FIXED-TILE-B-2-Y FIXED-TILE-ID)
  (mset EXTRA-TILE-B-L-X EXTRA-TILE-B-Y EXTRA-TILE-ID)
  (mset EXTRA-TILE-B-R-X EXTRA-TILE-B-Y EXTRA-TILE-2-ID)
  (mset CUSTOM-TILE-X CUSTOM-TILE-Y CUSTOM-TILE-ID)
  (mset DASH-FRAGMENT-TILE-X DASH-FRAGMENT-TILE-Y DASH-FRAGMENT-TILE-ID)
  (mset FIRE-FRAGMENT-TILE-X FIRE-FRAGMENT-TILE-Y FIRE-FRAGMENT-TILE-ID)
  (mset SOLO-BLACK-BLOCK-X SOLO-BLACK-BLOCK-Y SOLO-BLACK-BLOCK-ID)
  (mset (+ SOLO-BLACK-BLOCK-X 1) SOLO-BLACK-BLOCK-Y SOLO-RIGHT-BLOCK-ID)
  (mset (+ SOLO-BLACK-BLOCK-X 1) (- SOLO-BLACK-BLOCK-Y 1) SOLO-RIGHT-BLOCK-ID)
  (mset (+ SOLO-BLACK-BLOCK-X 2) SOLO-BLACK-BLOCK-Y SOLO-RIGHT2-BLOCK-ID)
  (mset STELE2-X STELE2-Y STELE2-BASE-ID)
  (mset (+ STELE2-X 1) STELE2-Y SOLO-RIGHT-BLOCK-ID)
  (mset (+ STELE2-X 1) (- STELE2-Y 1) SOLO-RIGHT-BLOCK-ID)
  (mset (+ STELE2-X 2) STELE2-Y SOLO-RIGHT2-BLOCK-ID)
  (mset STELE2-FRAGMENT-TILE-X STELE2-FRAGMENT-TILE-Y STELE2-FRAGMENT-TILE-ID)
  (set-end-tiles)
  (mset FLAME-TILE-X FLAME-TILE-Y 0)
  (mset FLAME-TILE-B-X FLAME-TILE-B-Y 0)
  (mset FLAME-TILE-D-X FLAME-TILE-D-Y 0)
  (set-door-tiles DOOR-TX DOOR-TY DOOR-CLOSED-TL DOOR-CLOSED-TR DOOR-CLOSED-BL DOOR-CLOSED-BR)
  (set-door-tiles DOOR2-TX DOOR2-TY DOOR-CLOSED-TL DOOR-CLOSED-TR DOOR-CLOSED-BL DOOR-CLOSED-BR)
  (set-door-tiles DOOR3-TX DOOR3-TY DOOR-CLOSED-TL DOOR-CLOSED-TR DOOR-CLOSED-BL DOOR-CLOSED-BR)
  (set-door-tiles DOOR4-TX DOOR4-TY DOOR-CLOSED-TL DOOR-CLOSED-TR DOOR-CLOSED-BL DOOR-CLOSED-BR)
  (scan-level-traps)
  (start-attempt))

;; Gere l'animation de tremblement de l'ecran.
;; Decremente le timer et applique un offset aleatoire tant qu'il reste du shake.
(fn update-screen-shake []
  (when (> shake-timer 0) (set shake-timer (- shake-timer 1)))
  (if (> shake-timer 0)
    (do (set shake-x (math.random -3 3)) (set shake-y (math.random -2 2)))
    (do (set shake-x 0) (set shake-y 0))))

;; Remet le hunter a sa position de spawn initiale et reinitialise tous ses etats.
;; Appelee a la mort du joueur pour que le hunter recommence depuis le debut.
(fn reset-hunters-to-start []
  (each [_ hunter (ipairs hunters)]
    (set hunter.x (* HUNTER-START-TX TILE-SIZE))
    (set hunter.y (* HUNTER-START-TY TILE-SIZE))
    (set hunter.vx 0) (set hunter.vy 0)
    (set hunter.on-ground false) (set hunter.dir 1)
    (set hunter.reached-stop false)
    (set hunter.armed false) (set hunter.active false)))

;; Declenche la mort du joueur : le marque comme mort, reset le hunter,
;; passe en mode :death avec flash rouge et screen shake.
(fn trigger-death []
  (when player.alive
    (set player.alive false)
    (reset-hunters-to-start)
    (set state.mode :death)
    (set state.timer 0) (set state.flash 10) (set state.flash-color 2)
    (set shake-timer 20) (play-death-sound)))

;; Met a jour les rouleaux (rollers) : deplacement horizontal aller-retour.
;; Tue le joueur ou les clones en cas de collision.
(fn update-rollers []
  (each [_ roller (ipairs rollers)]
    (when roller.alive
      (set roller.x (+ roller.x roller.vx))
      (when (<= roller.x roller.min-x)
        (set roller.x roller.min-x) (set roller.vx 0.6))
      (when (>= roller.x roller.max-x)
        (set roller.x roller.max-x) (set roller.vx -0.6))
      (when (and player.alive
                 (aabb-overlap roller.x roller.y 8 8 player.x player.y (or player.w 8) (or player.h 8)))
        (trigger-death))
      (each [_ clone (ipairs active-clones)]
        (when (and clone.alive
                   (aabb-overlap roller.x roller.y 8 8 clone.x clone.y (or clone.w 8) (or clone.h 8)))
          (kill-clone clone))))))

;; Met a jour les ennemis volants (flyers) : deplacement horizontal aller-retour.
;; Meme comportement que les rollers mais positionnement en l'air dans la map.
(fn update-flyers []
  (each [_ flyer (ipairs flyers)]
    (when flyer.alive
      (set flyer.x (+ flyer.x flyer.vx))
      (when (<= flyer.x flyer.min-x)
        (set flyer.x flyer.min-x) (set flyer.vx 0.6))
      (when (>= flyer.x flyer.max-x)
        (set flyer.x flyer.max-x) (set flyer.vx -0.6))
      (when (and player.alive
                 (aabb-overlap flyer.x flyer.y 8 8 player.x player.y (or player.w 8) (or player.h 8)))
        (trigger-death))
      (each [_ clone (ipairs active-clones)]
        (when (and clone.alive
                   (aabb-overlap flyer.x flyer.y 8 8 clone.x clone.y (or clone.w 8) (or clone.h 8)))
          (kill-clone clone))))))

;; Enregistre la run courante comme nouveau fantome si la limite n'est pas atteinte.
;; Stocke les inputs, le x et y de depart pour pouvoir rejouer la run plus tard.
(fn save-current-run-as-clone []
  (when (< (list-length ghost-recordings) MAX-CLONES)
    (table.insert ghost-recordings
      {:inputs current-recording
       :start-x current-start-x :start-y current-start-y})
    (play-clone-sound)))

;; Declenche l'etat de victoire : flash vert, son de victoire, timer pour l'ecran.
(fn finish-level []
  (set state.mode :win) (set state.timer 0)
  (set win-selection 1)
  (set state.message-timer 45) (set state.flash 6)
  (set state.flash-color 12) (play-win-sound))

;; Retourne true si le joueur couvre au moins une tuile de "status" (ID 174).
(global player-on-end-structure?
  (fn []
    (let [w (or player.w 8)
          h (or player.h 8)
          left (// player.x TILE-SIZE)
          right (// (+ player.x (- w 1)) TILE-SIZE)
          top (// player.y TILE-SIZE)
          bottom (// (+ player.y (- h 1)) TILE-SIZE)]
      (var found false)
      (for [ty top bottom]
        (for [tx left right]
          (when (= (map-tile tx ty) 174)
            (set found true))))
      found)))

;; Interaction de fin : touche K sur la structure pour changer de skin et finir le niveau.
(global update-end-structure-interaction
  (fn []
    (when (and player.alive (keyp 11) (player-on-end-structure?))
      (set player-skin-sprite 450)
      (finish-level))))

;; Met a jour le point de respawn du joueur si il change de checkpoint.
;; Joue un son si c'est un nouveau checkpoint.
(fn set-checkpoint [tx ty]
  (let [new-x (* tx TILE-SIZE) new-y (* ty TILE-SIZE)]
    (when (or (not= respawn-x new-x) (not= respawn-y new-y))
      (set respawn-x new-x) (set respawn-y new-y) (sfx 5))))

;; Ecrit les 4 tiles d'une porte 2x2 dans la map a la position (tx,ty).
;; Utilise pour ouvrir ou fermer une porte en changeant ses 4 tiles.
(global set-door-tiles
  (fn [tx ty tl tr bl br]
    (mset tx ty tl) (mset (+ tx 1) ty tr)
    (mset tx (+ ty 1) bl) (mset (+ tx 1) (+ ty 1) br)))

;; Ecrit le bloc decoratif de fin de niveau dans la map.
;; Organise les tiles en 3 colonnes et 4 rangees, du haut vers le bas.
(global set-end-tiles
  (fn []
    (mset END-FINISH-X-LEFT END-FINISH-Y-BOTTOM 193)
    (mset END-FINISH-X-MID END-FINISH-Y-BOTTOM 193)
    (mset END-FINISH-X-RIGHT END-FINISH-Y-BOTTOM 193)
    (mset END-FINISH-X-LEFT END-FINISH-Y-ROW3 176)
    (mset END-FINISH-X-MID END-FINISH-Y-ROW3 177)
    (mset END-FINISH-X-RIGHT END-FINISH-Y-ROW3 178)
    (mset END-FINISH-X-LEFT END-FINISH-Y-ROW2 160)
    (mset END-FINISH-X-MID END-FINISH-Y-ROW2 161)
    (mset END-FINISH-X-RIGHT END-FINISH-Y-ROW2 162)
    (mset END-FINISH-X-LEFT END-FINISH-Y-TOP 144)
    (mset END-FINISH-X-MID END-FINISH-Y-TOP 145)
    (mset END-FINISH-X-RIGHT END-FINISH-Y-TOP 146)))

;; Teleporte instantanement le joueur a la position de la porte principale.
;; Utilisee par le systeme de teleportation inter-portes (touche B).
(global teleport-player-to-spawn-door
  (fn []
    (set player.x (* DOOR-TX TILE-SIZE))
    (set player.y (- (* DOOR-TY TILE-SIZE) 16))
    (set player.vx 0) (set player.vy 0)
    (set player.on-ground false) (set player.dir 1)
    (set cam-x (- (+ player.x 4) (/ SCREEN-W 2)))
    (set cam-y (- (+ player.y 4) (/ SCREEN-H 2)))
    (sfx 10)))

;; Retourne true si le point de respawn actuel correspond au checkpoint (tx,ty).
;; Utilise pour afficher le bon sprite de checkpoint (actif ou inactif).
(fn checkpoint-active? [tx ty]
  (and (= respawn-x (* tx TILE-SIZE)) (= respawn-y (* ty TILE-SIZE))))

;; Retourne true si le joueur est assez proche d'un checkpoint.
;; Evite les ratés quand la hitbox ne recouvre pas exactement la tuile du checkpoint.
(fn player-near-checkpoint? [tx ty]
  (let [foot-x (+ player.x 4)
        foot-y (+ player.y (- (or player.h 16) 1))
        ftx (// foot-x TILE-SIZE)
        fty (// foot-y TILE-SIZE)]
    (and (>= ftx (- tx 1)) (<= ftx (+ tx 1))
         (>= fty (- ty 1)) (<= fty (+ ty 1)))))

;; Retourne les coordonnees tile [mx my] du centre de l'entite.
;; Utilise pour la detection de checkpoints avec une tolerance d'un tile.
(fn entity-midpoint-tile [entity]
  (let [w (or entity.w 8) h (or entity.h 8)]
    [(// (+ entity.x (/ w 2)) TILE-SIZE)
     (// (+ entity.y (/ h 2)) TILE-SIZE)]))

;; Verifie si le joueur touche un des 4 checkpoints et met a jour le respawn.
;; Un checkpoint touche est marque comme visited pour eviter de cacher le checkpoint B.
(fn update-checkpoint []
  (when player.alive
    (let [on-a (or (entity-covers-tile? player CHECKPOINT-A-TX CHECKPOINT-A-TY)
                   (player-near-checkpoint? CHECKPOINT-A-TX CHECKPOINT-A-TY))
          on-b (or (entity-covers-tile? player CHECKPOINT-B-TX CHECKPOINT-B-TY)
                   (player-near-checkpoint? CHECKPOINT-B-TX CHECKPOINT-B-TY))
          on-c (or (entity-covers-tile? player CHECKPOINT-C-TX CHECKPOINT-C-TY)
                   (player-near-checkpoint? CHECKPOINT-C-TX CHECKPOINT-C-TY))
          on-d (or (entity-covers-tile? player CHECKPOINT-D-TX CHECKPOINT-D-TY)
                   (player-near-checkpoint? CHECKPOINT-D-TX CHECKPOINT-D-TY))]
      (when on-a (set checkpoint-a-touched true)
        (set-checkpoint CHECKPOINT-A-TX CHECKPOINT-A-TY))
      (when on-b (set checkpoint-b-touched true)
        (set-checkpoint CHECKPOINT-B-TX CHECKPOINT-B-TY))
      (when on-c
        (set checkpoint-c-touched true)
        (set-checkpoint CHECKPOINT-C-TX CHECKPOINT-C-TY))
      (when on-d
        (set checkpoint-d-touched true)
        (set-checkpoint CHECKPOINT-D-TX CHECKPOINT-D-TY)))))

;; Gere l'ouverture et fermeture de toutes les portes selon la proximite du joueur.
(fn update-door []
  (let [near-door (and player.alive
    (or
      (entity-covers-tile? player (- DOOR-TX 1) DOOR-TY)
      (entity-covers-tile? player DOOR-TX DOOR-TY)
      (entity-covers-tile? player (+ DOOR-TX 1) DOOR-TY)
      (entity-covers-tile? player (+ DOOR-TX 2) DOOR-TY)
      (entity-covers-tile? player (- DOOR-TX 1) (+ DOOR-TY 1))
      (entity-covers-tile? player DOOR-TX (+ DOOR-TY 1))
      (entity-covers-tile? player (+ DOOR-TX 1) (+ DOOR-TY 1))
      (entity-covers-tile? player (+ DOOR-TX 2) (+ DOOR-TY 1))
      (entity-covers-tile? player (- DOOR2-TX 1) DOOR2-TY)
      (entity-covers-tile? player DOOR2-TX DOOR2-TY)
      (entity-covers-tile? player (+ DOOR2-TX 1) DOOR2-TY)
      (entity-covers-tile? player (+ DOOR2-TX 2) DOOR2-TY)
      (entity-covers-tile? player (- DOOR2-TX 1) (+ DOOR2-TY 1))
      (entity-covers-tile? player DOOR2-TX (+ DOOR2-TY 1))
      (entity-covers-tile? player (+ DOOR2-TX 1) (+ DOOR2-TY 1))
      (entity-covers-tile? player (+ DOOR2-TX 2) (+ DOOR2-TY 1))
      (entity-covers-tile? player (- DOOR3-TX 1) DOOR3-TY)
      (entity-covers-tile? player DOOR3-TX DOOR3-TY)
      (entity-covers-tile? player (+ DOOR3-TX 1) DOOR3-TY)
      (entity-covers-tile? player (+ DOOR3-TX 2) DOOR3-TY)
      (entity-covers-tile? player (- DOOR3-TX 1) (+ DOOR3-TY 1))
      (entity-covers-tile? player DOOR3-TX (+ DOOR3-TY 1))
      (entity-covers-tile? player (+ DOOR3-TX 1) (+ DOOR3-TY 1))
      (entity-covers-tile? player (+ DOOR3-TX 2) (+ DOOR3-TY 1))
      (entity-covers-tile? player (- DOOR4-TX 1) DOOR4-TY)
      (entity-covers-tile? player DOOR4-TX DOOR4-TY)
      (entity-covers-tile? player (+ DOOR4-TX 1) DOOR4-TY)
      (entity-covers-tile? player (+ DOOR4-TX 2) DOOR4-TY)
      (entity-covers-tile? player (- DOOR4-TX 1) (+ DOOR4-TY 1))
      (entity-covers-tile? player DOOR4-TX (+ DOOR4-TY 1))
      (entity-covers-tile? player (+ DOOR4-TX 1) (+ DOOR4-TY 1))
      (entity-covers-tile? player (+ DOOR4-TX 2) (+ DOOR4-TY 1))))]
    (when (and (not door-system-armed) (not near-door))
      (set door-system-armed true))
    (when door-system-armed
      (when (and near-door (not door-open))
        (set door-open true)
        (set-door-tiles DOOR-TX DOOR-TY DOOR-OPEN-TL DOOR-OPEN-TR DOOR-OPEN-BL DOOR-OPEN-BR)
        (set-door-tiles DOOR2-TX DOOR2-TY DOOR-OPEN-TL DOOR-OPEN-TR DOOR-OPEN-BL DOOR-OPEN-BR)
        (set-door-tiles DOOR3-TX DOOR3-TY DOOR-OPEN-TL DOOR-OPEN-TR DOOR-OPEN-BL DOOR-OPEN-BR)
        (set-door-tiles DOOR4-TX DOOR4-TY DOOR-OPEN-TL DOOR-OPEN-TR DOOR-OPEN-BL DOOR-OPEN-BR)
        (sfx 10))
      (when (and (not near-door) door-open)
        (set door-open false)
        (set-door-tiles DOOR-TX DOOR-TY DOOR-CLOSED-TL DOOR-CLOSED-TR DOOR-CLOSED-BL DOOR-CLOSED-BR)
        (set-door-tiles DOOR2-TX DOOR2-TY DOOR-CLOSED-TL DOOR-CLOSED-TR DOOR-CLOSED-BL DOOR-CLOSED-BR)
        (set-door-tiles DOOR3-TX DOOR3-TY DOOR-CLOSED-TL DOOR-CLOSED-TR DOOR-CLOSED-BL DOOR-CLOSED-BR)
        (set-door-tiles DOOR4-TX DOOR4-TY DOOR-CLOSED-TL DOOR-CLOSED-TR DOOR-CLOSED-BL DOOR-CLOSED-BR)))))

;; Teleporte le joueur vers la porte principale si il appuie sur B (keyp 11)
;; en etant pres d'une porte secondaire (DOOR2, DOOR3 ou DOOR4).
(fn update-door-teleport []
  (when (and player.alive (keyp 11)
    (or
      (entity-covers-tile? player DOOR2-TX DOOR2-TY)
      (entity-covers-tile? player (+ DOOR2-TX 1) DOOR2-TY)
      (entity-covers-tile? player DOOR2-TX (+ DOOR2-TY 1))
      (entity-covers-tile? player (+ DOOR2-TX 1) (+ DOOR2-TY 1))
      (entity-covers-tile? player DOOR3-TX DOOR3-TY)
      (entity-covers-tile? player (+ DOOR3-TX 1) DOOR3-TY)
      (entity-covers-tile? player DOOR3-TX (+ DOOR3-TY 1))
      (entity-covers-tile? player (+ DOOR3-TX 1) (+ DOOR3-TY 1))
      (entity-covers-tile? player DOOR4-TX DOOR4-TY)
      (entity-covers-tile? player (+ DOOR4-TX 1) DOOR4-TY)
      (entity-covers-tile? player DOOR4-TX (+ DOOR4-TY 1))
      (entity-covers-tile? player (+ DOOR4-TX 1) (+ DOOR4-TY 1))))
    (teleport-player-to-spawn-door)))

;; Deplace le joueur en mode spectateur libre (sans physique ni collision).
(fn update-spectator-player [entity input-left input-right input-up input-down]
  (let [w (or entity.w 8) h (or entity.h 8)
        max-x (- (* MAP-TILES-W TILE-SIZE) w)
        max-y (- (* MAP-TILES-H TILE-SIZE) h)
        dx (+ (if input-right SPECTATOR-SPEED 0)
              (if input-left (- 0 SPECTATOR-SPEED) 0))
        dy (+ (if input-down SPECTATOR-SPEED 0)
              (if input-up (- 0 SPECTATOR-SPEED) 0))]
    (set entity.x (clamp (+ entity.x dx) 0 max-x))
    (set entity.y (clamp (+ entity.y dy) 0 max-y))
    (set entity.vx 0) (set entity.vy 0) (set entity.on-ground false)))

;; Anime les flammes decoratives en cyclant entre 3 frames (432, 433, 434).
(fn update-flame-animation []
  (let [phase (% (// state.timer 8) 3)
        frame (if (= phase 0) 432 (if (= phase 1) 433 434))]
    (set flame-sprite frame))
  (set lava-sprite (if (= (% (// state.timer 15) 2) 0) 47 159)))

;; Physique universelle partagee entre le joueur et les clones.
(fn update-entity [entity input-left input-right input-jump input-down]
  (when entity.alive
    (if input-left
      (do (set entity.vx (- 0 WALK-SPEED)) (set entity.dir -1))
      (if input-right
        (do (set entity.vx WALK-SPEED) (set entity.dir 1))
        (set entity.vx 0)))
    (let [climb-up input-jump
          climb-down input-down
          climbing? (and (= entity.kind :player)
                         ladder-unlocked
                         (or climb-up climb-down)
                         (entity-on-ladder? entity))]
      (if climbing?
        (do
          (set entity.on-ground false)
          (set entity.vy (if climb-up -1.2 (if climb-down 1.2 0))))
        (do
          (when (and input-jump entity.on-ground)
            (set entity.vy JUMP-FORCE)
            (when (= entity.kind :player) (play-jump-sound)))
          (set entity.vy (clamp (+ entity.vy GRAVITY) -8 MAX-FALL))
          (set entity.on-ground false))))
    (let [nx (+ entity.x entity.vx)
          w (or entity.w 8)
          max-x (- (* MAP-TILES-W TILE-SIZE) w)]
      (if (< nx 0) (set entity.x max-x)
        (if (> nx max-x) (set entity.x 0)
          (if (collides-at? entity nx  entity.y)
            (do
              (when (> entity.vx 0)
                (while (not (collides-at? entity (+ entity.x 1) entity.y))
                  (set entity.x (+ entity.x 1))))
              (when (< entity.vx 0)
                (while (not (collides-at? entity (- entity.x 1) entity.y))
                  (set entity.x (- entity.x 1))))
              (set entity.vx 0))
            (set entity.x nx)))))
    (let [ny (+ entity.y entity.vy)]
      (if (collides-at? entity entity.x ny)
        (do
          (when (> entity.vy 0)
            (while (not (collides-at? entity entity.x (+ entity.y 1)))
              (set entity.y (+ entity.y 1)))
            (set entity.on-ground true))
          (when (< entity.vy 0)
            (while (not (collides-at? entity entity.x (- entity.y 1)))
              (set entity.y (- entity.y 1))))
          (set entity.vy 0))
        (set entity.y ny)))
    (when (>= entity.y (* MAP-TILES-H TILE-SIZE))
      (set entity.y 0) (set entity.vy 0) (set entity.on-ground false))))

;; Supprime de la liste projectiles tous les projectiles morts (alive=false).
(fn remove-dead-projectiles []
  (var kept [])
  (each [_ p (ipairs projectiles)] (when p.alive (table.insert kept p)))
  (set projectiles kept))

;; Ignore toute tentative de tuer un clone (clones immortels dans ce jeu).
(global kill-clone
  (fn [clone]
    (when clone
      (set clone.alive false)
      (set clone.immobile false))))

;; Met a jour un clone pour une frame : lit son input enregistre, applique la physique.
(fn update-clone [clone]
  (when clone.alive
    (if (<= clone.frame (list-length clone.inputs))
      (let [mask (. clone.inputs clone.frame)
            [left right jump] (decode-bitmask mask)]
        (update-entity clone left right jump)
        (set clone.frame (+ clone.frame 1))
        (set clone.immobile (and (= clone.vx 0) (= clone.vy 0))))
      (do (set clone.vx 0) (set clone.vy 0) (set clone.immobile true)))))

;; Met a jour tous les clones actifs puis reconstruit la liste des plateformes solides.
(fn update-clones []
  (each [_ clone (ipairs active-clones)] (update-clone clone))
  (rebuild-solid-clones))

;; Verifie si le joueur ou un clone est sur un tile mortel et declenche la mort.
(fn update-deadly-zones []
  (when (and player.alive (entity-on-deadly-tile? player)) (trigger-death))
  (each [_ clone (ipairs active-clones)]
    (when (and clone.alive (entity-on-deadly-tile? clone)) (kill-clone clone)))
  (rebuild-solid-clones))

;; Met a jour les ennemis patrouilleurs.
(fn update-patrollers []
  (each [_ p (ipairs patrollers)]
    (when p.alive
      (let [target (closest-target (+ p.x 4) (+ p.y 4) player active-clones)
            speed 0.5]
        (if target
          (let [[tx ty] (entity-midpoint target)
                chase? (< (math.sqrt (dist2 (+ p.x 4) (+ p.y 4) tx ty)) p.detect-radius)
                cs (if chase? 1.5 speed)]
            (set p.dir (if (< tx (+ p.x 4)) -1 1))
            (set p.vx (* p.dir cs)))
          (set p.vx (* p.dir speed))))
      (set p.x (+ p.x p.vx))
      (when (<= p.x p.patrol-left) (set p.x p.patrol-left) (set p.dir 1))
      (when (>= p.x p.patrol-right) (set p.x p.patrol-right) (set p.dir -1))
      (when (and player.alive
                 (aabb-overlap p.x p.y 8 8 player.x player.y (or player.w 8) (or player.h 8)))
        (trigger-death))
      (each [_ clone (ipairs active-clones)]
        (when (and clone.alive
                   (aabb-overlap p.x p.y 8 8 clone.x clone.y (or clone.w 8) (or clone.h 8)))
          (kill-clone clone)))))
  (rebuild-solid-clones))

;; Retourne true si un obstacle solide se trouve devant le hunter dans la direction dir.
(fn hunter-obstacle-ahead? [hunter dir]
  (let [probe-x (+ hunter.x (* dir 2))]
    (or (collides-at? hunter probe-x hunter.y)
        (collides-at? hunter probe-x (- hunter.y 1)))))

;; Retourne true s'il y a un vide devant le hunter dans la direction dir.
(fn hunter-gap-ahead? [hunter dir]
  (let [front-x (if (> dir 0) (+ hunter.x 16) (- hunter.x 1))
        foot-y (+ hunter.y 17)]
    (not (point-solid? front-x foot-y))))

;; Met a jour le hunter (boss pourchasseur).
(fn update-hunters []
  (each [_ hunter (ipairs hunters)]
    (when hunter.alive
      (if (not hunter.active)
        (let [on-spawn-case (and player.alive
                                 (or
                                   (entity-covers-tile? player HUNTER-START-TX HUNTER-START-TY)
                                   (entity-covers-tile? player (+ HUNTER-START-TX 1) HUNTER-START-TY)
                                   (entity-covers-tile? player HUNTER-START-TX (+ HUNTER-START-TY 1))
                                   (entity-covers-tile? player (+ HUNTER-START-TX 1) (+ HUNTER-START-TY 1))))]
          (when on-spawn-case (set hunter.armed true))
          (when (and hunter.armed (not on-spawn-case))
            (set hunter.active true)))
        (let [center-x (+ hunter.x 8) center-y (+ hunter.y 8)
              [target-x target-y] (if player.alive
                                    (entity-midpoint player)
                                    [center-x center-y])
              move-left (< target-x (- center-x 2))
              move-right (> target-x (+ center-x 2))
              dir (if move-left -1 (if move-right 1 hunter.dir))
              jump-needed (and hunter.on-ground
                               (or (hunter-obstacle-ahead? hunter dir)
                                   (hunter-gap-ahead? hunter dir)
                                   (< target-y (- center-y 10))))]
          (set hunter.dir dir)
          (update-entity hunter (= dir -1) (= dir 1) jump-needed)
          (when (and player.alive
                     (aabb-overlap hunter.x hunter.y 16 16 player.x player.y (or player.w 8) (or player.h 8)))
            (trigger-death)))))))

;; Met a jour l'orientation des sentinelles vers le joueur.
(fn update-sentries []
  (each [_ sentry (ipairs sentries)]
    (when sentry.alive
      (let [sx (+ sentry.x 8)
            [px _] (if player.alive (entity-midpoint player) [sx 0])]
        (set sentry.facing-right (> px sx))))))

;; Cree une flamme d'impact a la position (x,y) avec un timer de 120 frames.
(fn spawn-impact-flame [x y]
  (table.insert impact-flames {:x x :y y :timer 120})
  (when (> (list-length impact-flames) 24)
    (table.remove impact-flames 1)))

;; Cree un projectile a (x,y) avec une velocite (vx,vy) et des options.
(fn spawn-projectile [x y vx vy opts]
  (table.insert projectiles
    {:x x :y y :vx vx :vy vy :alive true
     :sprite (or (and opts opts.sprite) SPR-PROJECTILE)
     :leave-flame (or (and opts opts.leave-flame) false)
     :owner (or (and opts opts.owner) :enemy)
     :anim-sprites (and opts opts.anim-sprites)
     :anim-index 1
     :anim-step (or (and opts opts.anim-step) 3)
     :anim-timer 0}))

;; Tire une boule de feu animee depuis le joueur dans sa direction courante.
(fn shoot-player-fireball []
  (when (and fire-skill-unlocked player.alive
             (not spectator-mode)
             (= dash-active-timer 0)
             (= fireball-cooldown 0))
    (let [dir (if (= player.dir 0) 1 player.dir)
          start-x (if (> dir 0) (+ player.x 10) (- player.x 6))
          start-y (+ player.y 7)]
      (spawn-projectile start-x start-y (* dir 2.2) 0
        {:sprite FIREBALL-SPR-A :leave-flame true :owner :player
         :anim-sprites [FIREBALL-SPR-A FIREBALL-SPR-B] :anim-step 2})
      (set fireball-cooldown 10) (sfx 4))))

;; Met a jour tous les tireurs (shooters).
(fn update-shooters []
  (each [_ s (ipairs shooters)]
    (when s.alive
      (set s.timer (+ s.timer 1))
      (when (>= s.timer s.fire-interval)
        (let [cx (if s.big (+ s.x 8) (+ s.x 4))
              cy (if s.big (+ s.y 8) (+ s.y 4))
              target (closest-target cx cy player active-clones)]
          (when target
            (let [[tx ty] (entity-midpoint target)
                  dx (- tx cx) dy (- ty cy)
                  mag (math.max 1 (math.sqrt (+ (* dx dx) (* dy dy))))
                  speed 1.7]
              (when s.big (set s.facing-right (> dx 0)))
              (spawn-projectile (if s.big cx (+ s.x 4))
                (if (> dy 0) (if s.big (+ s.y 14) (+ s.y 12)) (+ s.y 2))
                (* (/ dx mag) speed) (* (/ dy mag) speed)
                {:sprite SPR-GOBLIN-FIRE :leave-flame true :owner :enemy})
              (sfx 4))))
        (set s.timer 0)))))

;; Met a jour tous les projectiles : animation, deplacement, collisions.
(fn update-projectiles []
  (each [_ p (ipairs projectiles)]
    (when p.alive
      (when p.anim-sprites
        (set p.anim-timer (+ p.anim-timer 1))
        (when (= (% p.anim-timer p.anim-step) 0)
          (set p.anim-index (+ p.anim-index 1))
          (when (> p.anim-index (length p.anim-sprites)) (set p.anim-index 1))
          (set p.sprite (. p.anim-sprites p.anim-index))))
      (set p.x (+ p.x p.vx)) (set p.y (+ p.y p.vy))
      (let [hit-solid (point-solid? p.x p.y)
            out-map (or (< p.x 0) (< p.y 0)
                        (> p.x (* MAP-TILES-W TILE-SIZE))
                        (> p.y (* MAP-TILES-H TILE-SIZE)))]
        (when (or hit-solid out-map)
          (when (and p.leave-flame hit-solid)
            (let [fx (* (// p.x TILE-SIZE) TILE-SIZE)
                  fy (math.max 0 (+ (* (// p.y TILE-SIZE) TILE-SIZE) TILE-SIZE))]
              (spawn-impact-flame fx fy)))
          (set p.alive false))
        (when (and p.alive (not= p.owner :player) player.alive
                   (aabb-overlap p.x p.y 4 4 player.x player.y (or player.w 8) (or player.h 8)))
          (set p.alive false) (trigger-death))
        (each [_ clone (ipairs active-clones)]
          (when (and p.alive (not= p.owner :player) clone.alive
                     (aabb-overlap p.x p.y 4 4 clone.x clone.y (or clone.w 8) (or clone.h 8)))
            (set p.alive false) (kill-clone clone)))
        (each [_ pat (ipairs patrollers)]
          (when (and p.alive (= p.owner :player) pat.alive
                     (aabb-overlap p.x p.y 4 4 pat.x pat.y 8 8))
            (set p.alive false) (set pat.alive false)))
        (each [_ shooter (ipairs shooters)]
          (when (and p.alive (= p.owner :player) shooter.alive
                     (aabb-overlap p.x p.y 4 4 shooter.x shooter.y (or shooter.w 8) (or shooter.h 8)))
            (set p.alive false) (set shooter.alive false)))
        (each [_ hunter (ipairs hunters)]
          (when (and p.alive (= p.owner :player) hunter.alive
                     (aabb-overlap p.x p.y 4 4 hunter.x hunter.y 16 16))
            (set p.alive false) (set hunter.alive false))))))
  (remove-dead-projectiles) (rebuild-solid-clones))

;; Met a jour les flammes d'impact.
(fn update-impact-flames []
  (var kept [])
  (each [_ f (ipairs impact-flames)]
    (set f.timer (- f.timer 1))
    (when (and player.alive
               (aabb-overlap f.x f.y 8 8 player.x player.y (or player.w 8) (or player.h 8)))
      (trigger-death))
    (when (> f.timer 0) (table.insert kept f)))
  (set impact-flames kept))

;; Met a jour la trainee visuelle qui suit le joueur.
(fn update-player-trail []
  (when (= (length player-trail) 0) (reset-player-follow))
  (let [head-x (+ player.x 4) head-y (+ player.y 14)]
    (each [i seg (ipairs player-trail)]
      (let [prev (if (> i 1) (. player-trail (- i 1)) nil)
            tx (if prev prev.x head-x) ty (if prev prev.y head-y)]
        (set seg.x (+ seg.x (* (- tx seg.x) FOLLOW-LERP)))
        (set seg.y (+ seg.y (* (- ty seg.y) FOLLOW-LERP)))))))

;; Initialise le champ d'etoiles du menu.
(fn init-stars []
  (set stars [])
  (for [_ 1 80]
    (table.insert stars {:x (math.random 0 239) :y (math.random 0 135)
      :speed (/ (math.random 1 3) 10) :color (. [7 8 8 13] (math.random 1 4))}))
  (for [_ 1 30]
    (table.insert stars {:x (math.random 0 239) :y (math.random 0 135)
      :speed (/ (math.random 4 7) 10) :color (. [13 14 15] (math.random 1 3))}))
  (for [_ 1 10]
    (table.insert stars {:x (math.random 0 239) :y (math.random 0 135)
      :speed (/ (math.random 8 12) 10) :color 15})))

;; Anime et dessine les etoiles du fond.
(fn animate-stars []
  (each [_ star (ipairs stars)]
    (set star.x (+ star.x star.speed))
    (when (> star.x 239) (set star.x 0) (set star.y (math.random 0 135)))
    (pix star.x star.y star.color)))

;; Dessine le soleil noir anime du menu.
(fn draw-black-sun []
  (let [radius (+ 12 (* 2 (math.sin (* title-time 0.8)))) cx 120 cy 28]
    (circb cx cy (+ radius 5) 2) (circb cx cy (+ radius 3) 1)
    (circ cx cy radius 0) (circb cx cy radius 9)
    (for [i 0 7]
      (let [angle (* i (/ (* 2 3.14159) 8))
            rx1 (* (+ radius 2) (math.cos angle)) ry1 (* (+ radius 2) (math.sin angle))
            rx2 (* (+ radius 7) (math.cos angle)) ry2 (* (+ radius 7) (math.sin angle))]
        (line (+ cx rx1) (+ cy ry1) (+ cx rx2) (+ cy ry2) 9)))))

;; Dessine le titre du jeu.
(fn draw-title-card []
  (print "Echo Clone" 62 22 0 0 0 false 2)
  (let [offset (* (math.sin title-time) 2)]
    (print "Echo Clone" 61 (+ 50 offset) 9 0 0 false 2))
  (let [subtitle "Echo Clone"
        sw (* (string.len subtitle) 6)
        sx (- (/ SCREEN-W 2) (/ sw 2))]
    (print subtitle sx 46 13)))

;; Dessine les ailes pixel-art du joueur si l'option est activee.
(fn draw-player-wings [sx sy]
  (when show-player-wings
    (let [flap (* (math.sin (* title-time 7)) 1.2)
          ltx (- sx 5 flap) rtx (+ sx 21 flap)
          top-y (+ sy 6 flap) mid-y (+ sy 10)
          bl (+ sx 3) br (+ sx 13)]
      (line bl (+ sy 7) ltx top-y 13) (line bl (+ sy 9) (- ltx 1) (+ mid-y 1) 12)
      (line bl (+ sy 11) (+ ltx 1) (+ mid-y 3) 6) (circ ltx (+ sy 10) 1 12)
      (line br (+ sy 7) rtx top-y 13) (line br (+ sy 9) (+ rtx 1) (+ mid-y 1) 12)
      (line br (+ sy 11) (- rtx 1) (+ mid-y 3) 6) (circ rtx (+ sy 10) 1 12))))

;; Dessine le sprite joueur.
(fn draw-player []
  (when player.alive
    (let [sx (+ (- player.x cam-x 4) shake-x)
          sy (+ (- player.y cam-y) shake-y)]
      (draw-player-wings sx sy)
  (spr (if spectator-mode SPR-CLONE-A player-skin-sprite)
           sx sy 0 1 (if (< player.dir 0) 1 0) 0 2 2))))

;; Dessine la trainee visuelle coloree qui suit le joueur.
(fn draw-player-follow []
  (let [colors [14 13 12 6 5]]
    (each [i seg (ipairs player-trail)]
      (when (> i 1)
        (let [prev (. player-trail (- i 1))
              c (. colors (+ 1 (% i (length colors))))]
          (line (+ (- prev.x cam-x) shake-x) (+ (- prev.y cam-y) shake-y)
                (+ (- seg.x cam-x) shake-x) (+ (- seg.y cam-y) shake-y) c))))
    (each [i seg (ipairs player-trail)]
      (let [c (. colors (+ 1 (% i (length colors)))) r (if (< i 3) 2 1)]
        (circ (+ (- seg.x cam-x) shake-x) (+ (- seg.y cam-y) shake-y) r c)))))

;; Dessine tous les clones actifs.
(fn draw-clones []
  (each [_ clone (ipairs active-clones)]
    (when clone.alive
      (spr SPR-CLONE-A
        (+ (- clone.x cam-x 4) shake-x)
        (+ (- clone.y cam-y) shake-y)
        0 1 (if (< clone.dir 0) 1 0) 0 2 2))))

;; Dessine tous les ennemis et projectiles.
(fn draw-traps []
  (each [_ p (ipairs patrollers)]
    (spr (or p.sprite SPR-PATROLLER) (+ (- p.x cam-x) shake-x) (+ (- p.y cam-y) shake-y)
         0 1 (if (< p.dir 0) 1 0)))
  (each [_ s (ipairs shooters)]
    (if s.big
      (let [sx (+ (- s.x cam-x) shake-x) sy (+ (- s.y cam-y) shake-y)
            tl (if s.facing-right SENTRY-R-TL SENTRY-L-TL)
            tr (if s.facing-right SENTRY-R-TR SENTRY-L-TR)
            bl (if s.facing-right SENTRY-R-BL SENTRY-L-BL)
            br (if s.facing-right SENTRY-R-BR SENTRY-L-BR)]
        (spr tl sx sy 0) (spr tr (+ sx 8) sy 0)
        (spr bl sx (+ sy 8) 0) (spr br (+ sx 8) (+ sy 8) 0))
      (spr SPR-SHOOTER (+ (- s.x cam-x) shake-x) (+ (- s.y cam-y) shake-y) 0)))
  (each [_ hunter (ipairs hunters)]
    (when (and hunter.alive hunter.active)
      (let [hx (+ (- hunter.x cam-x) shake-x) hy (+ (- hunter.y cam-y) shake-y)]
        (spr SPR-HUNTER-TL hx hy 0) (spr SPR-HUNTER-TR (+ hx 8) hy 0)
        (spr SPR-HUNTER-BL hx (+ hy 8) 0) (spr SPR-HUNTER-BR (+ hx 8) (+ hy 8) 0))))
  (each [_ sentry (ipairs sentries)]
    (when sentry.alive
      (let [sx (+ (- sentry.x cam-x) shake-x) sy (+ (- sentry.y cam-y) shake-y)
            tl (if sentry.facing-right SENTRY-R-TL SENTRY-L-TL)
            tr (if sentry.facing-right SENTRY-R-TR SENTRY-L-TR)
            bl (if sentry.facing-right SENTRY-R-BL SENTRY-L-BL)
            br (if sentry.facing-right SENTRY-R-BR SENTRY-L-BR)]
        (spr tl sx sy 0) (spr tr (+ sx 8) sy 0)
        (spr bl sx (+ sy 8) 0) (spr br (+ sx 8) (+ sy 8) 0))))
  (each [_ roller (ipairs rollers)]
    (when roller.alive
      (spr (or roller.sprite ROLLER-SPRITE)
           (+ (- roller.x cam-x) shake-x) (+ (- roller.y cam-y) shake-y) 0)))
  (each [_ flyer (ipairs flyers)]
    (when flyer.alive
      (spr (or flyer.sprite FLYER-SPRITE)
           (+ (- flyer.x cam-x) shake-x) (+ (- flyer.y cam-y) shake-y) 0)))
  (each [_ p (ipairs projectiles)]
    (spr (or p.sprite SPR-PROJECTILE)
         (+ (- p.x cam-x) shake-x) (+ (- p.y cam-y) shake-y) 0))
  (each [_ f (ipairs impact-flames)]
    (let [fp (% (// f.timer 6) 3)
          frame (if (= fp 0) 432 (if (= fp 1) 433 434))]
      (spr frame (+ (- f.x cam-x) shake-x) (+ (- f.y cam-y) shake-y) 0))))

;; Dessine les 4 checkpoints avec le bon sprite (actif/inactif).
(fn draw-checkpoints []
  (let [cx-a (* CHECKPOINT-A-TX TILE-SIZE) cy-a (* CHECKPOINT-A-TY TILE-SIZE)
        cx-b (* CHECKPOINT-B-TX TILE-SIZE) cy-b (* CHECKPOINT-B-TY TILE-SIZE)
        cx-c (* CHECKPOINT-C-TX TILE-SIZE) cy-c (* CHECKPOINT-C-TY TILE-SIZE)
        cx-d (* CHECKPOINT-D-TX TILE-SIZE) cy-d (* CHECKPOINT-D-TY TILE-SIZE)
        hide-b? (and (not checkpoint-b-touched)
                     (= CHECKPOINT-B-TX SPAWN-TX) (= CHECKPOINT-B-TY SPAWN-TY))
        spr-a (if (checkpoint-active? CHECKPOINT-A-TX CHECKPOINT-A-TY) SPR-CHECKPOINT-ON SPR-CHECKPOINT-OFF)
        spr-b (if (checkpoint-active? CHECKPOINT-B-TX CHECKPOINT-B-TY) SPR-CHECKPOINT-ON SPR-CHECKPOINT-OFF)
        spr-c (if (checkpoint-active? CHECKPOINT-C-TX CHECKPOINT-C-TY) SPR-CHECKPOINT-ON SPR-CHECKPOINT-OFF)
        spr-d (if (checkpoint-active? CHECKPOINT-D-TX CHECKPOINT-D-TY) SPR-CHECKPOINT-ON SPR-CHECKPOINT-OFF)]
    (spr spr-a (+ (- cx-a cam-x) shake-x) (+ (- cy-a cam-y) shake-y) 0)
    (when (not hide-b?)
      (spr spr-b (+ (- cx-b cam-x) shake-x) (+ (- cy-b cam-y) shake-y) 0))
    (spr spr-c (+ (- cx-c cam-x) shake-x) (+ (- cy-c cam-y) shake-y) 0)
    (spr spr-d (+ (- cx-d cam-x) shake-x) (+ (- cy-d cam-y) shake-y) 0)))

;; Dessine les 4 flammes decoratives animees.
(fn draw-animated-flame []
  (let [fx   (* FLAME-TILE-X TILE-SIZE)   fy   (* FLAME-TILE-Y TILE-SIZE)
        fx-b (* FLAME-TILE-B-X TILE-SIZE) fy-b (* FLAME-TILE-B-Y TILE-SIZE)
        fx-c (* FLAME-TILE-C-X TILE-SIZE) fy-c (* FLAME-TILE-C-Y TILE-SIZE)
        fx-d (* FLAME-TILE-D-X TILE-SIZE) fy-d (* FLAME-TILE-D-Y TILE-SIZE)]
    (spr flame-sprite (+ (- fx cam-x)   shake-x FLAME-DRAW-OFFSET-X) (+ (- fy   cam-y) shake-y FLAME-DRAW-OFFSET-Y) 0)
    (spr flame-sprite (+ (- fx-b cam-x) shake-x FLAME-DRAW-OFFSET-X) (+ (- fy-b cam-y) shake-y FLAME-DRAW-OFFSET-Y) 0)
    (spr flame-sprite (+ (- fx-c cam-x) shake-x FLAME-DRAW-OFFSET-X) (+ (- fy-c cam-y) shake-y FLAME-DRAW-OFFSET-Y) 0)
    (spr flame-sprite (+ (- fx-d cam-x) shake-x FLAME-DRAW-OFFSET-X) (+ (- fy-d cam-y) shake-y FLAME-DRAW-OFFSET-Y) 0)))

;; Dessine le HUD.
(fn draw-hud []
  (print (.. "Fragments: " fragment-count "/" "4") 2 2 15)
  (print (.. "R:" respawn-x "," respawn-y) 2 10 7)
  (when spectator-mode (print "MODE SPECTATEUR" 86 26 11)))

;; Dessine toute la scene de jeu.
(fn draw-world []
  (let [tx0 (// cam-x TILE-SIZE) ty0 (// cam-y TILE-SIZE)
        ox (+ (- (% cam-x TILE-SIZE)) shake-x)
        oy (+ (- (% cam-y TILE-SIZE)) shake-y)]
    (map tx0 ty0 (+ LEVEL-W 1) (+ LEVEL-H 1) ox oy))
  (draw-animated-flame)
  (draw-checkpoints)
  (draw-clones)
  (when show-player-tail (draw-player-follow))
  (draw-player)
  (draw-traps)
  (draw-hud)
  (when (> state.flash 0) (rect 0 0 SCREEN-W SCREEN-H state.flash-color)))

;; Met a jour la camera pour qu'elle suive le joueur en douceur.
(fn update-camera []
  (let [target-x (- (+ player.x 4) (/ SCREEN-W 2))
        target-y (- (+ player.y 4) (/ SCREEN-H 2))]
    (set cam-x (+ cam-x (* (- target-x cam-x) 0.18)))
    (set cam-y (+ cam-y (* (- target-y cam-y) 0.18)))))

;; Gere l'ecran de menu principal.
(fn update-menu []
  (cls 0)
  (when (not state.music-started) (music 0) (set state.music-started true))
  (animate-stars) (draw-black-sun) (draw-title-card)
  (let [(mx my left-click) (mouse)
        over-start (in-rect? mx my 70 70 100 18)
        over-options (in-rect? mx my 85 95 70 14)
        start-now (btn 4)]
    (when over-start (rounded-rect 68 68 104 22 3 5))
    (rounded-rect 70 70 100 18 (if over-start 10 9) 4)
    (when over-options (rounded-rect 83 93 74 18 3 5))
    (rounded-rect 85 95 70 14 5 4)
    (print "START GAME" 88 76 0) (print "OPTIONS" 98 99 15) (print "v0.2.0" 2 128 8)
    (when (and left-click mouse-released over-start)
      (set mouse-released false) (init-game) (set state.mode :play))
    (when (not left-click) (set mouse-released true))
    (when (and left-click mouse-released over-options)
      (set mouse-released false) (set options-selection 1) (set state.mode :options))
    (when (and start-now (not state.prev-start))
      (init-game) (set state.mode :play))
    (set state.prev-start start-now)))

;; Gere l'ecran d'options.
(fn update-options []
  (cls 0) (animate-stars)
  (rect 24 20 192 96 1) (rectb 24 20 192 96 9)
  (let [(mx my left-click) (mouse)
        over-tail (in-rect? mx my 44 50 152 14)
        over-wings (in-rect? mx my 44 68 152 14)
        over-back (in-rect? mx my 70 96 100 14)
        up (btnp 0) down (btnp 1) left (btnp 2) right (btnp 3)
        ok (or (btnp 4) (btnp 5)) back (btnp 6)]
    (when down (set options-selection 2))
    (when up (set options-selection 1))
    (when (and left-click mouse-released over-tail)
      (set mouse-released false) (set options-selection 1)
      (set show-player-tail (not show-player-tail))
      (when (not show-player-tail) (set player-trail [])))
    (when (and left-click mouse-released over-wings)
      (set mouse-released false) (set options-selection 2)
      (set show-player-wings (not show-player-wings)))
    (when (and left-click mouse-released over-back)
      (set mouse-released false) (set state.mode :menu))
    (when (not left-click) (set mouse-released true))
    (when (and (= options-selection 1) (or left right ok))
      (set show-player-tail (not show-player-tail))
      (when (not show-player-tail) (set player-trail [])))
    (when (and (= options-selection 2) (or left right ok))
      (set show-player-wings (not show-player-wings)))
    (when back (set state.mode :menu)))
  (print "OPTIONS" 99 28 12)
  (print (if (= options-selection 1) "> Queue perso" "  Queue perso") 36 52 15)
  (rectb 136 51 10 10 12)
  (when show-player-tail (line 138 56 140 58 11) (line 140 58 145 53 11))
  (print "Afficher" 151 52 12)
  (print (if (= options-selection 2) "> Ailes" "  Ailes") 36 70 15)
  (rectb 136 69 10 10 12)
  (when show-player-wings (line 138 74 140 76 11) (line 140 76 145 71 11))
  (print "Afficher" 151 70 12)
  (print "Haut/Bas: choix" 42 84 12)
  (print "Gauche/Droite/Z/X: basculer" 42 92 12)
  (rounded-rect 70 96 100 14 5 3)
  (print "RETOUR (A)" 96 100 15))

;; Boucle principale de jeu.
(fn update-play []
  (set state.timer (+ state.timer 1))
  (update-screen-shake)
  (when (> state.flash 0) (set state.flash (- state.flash 1)))
  (when (> dash-cooldown 0) (set dash-cooldown (- dash-cooldown 1)))
  (when (> fireball-cooldown 0) (set fireball-cooldown (- fireball-cooldown 1)))
  (let [left  (btn 2) right (btn 3) jump (btn 0) down (btn 1)
        toggle-spectator (btnp 6)
        test-death (btnp 7)
        dash-key (or (btnp 4) (btnp 5) (keyp 24))
        fire-key (or (keyp 25) (keyp 22))
        mask (+ (if left 1 0) (if right 2 0) (if jump 4 0))]
    (when toggle-spectator
      (set spectator-mode (not spectator-mode))
      (set player.alive true) (set player.vx 0) (set player.vy 0))
    (when (and dash-unlocked dash-key (not spectator-mode)) (start-dash))
    (when (and fire-key (not dash-key)) (shoot-player-fireball))
    (when (and test-death (not spectator-mode)) (trigger-death))
    (when (= state.mode :play)
      (mset FIXED-TILE-X FIXED-TILE-Y FIXED-TILE-ID)
      (mset FIXED-TILE-X FIXED-TILE-2-Y FIXED-TILE-ID)
      (mset EXTRA-TILE-X EXTRA-TILE-Y EXTRA-TILE-ID)
      (mset EXTRA-TILE-2-X EXTRA-TILE-2-Y EXTRA-TILE-2-ID)
      (mset FIXED-TILE-B-X FIXED-TILE-B-Y FIXED-TILE-ID)
      (mset FIXED-TILE-B-X FIXED-TILE-B-2-Y FIXED-TILE-ID)
      (mset EXTRA-TILE-B-L-X EXTRA-TILE-B-Y EXTRA-TILE-ID)
      (mset EXTRA-TILE-B-R-X EXTRA-TILE-B-Y EXTRA-TILE-2-ID)
      (when (not fragment-collected) (mset CUSTOM-TILE-X CUSTOM-TILE-Y CUSTOM-TILE-ID))
      (when (not dash-fragment-collected) (mset DASH-FRAGMENT-TILE-X DASH-FRAGMENT-TILE-Y DASH-FRAGMENT-TILE-ID))
      (when (not fire-fragment-collected) (mset FIRE-FRAGMENT-TILE-X FIRE-FRAGMENT-TILE-Y FIRE-FRAGMENT-TILE-ID))
      (when (not stele2-fragment-collected) (mset STELE2-FRAGMENT-TILE-X STELE2-FRAGMENT-TILE-Y STELE2-FRAGMENT-TILE-ID))
      (mset SOLO-BLACK-BLOCK-X SOLO-BLACK-BLOCK-Y SOLO-BLACK-BLOCK-ID)
      (mset (+ SOLO-BLACK-BLOCK-X 1) SOLO-BLACK-BLOCK-Y SOLO-RIGHT-BLOCK-ID)
      (mset (+ SOLO-BLACK-BLOCK-X 1) (- SOLO-BLACK-BLOCK-Y 1) SOLO-RIGHT-BLOCK-ID)
      (mset (+ SOLO-BLACK-BLOCK-X 2) SOLO-BLACK-BLOCK-Y SOLO-RIGHT2-BLOCK-ID)
      (mset STELE2-X STELE2-Y STELE2-BASE-ID)
      (mset (+ STELE2-X 1) STELE2-Y SOLO-RIGHT-BLOCK-ID)
      (mset (+ STELE2-X 1) (- STELE2-Y 1) SOLO-RIGHT-BLOCK-ID)
      (mset (+ STELE2-X 2) STELE2-Y SOLO-RIGHT2-BLOCK-ID)
      (set-end-tiles)
      (mset 104 47 lava-sprite)
      (update-flame-animation)
      (if spectator-mode
        (do (update-spectator-player player left right jump down) (update-camera))
        (do
          (table.insert current-recording mask)
          (update-clones)
          (if (player-dashing?) (update-dash) (update-entity player left right jump down))
          (update-door) (update-door-teleport) (update-checkpoint) (update-fragments)
          (update-end-structure-interaction)
          (when show-player-tail (update-player-trail))
          (update-deadly-zones) (update-rollers) (update-flyers) (update-patrollers)
          (update-hunters) (update-sentries) (update-shooters)
          (update-projectiles) (update-impact-flames) (update-camera)
          ))))
  (cls 0) (draw-world))

;; Gere l'ecran de mort.
(fn update-death []
  (set state.timer (+ state.timer 1))
  (update-screen-shake)
  (when (> state.flash 0) (set state.flash (- state.flash 1)))
  (when (>= state.timer 45)
    (if (and clone-system-unlocked (< (list-length ghost-recordings) MAX-CLONES))
      (do (set state.mode :death-choice) (set state.timer 0) (set state.prev-choice false))
      (do
        (start-attempt)
        (set state.mode :play)
        (set state.timer 0)
        (set state.prev-choice false))))
  (cls 2)
  (print "TU ES MORT" 92 54 15)
  (print "Choix dans un instant..." 56 70 15))

;; Gere les inputs de l'ecran de choix apres la mort.
(fn update-death-choice []
  (let [choose-save (or (btnp 5) (btnp 4) (btnp 0))
        choose-skip (or (btnp 1) (btnp 6))]
    (when choose-save (save-current-run-as-clone) (start-attempt) (set state.mode :play))
    (when choose-skip (start-attempt) (set state.mode :play))))

;; Dessine l'ecran de choix post-mort.
(fn draw-death-choice []
  (cls 0)
  (rect 40 35 160 66 0) (rectb 40 35 160 66 9)
  (let [msg "TU ES MORT" mw (* (string.len msg) 6)]
    (print msg (- 120 (/ mw 2)) 42 2 0 0 false 1))
  (let [msg2 "Enregistrer ce fantome ?" mw2 (* (string.len msg2) 6)]
    (print msg2 (- 120 (/ mw2 2)) 56 7))
  (rounded-rect 50 68 60 18 11 3) (print "OUI" 72 74 0) (print "Z / X / Haut" 50 88 6)
  (rounded-rect 130 68 60 18 2 3) (print "NON" 153 74 0) (print "Bas / A" 134 88 6)
  (let [restants (- MAX-CLONES (list-length ghost-recordings))
        msg3 (.. "Fantomes dispo: " restants "/" MAX-CLONES)]
    (print msg3 (- 120 (* (string.len msg3) 3)) 100 12)))

;; Gere l'etat game-over.
(fn update-game-over []
  (when (or (btn 4) (btn 5) (btn 0) (btn 1))
    (init-game) (set state.mode :play)))

;; Dessine l'ecran de game-over.
(fn draw-game-over []
  (cls 0)
  (print "GAME OVER" 86 44 2 0 0 false 2)
  (print "3 fantomes utilises." 78 70 7)
  (print "Z/X/Haut/Bas pour recommencer" 34 84 12))

;; Gere l'ecran de victoire.
(fn update-win []
  (set state.timer (+ state.timer 1))
  (update-screen-shake)
  (when (> state.flash 0) (set state.flash (- state.flash 1)))
  (if (< state.timer state.message-timer)
    (cls 0)
    (do
      (let [up (btnp 0)
            down (btnp 1)
            confirm (or (btnp 4) (btnp 5))]
        (when up (set win-selection 1))
        (when down (set win-selection 2))
        (when confirm
          (if (= win-selection 1)
            (do (init-game) (set state.mode :play))
            (set state.mode :menu))))
      (cls 12)
      (rect 28 20 184 96 0)
      (rectb 28 20 184 96 1)
      (print "YOU WIN" 96 30 12)
      (print (.. "Fragments: " fragment-count "/" "4") 70 46 12)
      (print (.. "Clones: " (list-length ghost-recordings) "/" MAX-CLONES) 74 54 12)
      (rounded-rect 62 70 116 14 (if (= win-selection 1) 11 5) 3)
      (rounded-rect 62 88 116 14 (if (= win-selection 2) 11 5) 3)
      (print "RESTART" 102 74 (if (= win-selection 1) 0 15))
      (print "MENU" 110 92 (if (= win-selection 2) 0 15))
      (print "HAUT/BAS + Z/X" 78 108 13))))

;; Boucle principale TIC-80 : appelee 60 fois par seconde.
(global TIC (fn []
  (update-sound-sequence)
  (when (= (list-length stars) 0) (init-stars))
  (set title-time (+ title-time 0.05))
  (case state.mode
    :menu        (update-menu)
    :options     (update-options)
    :play        (update-play)
    :death       (update-death)
    :death-choice (do (update-death-choice) (draw-death-choice))
    :game-over   (do (update-game-over) (draw-game-over))
    :win         (update-win)
    _            (update-menu))))
