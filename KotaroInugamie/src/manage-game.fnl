(fn render-game []
  (if (= game-start-time 0)
    (start-game-music-logic))
  (if (and (not= music-main music-state) (>= (- t game-start-time) (* 3 4)))
    (play-music music-main))
  (if (and (>= (- t music-start-time) (* 38 6)) (not= music-state -1))
    (reset-music-game))
  (cls background-color-game)

  (map)

  (for [i 1 (length map-sol)]
    (local inner (. map-sol i))
    (for [j 1 (length inner)]
      (if (< (. inner j) 41) ; Vide : 40 %
        (spr 48 (* (+ j 5) 8) (* (- i 1) 8) 0)
        (< (. inner j) 61) ; Fleurs : 20 %
        (spr ( + 64 (% t 4)) (* (+ j 5) 8) (* (- i 1) 8) 0)
        (< (. inner j) 81) ; Herbe : 20 %
        (spr ( + 80 (% t 6)) (* (+ j 5) 8) (* (- i 1) 8) 0)
        (< (. inner j) 86) ; Flaque : 5 %
        (spr ( + 96 (% t 6)) (* (+ j 5) 8) (* (- i 1) 8) 0)
        (< (. inner j) 100) ; Cailloux : 14 %
        (spr 112 (* (+ j 5) 8) (* (- i 1) 8) 0)
        (spr 113 (* (+ j 5) 8) (* (- i 1) 8) 0))))) ; Fenouil : 1%

(fn manage-main-game []
  (render-game)

  (if (= nutr-affiche 0)
    (if (> nutr-delai 0)
      (set nutr-delai (- nutr-delai 1))
      (generate-nutriment))
    (render-nutriment))
  
  (if (= true (detect-collision player-x player-y 8 8 nutr-x nutr-y 8 8))
    (manage-ingere-nutriment))
  
  (manage-player-movements)
  (manage-flies)
  
  (for [i 0 5]
    (for [j 0 16]
      (spr 7 (* i 8) (* j 8))))
  
  (for [i 24 29]
    (for [j 0 16]
      (spr 7 (* i 8) (* j 8))))
      
  (print (.. "Score:\n" score) 4 4 couleur-texte true 1 true)
  (print (.. "Best Score:\n" best-score) 4 20 couleur-texte true 1 true))

(fn render-game-over []
  (cls background-color-menu)
  (set music-main 2)
  (if (or (= music-state 2) (= music-state 0))
    (reset-music-game))
  (if (not= 3 music-state)
    (play-music 3))

  (var decalage-y (* (math.sin t) 2))
  
  (for [i 0 29]
    (for [j 0 29]
      (spr 7 (* i 8) (* j 8) 0)))

  (print (.. "Score:\n" score) 4 4 couleur-texte true 1 true)

  (print (.. "Best Score:\n" best-score) 4 20 couleur-texte true 1 true)

  (print "Press space to restart" 80 (+ 100 decalage-y) couleur-texte false 1 true)
  
  (spr 4 85 10 0 8))

(fn manage-game-over []
  (if (> score best-score)
    (set best-score score))
  (render-game-over)
  (pmem 0 best-score)
  (if (= true (keyp 48))
    (restart-game)
  ))