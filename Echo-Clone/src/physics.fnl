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

(fn point-solid? [px py]
  (tile-solid? (// px TILE-SIZE) (// py TILE-SIZE)))

(fn tile-solid? [tx ty]
  (if (or (< tx 0) (>= tx MAP-TILES-W) (< ty 0))
    true
    (if (>= ty MAP-TILES-H)
      false
      (fget (map-tile tx ty) FLAG-SOLID))))