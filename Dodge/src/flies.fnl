(fn trace-flies []
  (each [key value (ipairs flies)]
  (trace "{")
  (trace (.. "pos-x: " (. value :fly-pos-x)))
  (trace (.. "pos-y: " (. value :fly-pos-y)))
  (trace (.. "vector-x: " (. value :fly-vector-x)))
  (trace (.. "vector-y: " (. value :fly-vector-y)))
  (trace (.. "respawn-delay: " (. value :fly-respawn-delay)))
  (trace "}")))

(fn spaw-chad []
  (set music-main 0)
  (set chad-fly-spawned true))

(fn new-fly [pos-x pos-y dir-start-x dir-start-y dir-end-x dir-end-y velocity is-chad]
  ; ->AB=((xb-xa)*->i)+((yb-ya)*->i)
  (local vector-x (- dir-end-x dir-start-x))
  (local vector-y (- dir-end-y dir-start-y))
  (set velo (* velocity chad-mult))
  ;(if (> chad-mult chad-mod-lvl)
  ;  (set music-main 0))
  (table.insert flies {:fly-pos-x pos-x :fly-pos-y pos-y :fly-vector-x (* velo vector-x) :fly-vector-y (* velo vector-y) :is-chad is-chad}))

(fn spawn-flies []
  (local spawn-zone (math.random 0 1))
  (var start-x (math.random 0 40))
  (if (= 1 spawn-zone)
  (set start-x (math.random 200 240)))
  (local start-y (math.random 0 136))
  (var must-chad (and (< chad-mod-lvl chad-mult) (not chad-fly-spawned)))
  (if (= true must-chad)
  (spaw-chad))
  (new-fly start-x start-y start-x start-y (math.random 0 240) (math.random 0 136) (* chad-mult 0.002) must-chad))

(fn remove-fly [j]
  (table.remove flies j)
  (spawn-flies))

(fn move-flies []
  ; (trace "Tdmsldvs")
  (each [j value (pairs flies)]
    (tset value :fly-pos-x (+ (. value :fly-vector-x) (. value :fly-pos-x)))
    (tset value :fly-pos-y (+ (. value :fly-vector-y) (. value :fly-pos-y)))
    (detecte-oob (. value :fly-pos-x) (. value :fly-pos-y) 0 240 -16 152)
    (if (= true correct)
      (remove-fly j))

    (if (detect-collision player-x player-y 8 8 (. value :fly-pos-x) (. value :fly-pos-y) 8 8)
      (change-state 3 c3 2))))

(fn render-ombre-mouche1 [x y]
  (spr 192 (- x 4) (- y 4) 0)
  (spr 193 (+ x 4) (- y 4) 0)
  (spr 208 (- x 4) (+ y 4) 0)
  (spr 209 (+ x 4) (+ y 4) 0))

(fn render-ombre-mouche2 [x y]
  (spr 194 (- x 12) (- y 12) 0 3)
  (spr 195 (+ x 12) (- y 12) 0 3)
  (spr 210 (- x 12) (+ y 12) 0 3)
  (spr 211 (+ x 12) (+ y 12) 0 3))

(fn render-ombre-mouche3 [x y]
  (spr 196 (- x 12) (- y 12) 0 3)
  (spr 197 (+ x 12) (- y 12) 0 3)
  (spr 212 (- x 12) (+ y 12) 0 3)
  (spr 213 (+ x 12) (+ y 12) 0 3))

(fn render-flies []
  (each [key value (pairs flies)]
  (var sprite-randomizer 16)
  (var size 3)

  (if (= true (. value :is-chad))
    (set sprite-randomizer 18)
    (set size 1))

  (spr 34 (. value :fly-pos-x) (+ (. value :fly-pos-y) 4) 0)

  (local sprite (math.random sprite-randomizer (+ 1 sprite-randomizer)))
  (if (= sprite 17)
    (render-ombre-mouche1 (. value :fly-pos-x) (. value :fly-pos-y))
    (= sprite 18)
    (render-ombre-mouche2 (. value :fly-pos-x) (. value :fly-pos-y))
    (= sprite 19)
    (render-ombre-mouche3 (. value :fly-pos-x) (. value :fly-pos-y)))
  (spr sprite (. value :fly-pos-x) (. value :fly-pos-y) 0 size)))

(fn manage-flies []
  (if (= true is-initializing-game)
    (for [i 0 5 1]
      (spawn-flies)))

  (set is-initializing-game false)
  ;(trace-flies)
  (move-flies)
  (render-flies))