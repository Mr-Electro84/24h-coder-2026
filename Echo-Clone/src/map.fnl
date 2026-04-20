(fn map-tile [tx ty]
  (if (or (< tx 0) (< ty 0) (>= tx MAP-TILES-W) (>= ty MAP-TILES-H))
    0
    (mget tx ty)))

(fn tile-deadly? [tx ty]
  (if (or (< tx 0) (>= tx MAP-TILES-W) (< ty 0) (>= ty MAP-TILES-H))
    false
    (let [tile (map-tile tx ty)]
      (or (fget tile FLAG-DEADLY)
          (= tile 100) (= tile 101) (= tile 47) (= tile 159)
          (= tile 116) (= tile 117) (= tile 132)
          (= tile 149) (= tile 164) (= tile 181)))))

(fn tile-exit? [tx ty]
  (if (or (< tx 0) (>= tx MAP-TILES-W) (< ty 0) (>= ty MAP-TILES-H))
    false
    (fget (map-tile tx ty) FLAG-EXIT)))

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

;; MODIF 2 : scan de tous les tiles de lave (IDs 47 et 159) dans la map
(fn scan-lava-tiles []
  (set lava-tiles [])
  (for [ty 0 (- MAP-TILES-H 1)]
    (for [tx 0 (- MAP-TILES-W 1)]
      (let [tile (mget tx ty)]
        (when (or (= tile 47) (= tile 159))
          (table.insert lava-tiles {:tx tx :ty ty}))))))