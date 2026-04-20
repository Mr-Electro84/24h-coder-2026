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
      (update-flame-animation)
      ;; MODIF 4 : animer tous les tiles de lave scannés
      (each [_ t (ipairs lava-tiles)]
        (mset t.tx t.ty lava-sprite))
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

(fn update-death-choice []
  (let [choose-save (or (btnp 5) (btnp 4) (btnp 0))
        choose-skip (or (btnp 1) (btnp 6))]
    (when choose-save (save-current-run-as-clone) (start-attempt) (set state.mode :play))
    (when choose-skip (start-attempt) (set state.mode :play))))

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

(fn update-impact-flames []
  (var kept [])
  (each [_ f (ipairs impact-flames)]
    (set f.timer (- f.timer 1))
    (when (and player.alive
               (aabb-overlap f.x f.y 8 8 player.x player.y (or player.w 8) (or player.h 8)))
      (trigger-death))
    (when (> f.timer 0) (table.insert kept f)))
  (set impact-flames kept))

(fn update-player-trail []
  (when (= (length player-trail) 0) (reset-player-follow))
  (let [head-x (+ player.x 4) head-y (+ player.y 14)]
    (each [i seg (ipairs player-trail)]
      (let [prev (if (> i 1) (. player-trail (- i 1)) nil)
            tx (if prev prev.x head-x) ty (if prev prev.y head-y)]
        (set seg.x (+ seg.x (* (- tx seg.x) FOLLOW-LERP)))
        (set seg.y (+ seg.y (* (- ty seg.y) FOLLOW-LERP)))))))

(fn update-camera []
  (let [target-x (- (+ player.x 4) (/ SCREEN-W 2))
        target-y (- (+ player.y 4) (/ SCREEN-H 2))]
    (set cam-x (+ cam-x (* (- target-x cam-x) 0.18)))
    (set cam-y (+ cam-y (* (- target-y cam-y) 0.18)))))

(fn update-game-over []
  (when (or (btn 4) (btn 5) (btn 0) (btn 1))
    (init-game) (set state.mode :play)))

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

(fn update-deadly-zones []
  (when (and player.alive (entity-on-deadly-tile? player)) (trigger-death))
  (each [_ clone (ipairs active-clones)]
    (when (and clone.alive (entity-on-deadly-tile? clone)) (kill-clone clone)))
  (rebuild-solid-clones))

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

(fn update-spectator-player [entity input-left input-right input-up input-down]
  (let [w (or entity.w 8) h (or entity.h 8)
        max-x (- (* MAP-TILES-W TILE-SIZE) w)
        max-y (- (* MAP-TILES-H TILE-SIZE) h)
        dx (+ (if input-right SPECTATOR-SPEED 0)
              (if input-left (- 0 SPECTATOR-SPEED) 0))
        dy (+ (if input-down SPECTATOR-SPEED 0)
              (if input-up (- 0 SPECTATOR-SPEED) 0))
        nx (+ entity.x dx)
        ny (+ entity.y dy)]
    (set entity.x (if (< nx 0) max-x (if (> nx max-x) 0 nx)))
    (set entity.y (if (< ny 0) max-y (if (> ny max-y) 0 ny)))
    (set entity.vx 0) (set entity.vy 0) (set entity.on-ground false)))

(fn update-flame-animation []
  (let [phase (% (// state.timer 8) 3)
        frame (if (= phase 0) 432 (if (= phase 1) 433 434))]
    (set flame-sprite frame))
  (set lava-sprite (if (= (% (// state.timer 15) 2) 0) 47 159)))
