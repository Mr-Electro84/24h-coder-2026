;; title:  Echo Clone
;; author: Equipe 7
;; desc:   Platformer TIC-80 en Fennel avec clones rejouant les runs precedentes.
;; script: fennel
;; /Applications/tic80.app/Contents/MacOS/tic80 --skip --fs . --cmd="load assets/sprites & import code src/main2.fnl & run"



(fn rounded-rect [x y w h color radius]
  (rect (+ x radius) y (- w (* 2 radius)) h color)
  (rect x (+ y radius) w (- h (* 2 radius)) color)
  (circ (+ x radius) (+ y radius) radius color)
  (circ (- (+ x w) radius) (+ y radius) radius color)
  (circ (+ x radius) (- (+ y h) radius) radius color)
  (circ (- (+ x w) radius) (- (+ y h) radius) radius color))

(fn decode-bitmask [mask]
  [(= (% mask 2) 1)
   (>= (% mask 4) 2)
   (>= mask 4)])

(fn entity-midpoint [entity]
  (let [w (or entity.w 8)
        h (or entity.h 8)]
    [(+ entity.x (/ w 2)) (+ entity.y (/ h 2))]))


(fn point-ladder? [px py]
  (= (map-tile (// px TILE-SIZE) (// py TILE-SIZE)) 48))

(fn solid-platform-overlap [self nx ny w h]
  (var hit nil)
  (each [_ clone (ipairs solid-clones)]
    (when (and clone.alive (not= clone self)
               (aabb-overlap nx ny w h clone.x clone.y (or clone.w 8) (or clone.h 8)))
      (set hit clone)))
  hit)

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

(fn entity-covers-tile? [entity tx ty]
  (let [w (or entity.w 8)
        h (or entity.h 8)
        left   (// entity.x TILE-SIZE)
        right  (// (+ entity.x (- w 1)) TILE-SIZE)
        top    (// entity.y TILE-SIZE)
        bottom (// (+ entity.y (- h 1)) TILE-SIZE)]
    (and (>= tx left) (<= tx right)
         (>= ty top) (<= ty bottom))))

(fn dash-wall-ahead? [entity dir]
  (let [probe-x (+ entity.x (* dir 4))]
    (collides-at? entity probe-x entity.y)))

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

(fn collect-fragment []
  (when (not fragment-collected)
    (set fragment-collected true)
    (set fragment-count (+ fragment-count 1))
    (set clone-system-unlocked true)
    (mset CUSTOM-TILE-X CUSTOM-TILE-Y 0)
    (sfx 8)))

(fn collect-dash-fragment []
  (when (not dash-fragment-collected)
    (set dash-fragment-collected true)
    (set fragment-count (+ fragment-count 1))
    (set dash-unlocked true)
    (mset DASH-FRAGMENT-TILE-X DASH-FRAGMENT-TILE-Y 0)
    (sfx 8)))

(fn collect-fire-fragment []
  (when (not fire-fragment-collected)
    (set fire-fragment-collected true)
    (set fire-skill-unlocked true)
    (set fragment-count (+ fragment-count 1))
    (mset FIRE-FRAGMENT-TILE-X FIRE-FRAGMENT-TILE-Y 0)
    (sfx 8)))

(fn collect-stele2-fragment []
  (when (not stele2-fragment-collected)
    (set stele2-fragment-collected true)
    (set ladder-unlocked true)
    (set fragment-count (+ fragment-count 1))
    (mset STELE2-FRAGMENT-TILE-X STELE2-FRAGMENT-TILE-Y 0)
    (sfx 8)))

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

(fn player-dashing? []
  (> dash-active-timer 0))

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


(fn reset-player-follow []
  (set player-trail [])
  (for [_ 1 FOLLOW-SEGMENTS]
    (table.insert player-trail {:x (+ player.x 4) :y (+ player.y 14)})))

(fn rebuild-solid-clones []
  (set solid-clones [])
  (each [_ clone (ipairs active-clones)]
    (when (and clone.alive clone.immobile)
      (table.insert solid-clones clone))))

(fn start-attempt []
  (set current-recording [])
  (set current-start-x respawn-x)
  (set current-start-y respawn-y)
  (reset-player respawn-x respawn-y)
  (set cam-x (- (+ player.x 4) (/ SCREEN-W 2)))
  (set cam-y (- (+ player.y 4) (/ SCREEN-H 2)))
  (spawn-clones-from-recordings))

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
  ;; MODIF 3 : scan des tiles de lave après init de la map
  (scan-lava-tiles)
  (start-attempt))

(fn update-screen-shake []
  (when (> shake-timer 0) (set shake-timer (- shake-timer 1)))
  (if (> shake-timer 0)
    (do (set shake-x (math.random -3 3)) (set shake-y (math.random -2 2)))
    (do (set shake-x 0) (set shake-y 0))))

(fn reset-hunters-to-start []
  (each [_ hunter (ipairs hunters)]
    (set hunter.x (* HUNTER-START-TX TILE-SIZE))
    (set hunter.y (* HUNTER-START-TY TILE-SIZE))
    (set hunter.vx 0) (set hunter.vy 0)
    (set hunter.on-ground false) (set hunter.dir 1)
    (set hunter.reached-stop false)
    (set hunter.armed false) (set hunter.active false)))

(fn trigger-death []
  (when player.alive
    (set player.alive false)
    (reset-hunters-to-start)
    (set state.mode :death)
    (set state.timer 0) (set state.flash 10) (set state.flash-color 2)
    (set shake-timer 20) (play-death-sound)))

(fn finish-level []
  (set state.mode :win) (set state.timer 0)
  (set win-selection 1)
  (set state.message-timer 45) (set state.flash 6)
  (set state.flash-color 12) (play-win-sound))

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

(global update-end-structure-interaction
  (fn []
    (when (and player.alive (keyp 11) (player-on-end-structure?))
      (set player-skin-sprite 450)
      (finish-level))))

(fn set-checkpoint [tx ty]
  (let [new-x (* tx TILE-SIZE) new-y (* ty TILE-SIZE)]
    (when (or (not= respawn-x new-x) (not= respawn-y new-y))
      (set respawn-x new-x) (set respawn-y new-y) (sfx 5))))

(global set-door-tiles
  (fn [tx ty tl tr bl br]
    (mset tx ty tl) (mset (+ tx 1) ty tr)
    (mset tx (+ ty 1) bl) (mset (+ tx 1) (+ ty 1) br)))

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

(global teleport-player-to-spawn-door
  (fn []
    (set player.x (* DOOR-TX TILE-SIZE))
    (set player.y (- (* DOOR-TY TILE-SIZE) 16))
    (set player.vx 0) (set player.vy 0)
    (set player.on-ground false) (set player.dir 1)
    (set cam-x (- (+ player.x 4) (/ SCREEN-W 2)))
    (set cam-y (- (+ player.y 4) (/ SCREEN-H 2)))
    (sfx 10)))

(fn checkpoint-active? [tx ty]
  (and (= respawn-x (* tx TILE-SIZE)) (= respawn-y (* ty TILE-SIZE))))

(fn player-near-checkpoint? [tx ty]
  (let [foot-x (+ player.x 4)
        foot-y (+ player.y (- (or player.h 16) 1))
        ftx (// foot-x TILE-SIZE)
        fty (// foot-y TILE-SIZE)]
    (and (>= ftx (- tx 1)) (<= ftx (+ tx 1))
         (>= fty (- ty 1)) (<= fty (+ ty 1)))))

(fn entity-midpoint-tile [entity]
  (let [w (or entity.w 8) h (or entity.h 8)]
    [(// (+ entity.x (/ w 2)) TILE-SIZE)
     (// (+ entity.y (/ h 2)) TILE-SIZE)]))

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

(fn remove-dead-projectiles []
  (var kept [])
  (each [_ p (ipairs projectiles)] (when p.alive (table.insert kept p)))
  (set projectiles kept))

(global kill-clone
  (fn [clone]
    (when clone
      (set clone.alive false)
      (set clone.immobile false))))






(fn hunter-obstacle-ahead? [hunter dir]
  (let [probe-x (+ hunter.x (* dir 2))]
    (or (collides-at? hunter probe-x hunter.y)
        (collides-at? hunter probe-x (- hunter.y 1)))))

(fn hunter-gap-ahead? [hunter dir]
  (let [front-x (if (> dir 0) (+ hunter.x 16) (- hunter.x 1))
        foot-y (+ hunter.y 17)]
    (not (point-solid? front-x foot-y))))



(fn spawn-impact-flame [x y]
  (table.insert impact-flames {:x x :y y :timer 120})
  (when (> (list-length impact-flames) 24)
    (table.remove impact-flames 1)))

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
