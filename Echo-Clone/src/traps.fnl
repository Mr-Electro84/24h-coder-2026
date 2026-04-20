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

(fn update-hunters []
  (each [_ hunter (ipairs hunters)]
    (when hunter.alive
      (if (not hunter.active)

        ;; Branche inactive : armer le hunter quand le joueur entre sur sa case
        (let [on-spawn-case
                (and player.alive
                     (or (entity-covers-tile? player HUNTER-START-TX HUNTER-START-TY)
                         (entity-covers-tile? player (+ HUNTER-START-TX 1) HUNTER-START-TY)
                         (entity-covers-tile? player HUNTER-START-TX (+ HUNTER-START-TY 1))
                         (entity-covers-tile? player (+ HUNTER-START-TX 1) (+ HUNTER-START-TY 1))))]
          (when on-spawn-case
            (set hunter.armed true))
          (when (and hunter.armed (not on-spawn-case))
            (set hunter.active true)))

        ;; Branche active : pourchasser le joueur
        (let [center-x    (+ hunter.x 8)
              center-y    (+ hunter.y 8)
              [target-x target-y] (if player.alive
                                    (entity-midpoint player)
                                    [center-x center-y])
              move-left   (< target-x (- center-x 2))
              move-right  (> target-x (+ center-x 2))
              dir         (if move-left -1 (if move-right 1 hunter.dir))
              jump-needed (and hunter.on-ground
                               (or (hunter-obstacle-ahead? hunter dir)
                                   (hunter-gap-ahead? hunter dir)
                                   (< target-y (- center-y 10))))]
          (set hunter.dir dir)
          (update-entity hunter (= dir -1) (= dir 1) jump-needed)
          (when (and player.alive
                     (aabb-overlap hunter.x hunter.y 16 16
                                   player.x player.y (or player.w 8) (or player.h 8)))
            (trigger-death)))))))

(fn update-sentries []
  (each [_ sentry (ipairs sentries)]
    (when sentry.alive
      (let [sx (+ sentry.x 8)
            [px _] (if player.alive (entity-midpoint player) [sx 0])]
        (set sentry.facing-right (> px sx))))))

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