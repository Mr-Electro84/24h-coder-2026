;; title:  Space Collider
;; author: Brigade anti-virus
;; desc:   Space Collider - Un jeu d'espace
;; script: fennel

;; -- DEBUT DEFINITIONS OBJETS --

;; ## Objet Vaisseau Utilisateur
;; Définition du prototype (la "classe")
(local Vaisseau {})
(set Vaisseau.__index Vaisseau)

;; Constructeur
(fn Vaisseau.new [num pos_x pos_y pv]
  (let [instance {:num num :pos_x pos_x :pos_y pos_y :pv pv}]
    (setmetatable instance Vaisseau)))

;; Méthodes
(fn Vaisseau.desc [self]
  (print (.. "pos x : " self.pos_x " pos y : " self.pos_y " pv : " self.pv) 45 45 12))

(fn Vaisseau.deplacer [self delta_x delta_y]
  (set self.pos_x (+ self.pos_x delta_x))
  (set self.pos_y (+ self.pos_y delta_y))
)

(fn Vaisseau.dessiner [self]
  (spr self.num self.pos_x self.pos_y -1 1 0 0 2 2)
)

(fn Vaisseau.config_skin [self num]
  (set self.num num)
)

;; ## Objet Planete
(local Planete {})
(set Planete.__index Planete)

;; Constructeur
(fn Planete.new [pos_x pos_y rayon gravite couleur]
  (let [instance {:pos_x pos_x :pos_y pos_y :rayon rayon :gravite gravite :couleur couleur}]
    (setmetatable instance Planete)))

;; Méthodes
(fn Planete.desc [self]
  (print (.. "pos x : " self.pos_x " pos y : " self.pos_y) 45 45 12))

(fn Planete.dessiner [self]
  (circ self.pos_x self.pos_y self.rayon self.couleur))

;; ## Objet Etoile
(local Etoile {})
(set Etoile.__index Etoile)

;; Constructeur
(fn Etoile.new [pos_x pos_y]
  (let [instance {:pos_x pos_x :pos_y pos_y}]
    (setmetatable instance Etoile)))

;; Méthodes
(fn Etoile.desc [self]
  (print (.. "pos x : " self.pos_x " pos y : " self.pos_y) 45 45 12))

(fn Etoile.dessiner [self]
  (spr 296 self.pos_x self.pos_y -1 1 0 0 2 2))

;; -- FIN DEFINITIONS OBJETS --

(var couleur-texte 12)  ; 6 = vert. Essaie 11 (bleu clair)
(var couleur-fond 0)  ; 12 = Blanc. Essaie 0 (Noir)

;; Variable pour l'animation
(var anim_t 0)

;; Variables d'initialisation
(var niveau 0)

(var skin_vaisseau false);;visualiser les skins

(var skin_vaisseau_select_x 0)
(var skin_vaisseau_select_y 0)


(var select_opt_menu 0)
(var musique false)

(var select_vitesse 0) ;; 0 = pas de vitesse, 1 = vitesse x, 2 = vitesse y

(var vitesse_vaisseau 0) ;; déplacement x
(var vitesse_vaisseau_y 0) ;; déplacement y

(local vaisseau (Vaisseau.new 258 5 60 100)) ;; Placer le vaisseau à gauche et au centre

(var x 0)
(var y 0)
(var D_time (time))

