;; title:  Space Collider
;; author: Brigade anti-virus
;; desc:   Space Collider - Un jeu d'espace
;; script: fennel

;; -- DEBUT DEFINITIONS OBJETS --

;; ## Objet Vaisseau Utilisateur
(local Vaisseau {})
(set Vaisseau.__index Vaisseau)

(fn Vaisseau.new [num pos_x pos_y pv]
  (let [instance {:num num :pos_x pos_x :pos_y pos_y :pv pv :vx 0 :vy 0 :angle 0}]
    (setmetatable instance Vaisseau)))

(fn Vaisseau.desc [self]
  (print (.. "pos x : " self.pos_x " pos y : " self.pos_y " pv : " self.pv) 45 45 12))

(fn Vaisseau.deplacer [self delta_x delta_y]
  (set self.pos_x (+ self.pos_x delta_x))
  (set self.pos_y (+ self.pos_y delta_y)))

(fn Vaisseau.dessiner [self]
  (spr self.num self.pos_x self.pos_y -1 1 0 0 2 2))

;; ## Objet Planete
(local Planete {})
(set Planete.__index Planete)

(fn Planete.new [pos_x pos_y rayon gravite couleur]
  (let [instance {:pos_x pos_x :pos_y pos_y :rayon rayon :gravite gravite :couleur couleur}]
    (setmetatable instance Planete)))

(fn Planete.desc [self]
  (print (.. "pos x : " self.pos_x " pos y : " self.pos_y) 45 45 12))

(fn Planete.dessiner [self]
  (circ self.pos_x self.pos_y self.rayon self.couleur))

;; -- FIN DEFINITIONS OBJETS --

(var couleur-texte 12)
(var couleur-fond 0)
(var anim_t 0)

(var niveau 0)
(var select_opt_menu 0)
(var musique false)

(local vaisseau (Vaisseau.new 258 5 60 100))

;; draw planets (FIXED CALLS)
(local planete1 (Planete.new 100 100 10 10 10))
(local planete2 (Planete.new 50 50 10 10 4))
(local planete3 (Planete.new 200 80 10 10 12))

;; ✅ correction minimale
(local planetes [planete1 planete2 planete3])

;; Boucle principale exécutée à 60 FPS
(fn _G.TIC []
  (cls couleur-fond)

  ;; music
  (when (not musique)
    (music 0)
    (set musique true))

  ;; animation menu
  (var decalage-y (* (math.sin anim_t) 5))

  ;; =========================
  ;; MENU
  ;; =========================
  (if (= niveau 0)
      (do
        (set anim_t (+ anim_t 0.05))

        (print "SPACE COLLIDER" 30 (+ 35 decalage-y) couleur-texte false 2)

        (if (= select_opt_menu 0) (rect 18 60 6 6 couleur-texte))
        (if (= select_opt_menu 1) (rect 18 70 6 6 couleur-texte))
        (if (= select_opt_menu 2) (rect 18 80 6 6 couleur-texte))

        (print "JOUER" 30 60 couleur-texte false 1)
        (print "Skins" 30 70 couleur-texte false 1)
        (print "Configuration" 30 80 couleur-texte false 1)

        ;; FIXED input
        (when (btnp 0) (set select_opt_menu (math.max 0 (- select_opt_menu 1))))
        (when (btnp 1) (set select_opt_menu (math.min 2 (+ select_opt_menu 1))))

        ;; start game
        (when (keyp 50)
          (if (= select_opt_menu 0)
              (set niveau 1))))
  )

  ;; =========================
  ;; GAME
  ;; =========================
  (when (= niveau 1)

    (when musique (music) (set musique false))

    ;; forward movement
    (set vaisseau.vx 1.5)

    ;; gravity (FIXED FULL VECTOR)
    (for [i 1 (# planetes)]
      (let [p (. planetes i)]
        (let [
          dx (- p.pos_x vaisseau.pos_x)
          dy (- p.pos_y vaisseau.pos_y)
          dist (math.sqrt (+ (* dx dx) (* dy dy)))
          dist (math.max dist 10)

          nx (/ dx dist)
          ny (/ dy dist)

          force (if (< dist 90)
                  (/ 2 dist)
                  0)
        ]
          (set vaisseau.vx (+ vaisseau.vx (* nx force)))
          (set vaisseau.vy (+ vaisseau.vy (* ny force))))))

    ;; move
    (vaisseau:deplacer vaisseau.vx vaisseau.vy)

    ;; damping
    (set vaisseau.vx (* vaisseau.vx 0.97))
    (set vaisseau.vy (* vaisseau.vy 0.97))

    (planete1:dessiner)
    (planete2:dessiner)
    (planete3:dessiner)

    ;; draw ship
    (vaisseau:dessiner)
  )
)