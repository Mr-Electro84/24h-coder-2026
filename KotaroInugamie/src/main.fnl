;; title: Dodge!
;; author: QbitStudio
;; desc: A video game designed by QbitSoft
;; script: fennel

<import global-variables.fnl>

(fn _G.BOOT []
  (pmem 0 0))

(set best-score (pmem 0))
(global map-sol [])
(for [i 1 17]
  (local map-x []) ; new table each time
  (for [j 1 18]
    (tset map-x j (math.random 100)))
  (tset map-sol i map-x))

; Variable pour l'animation
(var t 0)

<import music.fnl>
<import state-manager.fnl>
<import start-menu.fnl>

(fn detecte-oob [x y min-x max-x min-y max-y]
  (set correct false)
  (if (< x min-x)
    (set correct true))
  (if (> (+ x 8) max-x)
    (set correct true))
  (if (< y min-y)
    (set correct true))
  (if (> (+ y 8) max-y)
    (set correct true)))

(fn detect-collision [ax ay aw ah bx by bw bh]
  (and (and (< ax (+ bx bw)) (> (+ ax aw) bx)) (and (< ay (+ by bh)) (> (+ ay ah) by))))

(fn manage-player-movements []
  (if (= true (btn 0))
    (set axis-y (- axis-y 1)))
  (if (= true (btn 1))
    (set axis-y (+ axis-y 1)))
  (if (= true (btn 2))
    (set axis-x (- axis-x 1)))
  (if (= true (btn 3))
    (set axis-x (+ axis-x 1)))
  
  (detecte-oob (+ player-x axis-x) player-y GAME_MIN_X GAME_MAX_X GAME_MIN_Y GAME_MAX_Y)
  (if (= true correct)
    (set axis-x 0))
  (detecte-oob player-x (+ player-y axis-y) GAME_MIN_X GAME_MAX_X GAME_MIN_Y GAME_MAX_Y)
  (if (= true correct)
    (set axis-y 0))

  (set player-y (+ player-y axis-y))
  (set player-x (+ player-x axis-x))
  (if (or (not= axis-y 0) (not= axis-x 0))
    (set player-sprite (+ 2 (% t 2)))
    (set player-sprite 1))

  (spr 5 (- player-x 4) (- player-y 4) 0)
  (spr 6 (+ player-x 4) (- player-y 4) 0)
  (spr 21 (- player-x 4) (+ player-y 4) 0)
  (spr 22 (+ player-x 4) (+ player-y 4) 0)
  (spr player-sprite player-x player-y 0)

  (set axis-x 0)
  (set axis-y 0))

<import flies.fnl>
<import nutriment.fnl>
<import manage-game.fnl>

; Boucle principale exécutée à 60 FPS
(fn _G.TIC []
  
  (if (= state 0)
    (manage-start-menu)
    )
  
  (if (= state 1)
    (manage-main-game))
  
  (if (= state 2)
    (manage-game-over))
  
  ; 4. Fait avancer le temps
  (set t (+ t 0.1)))