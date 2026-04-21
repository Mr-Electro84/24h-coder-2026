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
  ;; On ajoute les variables vx et vy (la vélocité) ainsi que l'angle
  (let [instance {:num num :pos_x pos_x :pos_y pos_y :pv pv :vx 0 :vy 0 :angle 0}]
    (setmetatable instance Vaisseau)))


;; Méthodes
(fn Vaisseau.desc [self]
  (print (.. "pos x : " self.pos_x " pos y : " self.pos_y " pv : " self.pv) 45 45 12))

(fn Vaisseau.deplacer [self delta_x delta_y]
  (set self.pos_x (+ self.pos_x delta_x))
  (set self.pos_y (+ self.pos_y delta_y))
)

(fn Vaisseau.dessiner [self]
  (spr self.num self.pos_x self.pos_y 0 1 0 0 2 2)
)

(fn Vaisseau.config_skin [self num]
  (set self.num num)
)

;; ## Objet Planete
(local Planete {})
(set Planete.__index Planete)

;; Constructeur
(fn Planete.new [pos_x pos_y rayon_gravite gravite id_sprite]
  (let [instance {:pos_x pos_x :pos_y pos_y :rayon_gravite rayon_gravite :gravite gravite :id_sprite id_sprite}]
    (setmetatable instance Planete)))

;; Id de sprites pour les planetes : 386 - Terre | 390 - Magma | 394 - Forêt | 450 - Métal | 454 - Trou noir

;; Méthodes
(fn Planete.desc [self]
  (print (.. "pos x : " self.pos_x " pos y : " self.pos_y) 45 45 12))

(fn Planete.dessiner [self]
  (spr self.id_sprite self.pos_x self.pos_y 0 1 0 0 4 4))

;; ## Objet Etoile
(local Etoile {})
(set Etoile.__index Etoile)

;; Constructeur
(fn Etoile.new [pos_x pos_y]
  (let [instance {:pos_x pos_x :pos_y pos_y :prise false}]
    (setmetatable instance Etoile)))

;; Méthodes
(fn Etoile.desc [self]
  (print (.. "pos x : " self.pos_x " pos y : " self.pos_y) 45 45 12))

(fn Etoile.dessiner [self]
  (spr 296 self.pos_x self.pos_y 0 1 0 0 2 2))

;; ## Objet astéroide
(local Asteroide {})
(set Asteroide.__index Asteroide)

;; Constructeur
(fn Asteroide.new [pos_x pos_y]
  (let [instance {:pos_x pos_x :pos_y pos_y :prise false}]
    (setmetatable instance Asteroide)))

;; Méthodes
(fn Asteroide.desc [self]
  (print (.. "pos x : " self.pos_x " pos y : " self.pos_y) 45 45 12))

(fn Asteroide.dessiner [self]
  (spr 330 self.pos_x self.pos_y 0 1 0 0 2 2))

;; -- FIN DEFINITIONS OBJETS --

(var couleur-texte 12)  ; 6 = vert. Essaie 11 (bleu clair)
(var couleur-fond 0)  ; 12 = Blanc. Essaie 0 (Noir)

;; Variable pour l'animation
(var anim_t 0)

;; Variables d'initialisation
(var niveau 0)
(var select_opt_menu 0)
(var musique false)

(var skin_vaisseau false) ;; visualiser les skins
(var skin_vaisseau_select_x 0)
(var skin_vaisseau_select_y 0)

(var bande_son 0)
(var timer_sfx 0) ;; Timer pour relancer la musique après un effet sonore

(var select_vitesse 0) ;; 0 = pas de vitesse, 1 = vitesse x, 2 = vitesse y

