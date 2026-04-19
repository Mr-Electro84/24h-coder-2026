(global state 0) ; 0: start, 1: playing, 2: game over.
(global best-score 0)
(global player-x (- 120 4))
(global player-y (- 68 4))
(global player-sprite 1)
(global axis-x 0)
(global axis-y 0)
(global correct false)
(global music-state -1)
(global music-start-time 0)
(global game-start-time 0)
(global music-main 2)

(global is-initializing-game true)

(global chad-mult 1)
(global chad-mod-lvl 1.3)
(global chad-fly-spawned false)

; Flies
(global flies []) ; {fly-pos-x, fly-pos-y, fly-vector-x, fly-vector-y, fly-respawn-delay, is-chad}
; (global dead-flies-counter []) ; Counters of dead flies.

(global must-play-sfx false)

(global score 0)

(global nutr-x 6)
(global nutr-y 0)
(global nutr-index 0)
(global nutr-temps 120)
(global nutr-delai nutr-temps)
(global nutr-affiche 0)

(global GAME_MAX_X 192)
(global GAME_MIN_X 48)
(global GAME_MAX_Y 136)
(global GAME_MIN_Y 0)

(var couleur-texte 12)  ; 6 = vert. Essaie 11 (bleu clair)

(fn restart-game []
    (set best-score 0)
    (set player-x 120)
    (set player-y 68)
    (set player-sprite 1)
    (set axis-x 0)
    (set axis-y 0)
    (set correct false)
    (set music-state -1)
    (set music-start-time 0)
    (set game-start-time 0)

    (set is-initializing-game true)

    (set chad-mult 1)
    (set chad-fly-spawned false)

; Flies
    (set flies []) ; {fly-pos-x, fly-pos-y, fly-vector-x, fly-vector-y, fly-respawn-delay}
; (global dead-flies-counter []) ; Counters of dead flies.

    (set must-play-sfx false)

    (set score 0)

    (set nutr-x 6)
    (set nutr-y 0)
    (set nutr-index 0)
    (set nutr-temps 120)
    (set nutr-delai nutr-temps)
    (set nutr-affiche 0)

    (set best-score (pmem 0))
    (set map-sol [])
    (for [i 1 17]
    (local map-x []) ; new table each time
    (for [j 1 18]
        (tset map-x j (math.random 100)))
    (tset map-sol i map-x))

; Variable pour l'animation
    (set t 0)
    (set state 0)) ; 0: start, 1: playing, 2: game over.