;; Boucle principale exécutée à 60 FPS
(fn _G.TIC []
  ;; 1. Nettoie l'écran
  (cls couleur-fond)

  ;; Lance la musique
  (when (not musique)
    (music 0)
    (set musique true)
  )
  
  ;; 2. Calcule un petit mouvement de vague
  (var decalage-y (* (math.sin anim_t) 5))

  ;; Afficher le niveau si la variable niveau est supérieur à 1
  (when (> niveau 0)
    (print (.. "Niveau : " niveau) 10 10 couleur-texte)
  )

  (if (= niveau 0) ;; Menu principal
      (do
      (map x y)
      (if (> (- (time) D_time) 50)
        (do
          (set x (+ x 1))
          (set y (+ y 1))
          (when (> x 29) (set x 0))
          (when (> y 16) (set y 0))
          (set D_time (time))
        )
      )

      ;; Fait avancer le temps (pour l'animation du texte)
      (set anim_t (+ anim_t 0.05))

      ;; Dessiner le fond
      ;;(map 0 0 30 17 0 0 -1 1)

      (print "SPACE COLLIDER" 30 (+ 35 decalage-y) couleur-texte false 2)

      ;; carré de sélection
      (if (= select_opt_menu 0) (rect 18 60 6 6 couleur-texte))
      (if (= select_opt_menu 1) (rect 18 70 6 6 couleur-texte))
      (if (= select_opt_menu 2) (rect 18 80 6 6 couleur-texte))

      ;; menu
      (print "JOUER" 30 60 couleur-texte false 1)
      (print "Skins" 30 70 couleur-texte false 1)
      (print "Configuration" 30 80 couleur-texte false 1)

      (print "Entree pour valider" 30 100 couleur-texte false 1)

      (when (and (btnp 0) (> select_opt_menu 0)) ;; bouton haut
        (set select_opt_menu (- select_opt_menu 1)))
      (when (and (btnp 1) (< select_opt_menu 2)) ;; bouton bas
        (set select_opt_menu (+ select_opt_menu 1)))

      (when (keyp 50)
        (if (= select_opt_menu 0) (set niveau 1))
        (if (= select_opt_menu 1)
          ( do
            (set skin_vaisseau true)
            (set niveau -1)
            (set D_time (time))
          )
        )
      )
      
    )
    (when (= niveau 1)
      ;; désactiver la musique
      (when musique
        (music)
        (set musique false)
      )

      (local planete1 (Planete.new 100 100 10 10 10)) ;; rappel (Planete.new pos_x pos_y rayon gravite couleur)
      (planete1:dessiner)
      (local planete2 (Planete.new 50 30 10 10 4)) ;; autre couleur et autre placement
      (planete2:dessiner)
      (local planete3 (Planete.new 200 80 10 10 12)) ;; autre couleur et autre placement
      (planete3:dessiner)
      (local etoile1 (Etoile.new 100 70)) ;; placer au dessus de planete 1
      (etoile1:dessiner)
      (local etoile2 (Etoile.new 60 60))
      (etoile2:dessiner)
      (local etoile3 (Etoile.new 220 80))
      (etoile3:dessiner)

      (vaisseau:dessiner)

      (if (= select_vitesse 0)
        (print "Espace pour commencer" 50 130 couleur-texte false 1) ;; placer le texte en bas centré
      )

      ;; Si la touche espace est pressé, le joueur configure la vitesse du vaisseau
      (if (or (and (keyp 48) (= select_vitesse 0)) (= select_vitesse 1))
        (do
          (print "Vitesse du vaisseau" 50 130 couleur-texte false 1)
          (set select_vitesse 1)
        )
      )

    )
  )
  
  (when (= skin_vaisseau true)
    (rect (+ 8 (* skin_vaisseau_select_x 30)) (+ 28 (* skin_vaisseau_select_y 30)) 20 20 2)
    (for [i 0 6]
      (spr (+ 258 (* i 2)) (+ 10 (* i 30)) 30 -1 1 0 0 2 2)
    )
    (for [i 0 1]
      (spr (+ 290 (* i 2)) (+ 10 (* i 30)) 60 -1 1 0 0 2 2)
    )
    (print "Skins" 10 10 couleur-texte false 1)
    (print "Retour" 10 100 couleur-texte false 1)

    (when (and (btnp 0) (> skin_vaisseau_select_y 0)) ;; bouton haut
      (set skin_vaisseau_select_y (- skin_vaisseau_select_y 1))
      (set skin_vaisseau_select_x 0))
    (when (and (btnp 1) (< skin_vaisseau_select_y 1)) ;; bouton bas
      (set skin_vaisseau_select_y (+ skin_vaisseau_select_y 1))
      (set skin_vaisseau_select_x 0))

    (when (and (btnp 2) (> skin_vaisseau_select_x 0)) ;; bouton gauche
      (set skin_vaisseau_select_x (- skin_vaisseau_select_x 1)))
    (when (and (btnp 3) (or (and (< skin_vaisseau_select_x 6) (= skin_vaisseau_select_y 0)) (and (< skin_vaisseau_select_x 1) (= skin_vaisseau_select_y 1)))) ;; bouton droite
      (set skin_vaisseau_select_x (+ skin_vaisseau_select_x 1)))

    (when (keyp 48);;valider avec espace
      (when (= skin_vaisseau_select_y 0)
        (vaisseau:config_skin (+ 258 (* skin_vaisseau_select_x 2)))
      )
      (when (= skin_vaisseau_select_y 1)
        (vaisseau:config_skin (+ 290 (* skin_vaisseau_select_x 2)))
      )
    )


    (when (and (keyp 50) (> (- (time) D_time) 10))
      (set skin_vaisseau false)
      (set niveau 0)
      (set D_time (time))
    )
  )
)