(var vitesse_vaisseau 0) ;; déplacement x
(var placement_vaisseau 0) ;; placement (sur l'axe y)

(var etoiles_prises 0)
(var etoiles_requises 3)

(var etoiles [])
(var planetes [])
(var asteroides [])

(var caillou_1 30)
(var caillou_2 90)
(var caillou_3 40)
(var caillou_4 100)
(var caillou_5 20)
(var caillou_6 80)

(local vaisseau (Vaisseau.new 258 5 60 100)) ;; Placer le vaisseau à gauche et au centre

(fn reinitialiser_niveau [n]
  (set etoiles_prises 0)
  (set asteroides [])
  (if (= n 1)
    (do
      (set etoiles [
        (Etoile.new 100 70)
        (Etoile.new 60 60)
        (Etoile.new 220 60)
      ])
      (set planetes [
        (Planete.new 100 100 50 10 390)
        (Planete.new 50 25 50 12 386)
        (Planete.new 200 90 30 5 394)
      ])
    )
    (= n 2)
    (do
      (set etoiles [
        (Etoile.new 140 50)
        (Etoile.new 60 70)
        (Etoile.new 200 60)
      ])
      (set planetes [
        (Planete.new 60 30 40 8 386)   ;; Terre (id 386)
        (Planete.new 120 100 50 15 450) ;; Métal (id 450)
        (Planete.new 180 30 45 10 390)  ;; Magma (id 390)
        (Planete.new 200 110 35 6 394)  ;; Forêt (id 394)
      ])
    )
    (= n 3)
    (do
      (set etoiles [
        (Etoile.new 140 90)
        (Etoile.new 90 40)
        (Etoile.new 200 60)
      ])
      (set planetes [
        (Planete.new 60 40 60 25 454) ;; Trou Noir (id 454)
        (Planete.new 120 50 40 8 386)   ;; Terre (id 386)
        (Planete.new 170 30 45 10 390)  ;; Magma (id 390)
        (Planete.new 200 90 35 25 454)  ;; Trou Noir (id 454)
      ])
    )
    (= n 4)
    (do
      (set etoiles [
        (Etoile.new 90 90)
        (Etoile.new 90 40)
        (Etoile.new 130 20)
      ])
      (set planetes [
        ;;(Planete.new 100 40 60 25 454) ;; Trou Noir (id 454)
        (Planete.new 50 70 35 6 394)  ;; Forêt (id 394)
        (Planete.new 100 60 40 8 386)   ;; Terre (id 386)
        (Planete.new 110 30 45 10 390)  ;; Magma (id 390)
        (Planete.new 60 30 35 25 454)  ;; Trou Noir (id 454)
      ])
    )
    (= n 5)
    (do
      (set etoiles [
        (Etoile.new 120 50)  ;; Étoile au centre
        (Etoile.new 150 70)  ;; Étoile au dessus de la forêt
        (Etoile.new 180 90)  ;; Étoile au dessus de la Terre
      ])
      (set planetes [
        (Planete.new 100 80 40 8 386)   ;; Terre (id 386)
        (Planete.new 150 95 35 6 394)  ;; Forêt (id 394)
      ])
      ;; Ajouter 1 astéroide
      (set asteroides [
        (Asteroide.new 180 70) ;; Astéroïde au dessus de l'étoile de Terre
      ])
    )
    (= n 6)
    (do
      (set etoiles [
        (Etoile.new 110 90)  ;; Étoile au centre
        (Etoile.new 150 70)  ;; Étoile au dessus de la forêt
        (Etoile.new 180 30)  ;; Étoile au dessus de la Terre
      ])
      (set planetes [
        (Planete.new 60 80 40 8 386)   ;; Terre (id 386)
        (Planete.new 110 50 35 6 394)  ;; Forêt (id 394)
        (Planete.new 150 90 45 10 390)  ;; Magma (id 390)
        (Planete.new 150 30 50 15 450) ;; Métal (id 450)
      ])
      ;; Ajouter 1 astéroide
      (set asteroides [
        (Asteroide.new 50 30) ;; Astéroïde au dessus de l'étoile de Terre
        (Asteroide.new 50 70) ;; Astéroïde au dessus de l'étoile de Terre
        (Asteroide.new 110 40) ;; Astéroïde au dessus de l'étoile de Terre
      ])
    )
    (= n 7)
    (do
      (set etoiles [
        (Etoile.new 110 90)  ;; Étoile au centre
        (Etoile.new 150 70)  ;; Étoile au dessus de la forêt
        (Etoile.new 180 30)  ;; Étoile au dessus de la Terre
      ])
      (set planetes [
        (Planete.new 200 60 50 25 454)   ;; Trou Noir (id 454)
        (Planete.new 60 60 40 8 386)   ;; Terre (id 386)

        (Planete.new 110 50 35 6 394)  ;; Forêt (id 394)
        (Planete.new 150 90 45 10 390)  ;; Magma (id 390)
        (Planete.new 150 30 50 15 450) ;; Métal (id 450)
      ])
      ;; Ajouter 1 astéroide
      (set asteroides [
        (Asteroide.new 50 caillou_1) ;; Astéroïde au dessus de l'étoile de Terre
        (Asteroide.new 50 caillou_2) ;; Astéroïde au dessus de l'étoile de Terre
        (Asteroide.new 110 caillou_3) ;; Astéroïde au dessus de l'étoile de Terre
        (Asteroide.new 110 caillou_4) ;; Astéroïde au dessus de l'étoile de Terre
        (Asteroide.new 170 caillou_5)
        (Asteroide.new 170 caillou_6) ;; Astéroïde au dessus de l'étoile de Terre
      ])
    ) 
  )

  (set vaisseau.pos_x 5)
  (set vaisseau.pos_y 60)
  (set vaisseau.vx 0)
  (set vaisseau.vy 0)
  (set select_vitesse 0)
  (set vitesse_vaisseau 5)
)

(var x 0)
(var y 0)
(var D_time (time))

;; Boucle principale exécutée à 60 FPS
(fn _G.TIC []
  ;; 1. Nettoie l'écran
  (cls couleur-fond)

  ;; Gestion du timer pour relancer la musique après un bruitage
  (when (> timer_sfx 0)
    (set timer_sfx (- timer_sfx 1))
    (when (= timer_sfx 0)
      (set musique false)
    )
  )

  ;; Lance la musique
  (when (and (= bande_son 0) (not musique))
    (music 4)
    (set musique true)
  )
  
  ;; 2. Calcule un petit mouvement de vague
  (var decalage-y (* (math.sin anim_t) 5))

  ;; Afficher le niveau si la variable niveau est supérieur à 1
  (when (> niveau 0)
    (print (.. "Niveau : " niveau) 5 10 couleur-texte)
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

      (print "SPACE COLLIDER" 30 (+ 35 decalage-y) couleur-texte false 2)

      ;; carré de sélection
      (if (= select_opt_menu 0) (rect 18 60 6 6 couleur-texte))
      (if (= select_opt_menu 1) (rect 18 70 6 6 couleur-texte))

      ;; menu
      (print "JOUER" 30 60 couleur-texte false 1)
      (print "Skins" 30 70 couleur-texte false 1)

      (print "ENTREE pour valider" 30 100 couleur-texte false 1)

      (when (and (btnp 0) (> select_opt_menu 0)) ;; bouton haut
        (set select_opt_menu (- select_opt_menu 1)))
      (when (and (btnp 1) (< select_opt_menu 1)) ;; bouton bas
        (set select_opt_menu (+ select_opt_menu 1)))

      (when (keyp 50)
        ;; Si on démarre le jeu (JOUER)
        (if (= select_opt_menu 0) 
          (do
            (set niveau 1)
            (reinitialiser_niveau niveau)
          )
        )
        ;; Si on sélectionne "SKINS"
        (if (= select_opt_menu 1)
          (do
            (set skin_vaisseau true)
            (set niveau -1)
            (set D_time (time))
          )
        )
      )

      
    )
    (when (> niveau 0)
      ;; désactiver la musique
      (when (and musique (= bande_son 0))
        (music)
        (set musique false)
        (set bande_son 1)
      )

      ;; Lance la musique
      (when (and (= bande_son 1) (not musique))
        (music 0)
        (set musique true)
      )

      ;; Dessiner les planètes du niveau actuel
      (for [i 1 (# planetes)]
        (let [p (. planetes i)]
          (p:dessiner)))

      ;; Gestion et affichage des étoiles
      (for [i 1 (# etoiles)]
        (let [e (. etoiles i)]
          (when (not e.prise)
            ;; On calcule la distance (les sprites font 16x16, on centre à +8)
            (let [dx (- (+ e.pos_x 8) (+ vaisseau.pos_x 8))
                  dy (- (+ e.pos_y 8) (+ vaisseau.pos_y 8))
                  dist (math.sqrt (+ (* dx dx) (* dy dy)))]
              (when (< dist 12)
                (set e.prise true)
                (set etoiles_prises (+ etoiles_prises 1))
                ;; Jouer la piste audio correspondante à l'événement
                (if (= etoiles_prises etoiles_requises)
                  (do
                    (music 1 -1 -1 false) ;; Track 1: Niveau terminé
                    (set timer_sfx 100) ;; Reprend la musique après ~1.6 sec
                  )
                  (do
                    (music 2 -1 -1 false) ;; Track 2: Etoile collectée
                    (set timer_sfx 45) ;; Reprend la musique après ~0.75 sec
                  )
                )
              )
            )
            (e:dessiner))))

      ;; Gestion et affichage des astéroides
      (when (= niveau 7) (do
        (if (< caillou_1 -16) (set caillou_1 140))
        (if (< caillou_2 -16) (set caillou_2 140))
        (if (> caillou_3 140) (set caillou_3 -16))
        (if (> caillou_4 140) (set caillou_4 -16))
        (if (< caillou_5 -16) (set caillou_5 140))
        (if (< caillou_6 -16) (set caillou_6 140))
      
        ;; Animation des cailloux avec une vitesse réduite
        (set caillou_1 (- caillou_1 1))
        (set caillou_2 (- caillou_2 2))
        (set caillou_3 (+ caillou_3 1))
        (set caillou_4 (+ caillou_4 2))
        (set caillou_5 (- caillou_5 1))
        (set caillou_6 (- caillou_6 2))
        
        ;; Configuration séquentielle propre et sécurisée
        (let [n (length asteroides)]
          (when (> n 0) (tset (. asteroides 1) :pos_y caillou_1))
          (when (> n 1) (tset (. asteroides 2) :pos_y caillou_2))
          (when (> n 2) (tset (. asteroides 3) :pos_y caillou_3))
          (when (> n 3) (tset (. asteroides 4) :pos_y caillou_4))
          (when (> n 4) (tset (. asteroides 5) :pos_y caillou_5))
          (when (> n 5) (tset (. asteroides 6) :pos_y caillou_6)))
      ))

      (for [i 1 (# asteroides)]
        (let [a (. asteroides i)]
          (when (not a.prise)
            ;; On calcule la distance (les sprites font 16x16, on centre à +8)
            (let [dx (- (+ a.pos_x 8) (+ vaisseau.pos_x 8))
                  dy (- (+ a.pos_y 8) (+ vaisseau.pos_y 8))
                  dist (math.sqrt (+ (* dx dx) (* dy dy)))]
              (when (< dist 12)
                (music 3 -1 -1 false) ;; Track 3: Dégâts / Astéroide
                (set timer_sfx 50) ;; Reprend la musique après ~0.8 sec
                (reinitialiser_niveau niveau)
              )
            )
            (a:dessiner))))

      (vaisseau:dessiner)
      
      ;; Affichage du compteur d'étoiles
      (print (.. "Etoiles : " etoiles_prises "/" etoiles_requises) 5 2 couleur-texte)

      ;; Victoire
      (when (>= etoiles_prises etoiles_requises)
        (print "NIVEAU TERMINE !" 40 60 11 false 2)
        (if (< niveau 7)
          (print "Presser Entree pour le niveau suivant" 30 80 11 false 1)
        )
        (when (keyp 50)
          (if (< niveau 7)
            (do
              (set niveau (+ niveau 1))
              (reinitialiser_niveau niveau)
            )
            (do
              (set niveau 0)
            )
          )
        )
      )

      ;; Réinitialisation niveau en appuyant sur BACKSPACE (51)
      (when (keyp 51)
        (reinitialiser_niveau niveau)
      )

      (if (= select_vitesse 0)
        (do
          (print "Espace pour commencer" 50 130 couleur-texte false 1)
          (print (.. "Vitesse: " (math.floor (* vitesse_vaisseau 10))) 50 120 couleur-texte false 1)
          
          ;; Placement du vaisseau (Haut / Bas)
          (when (btn 0) (set vaisseau.pos_y (math.max 0 (- vaisseau.pos_y 1))))
          (when (btn 1) (set vaisseau.pos_y (math.min 136 (+ vaisseau.pos_y 1))))
          
          ;; Configuration de la vitesse (Gauche / Droite)
          (when (btn 2) 
            (set vitesse_vaisseau (math.max 0 (- vitesse_vaisseau 0.05))))
          (when (btn 3) 
            (set vitesse_vaisseau (math.min 10 (+ vitesse_vaisseau 0.05))))
        )
      )

      ;; Lancement de la physique une fois l'espace pressé
      (if (or (and (keyp 48) (= select_vitesse 0)) (= select_vitesse 1))
        (do
          (if (= select_vitesse 0) 
            (do
              ;; L'impulsion initiale est appliquée au moment exact du lancement
              (set vaisseau.vx vitesse_vaisseau)
              (set select_vitesse 1)
            )
          )

          ;; --- DEBUT DE LA PHYSIQUE ET GRAVITE ---
          
          ;; Calcul vectoriel complet pour la gravité en parcourant la liste planetes
          (for [i 1 (# planetes)]
            (let [p (. planetes i)]
              (let [
                dx (- (+ p.pos_x 16) (+ vaisseau.pos_x 8))
                dy (- (+ p.pos_y 16) (+ vaisseau.pos_y 8))
                dist (math.sqrt (+ (* dx dx) (* dy dy)))
                ;; Empêcher la distance de tomber trop bas pour éviter une division par zéro/infinité
                dist (math.max dist 10)

                nx (/ dx dist)
                ny (/ dy dist)

                ;; Calcul de la force : On utilise p.rayon_gravite du "main" au lieu de la constante 90 (si désiré)
                force (if (< dist p.rayon_gravite) ;; ou (< dist 90) selon le rendu voulu
                        (/ p.gravite dist) ;; ou (/ 2 dist) 
                        0)
              ]
                ;; On ajoute la force de cette planète à la vélocité actuelle du vaisseau
                (set vaisseau.vx (+ vaisseau.vx (* nx force)))
                (set vaisseau.vy (+ vaisseau.vy (* ny force))))))

          ;; On applique la vélocité totale retenue sur le déplacement du vaisseau
          (vaisseau:deplacer vaisseau.vx vaisseau.vy)

          ;; Amortissement (damping) - Simule un léger frein ou frottement pour ne pas accélérer infiniment
          (set vaisseau.vx (* vaisseau.vx 0.97))
          (set vaisseau.vy (* vaisseau.vy 0.97))
          
          ;; --- FIN DE LA PHYSIQUE ET GRAVITE ---

        )
      )

    )
  )
    ;; === MENU DE SÉLECTION DE SKIN ===
  (when (= skin_vaisseau true)
    
    ;; Rectangle de sélection
    (rect (+ 8 (* skin_vaisseau_select_x 30)) (+ 28 (* skin_vaisseau_select_y 30)) 20 20 2)
    
    ;; Première ligne de skins
    (for [i 0 6]
      (spr (+ 258 (* i 2)) (+ 10 (* i 30)) 30 0 1 0 0 2 2)
    )
    ;; Deuxième ligne de skins
    (for [i 0 1]
      (spr (+ 290 (* i 2)) (+ 10 (* i 30)) 60 0 1 0 0 2 2)
    )
    
    (print "Skins (ESPACE pour valider)" 10 10 couleur-texte false 1)
    (print "ENTREE pour retourner" 10 100 couleur-texte false 1)

    ;; Mouvements du curseur
    (when (and (btnp 0) (> skin_vaisseau_select_y 0)) ;; Haut
      (set skin_vaisseau_select_y (- skin_vaisseau_select_y 1))
      (set skin_vaisseau_select_x 0))
      
    (when (and (btnp 1) (< skin_vaisseau_select_y 1)) ;; Bas
      (set skin_vaisseau_select_y (+ skin_vaisseau_select_y 1))
      (set skin_vaisseau_select_x 0))

    (when (and (btnp 2) (> skin_vaisseau_select_x 0)) ;; Gauche
      (set skin_vaisseau_select_x (- skin_vaisseau_select_x 1)))
      
    (when (and (btnp 3) (or (and (< skin_vaisseau_select_x 6) (= skin_vaisseau_select_y 0)) 
                            (and (< skin_vaisseau_select_x 1) (= skin_vaisseau_select_y 1)))) ;; Droite
      (set skin_vaisseau_select_x (+ skin_vaisseau_select_x 1)))

    ;; Valider un skin avec ESPACE
    (when (keyp 48)
      (when (= skin_vaisseau_select_y 0)
        (vaisseau:config_skin (+ 258 (* skin_vaisseau_select_x 2)))
      )
      (when (= skin_vaisseau_select_y 1)
        (vaisseau:config_skin (+ 290 (* skin_vaisseau_select_x 2)))
      )
    )

    ;; Retourner au menu principal avec ENTREE (et empêcher les double-inputs avec un délai)
    (when (and (keyp 50) (> (- (time) D_time) 10))
      (set skin_vaisseau false)
      (set niveau 0)
      (set D_time (time))
    )
  )
)