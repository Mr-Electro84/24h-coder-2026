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

(fn animate-stars []
  (each [_ star (ipairs stars)]
    (set star.x (+ star.x star.speed))
    (when (> star.x 239) (set star.x 0) (set star.y (math.random 0 135)))
    (pix star.x star.y star.color)))

(fn draw-black-sun []
  (let [radius (+ 12 (* 2 (math.sin (* title-time 0.8)))) cx 120 cy 28]
    (circb cx cy (+ radius 5) 2) (circb cx cy (+ radius 3) 1)
    (circ cx cy radius 0) (circb cx cy radius 9)
    (for [i 0 7]
      (let [angle (* i (/ (* 2 3.14159) 8))
            rx1 (* (+ radius 2) (math.cos angle)) ry1 (* (+ radius 2) (math.sin angle))
            rx2 (* (+ radius 7) (math.cos angle)) ry2 (* (+ radius 7) (math.sin angle))]
        (line (+ cx rx1) (+ cy ry1) (+ cx rx2) (+ cy ry2) 9)))))

(fn draw-title-card []
  (print "Echo Clone" 62 22 0 0 0 false 2)
  (let [offset (* (math.sin title-time) 2)]
    (print "Echo Clone" 61 (+ 50 offset) 9 0 0 false 2))
  (let [subtitle "Echo Clone"
        sw (* (string.len subtitle) 6)
        sx (- (/ SCREEN-W 2) (/ sw 2))]
    (print subtitle sx 46 13)))

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

(fn draw-player []
  (when player.alive
    (let [sx (+ (- player.x cam-x 4) shake-x)
          sy (+ (- player.y cam-y) shake-y)]
      (draw-player-wings sx sy)
  (spr (if spectator-mode SPR-CLONE-A player-skin-sprite)
           sx sy 0 1 (if (< player.dir 0) 1 0) 0 2 2))))

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

(fn draw-clones []
  (each [_ clone (ipairs active-clones)]
    (when clone.alive
      (spr SPR-CLONE-A
        (+ (- clone.x cam-x 4) shake-x)
        (+ (- clone.y cam-y) shake-y)
        0 1 (if (< clone.dir 0) 1 0) 0 2 2))))

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

(fn draw-animated-flame []
  (let [fx   (* FLAME-TILE-X TILE-SIZE)   fy   (* FLAME-TILE-Y TILE-SIZE)
        fx-b (* FLAME-TILE-B-X TILE-SIZE) fy-b (* FLAME-TILE-B-Y TILE-SIZE)
        fx-c (* FLAME-TILE-C-X TILE-SIZE) fy-c (* FLAME-TILE-C-Y TILE-SIZE)
        fx-d (* FLAME-TILE-D-X TILE-SIZE) fy-d (* FLAME-TILE-D-Y TILE-SIZE)]
    (spr flame-sprite (+ (- fx cam-x)   shake-x FLAME-DRAW-OFFSET-X) (+ (- fy   cam-y) shake-y FLAME-DRAW-OFFSET-Y) 0)
    (spr flame-sprite (+ (- fx-b cam-x) shake-x FLAME-DRAW-OFFSET-X) (+ (- fy-b cam-y) shake-y FLAME-DRAW-OFFSET-Y) 0)
    (spr flame-sprite (+ (- fx-c cam-x) shake-x FLAME-DRAW-OFFSET-X) (+ (- fy-c cam-y) shake-y FLAME-DRAW-OFFSET-Y) 0)
    (spr flame-sprite (+ (- fx-d cam-x) shake-x FLAME-DRAW-OFFSET-X) (+ (- fy-d cam-y) shake-y FLAME-DRAW-OFFSET-Y) 0)))

(fn draw-hud []
  (print (.. "Fragments: " fragment-count "/" "4") 2 2 7)
  (when spectator-mode
    (print "MODE SPECTATEUR" 86 26 7)
    (print (.. "R:" respawn-x "," respawn-y) 2 10 7)
    (print (.. "P:" (math.floor player.x) "," (math.floor player.y)) 2 20 7)))

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

(fn draw-game-over []
  (cls 0)
  (print "GAME OVER" 86 44 2 0 0 false 2)
  (print "3 fantomes utilises." 78 70 7)
  (print "Z/X/Haut/Bas pour recommencer" 34 84 12))