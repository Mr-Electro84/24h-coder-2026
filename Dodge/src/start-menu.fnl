(fn render-start-menu []
  (if (not= music-state 1)
    (play-music 1))
  (cls background-color-menu)

  (var decalage-y (* (math.sin t) 2))
  
  ; Start menu title and sub.
  (for [i 0 29]
    (for [j 0 29]
      (spr 7 (* i 8) (* j 8) 0)))

  (print (.. "Best Score:\n" best-score) 4 4 couleur-texte true 1 true)

  (print "Dodge!" 105 (+ 50 decalage-y) couleur-texte)
  (print "Press space to start" 85 (+ 80 decalage-y) couleur-texte false 1 true)

  (print "By QbitSoft" 190 125 couleur-texte true 1 true)

  (spr 5 (- 15 32) (- 35 32) 0 8)
  (spr 6 (+ 15 32) (- 35 32) 0 8)
  (spr 21 (- 15 32) (+ 35 32) 0 8)
  (spr 22 (+ 15 32) (+ 35 32) 0 8)
  (spr 1 15 35 0 8)
  (spr 33 165 35 0 8))

(fn manage-start-menu [] ; State 0. Start menu.
  (render-start-menu)

  ; QUAND bouton flèche haut préssée Jouer un son et passe en mode jeu si on est dans le start menu
  (if (= true (keyp 48))
    (change-state 0 c5 1)))