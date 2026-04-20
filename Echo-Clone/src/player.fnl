(fn reset-player [x y]
  (set player {:x x :y y :vx 0 :vy 0 :on-ground false :dir 1
               :alive true :kind :player :w 8 :h 16}))

(fn start-dash []
  (when (and dash-unlocked player.alive (not spectator-mode)
             (= dash-active-timer 0) (= dash-cooldown 0))
    (set dash-dir (if (= player.dir 0) 1 player.dir))
    (set dash-speed-steps (if (dash-wall-ahead? player dash-dir) 8 6))
    (set dash-active-timer (if (= dash-speed-steps 8) 10 8))
    (set dash-cooldown 24)
    (set player.dir dash-dir)
    (sfx 9)))

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