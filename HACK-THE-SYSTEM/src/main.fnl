;; ============================================================
;; HACK THE SYSTEM — Platformer Fennel/TIC-80
;; Inspiré de Celeste & Super Mario
;; ============================================================

;; ============================================================
;; 1. ÉTAT GLOBAL
;; ============================================================

;; script: fennel
(var couleur-fond 0)
(var couleur-texte 6)
(global etat-jeu "accueil")
(global timer 0)

;; ============================================================
;; CONSTANTES DE TUNING — modifier ici pour ajuster le feeling
;; ============================================================
(global COYOTE-MAX   6)   ;; frames de grâce après avoir quitté le bord
(global JUMP-BUFFER  6)   ;; frames de mémorisation d'un saut pressé en avance
(global DASH-FRAMES  12)  ;; durée d'un dash en frames
(global DASH-SPEED   5)   ;; vitesse du dash (axe principal)
(global DASH-DIAG    0.707) ;; facteur diagonal (= 1/√2)

;; JOUEUR
;;   dir          : 1=droite, -1=gauche (flip sprite + direction dash)
;;   coyote-timer : frames de grâce après avoir quitté le sol (Celeste)
;;   jump-buffer  : mémorise un saut pressé JUMP-BUFFER frames en avance (Celeste)
;;   dash-used    : 1 seul dash en l'air, se recharge au sol (Celeste)
;;   dash-vx/vy   : vecteur du dash courant (8 directions)
(global player
  {:x 16 :y 16 :vx 0 :vy 0 :w 16 :h 16
   :au-sol       false
   :mode-bleu    false
   :jumps        2           ;; 2 = saut sol + double saut
   :dir          1
   :coyote-timer 0
   :jump-buffer  0
   :dash-timer   0
   :dash-used    false
   :dash-vx      0
   :dash-vy      0})

;; ============================================================
;; CHECKPOINT
;;   Sauvegarde la position quand le joueur touche une tuile 15.
;;   La mort téléporte au dernier checkpoint au lieu du spawn initial.
;; ============================================================
(global checkpoint {:x 16 :y 16})

;; ============================================================
;; PARTICULES DE DASH
;;   Table de fantômes visuels créés au moment du dash.
;;   Chaque particule : {x y life max-life flip id}
;; ============================================================
(global particules [])

;; ============================================================
;; 2. DÉTECTION DE COLLISION
;; ============================================================

;; Tuiles solides (murs / sol)
(fn solide? [x y]
  (let [id (mget (// x 8) (// y 8))]
    (or (= id 5)
        (= id 21)
        ;; Le bloc 6 (rouge) est solide SI le joueur est en mode bleu
        (and (= id 6) player.mode-bleu)
        ;; Le bloc 7 (bleu) est solide SI le joueur n'est PAS en mode bleu (donc rouge)
        (and (= id 7) (not player.mode-bleu)))))

;; Tuiles mortelles (pics / malware)
(fn mortel? [x y]
  (let [id (mget (// x 8) (// y 8))]
    (or (= id 2) 
        (= id 22) 
        (= id 23) 
        (= id 9) 
        (= id 8))))

;; Mur à droite du joueur (pour wall jump)
(fn touche-mur-droite? []
  (or (solide? (+ player.x 16) (+ player.y 2))
      (solide? (+ player.x 16) (+ player.y 13))))

;; Mur à gauche du joueur
(fn touche-mur-gauche? []
  (or (solide? (- player.x 1) (+ player.y 2))
      (solide? (- player.x 1) (+ player.y 13))))

;; ============================================================
;; 3. UTILITAIRES
;; ============================================================

;; Retourne le signe d'un nombre (1, -1 ou 0)
(fn sign [n]
  (if (> n 0) 1 (if (< n 0) -1 0)))

;; Réinitialise le joueur au dernier checkpoint après mort.
;; FIX : on reste dans l'état "jeu" pour éviter de repasser par le titre.
(fn respawn []
  (set player.x checkpoint.x)
  (set player.y checkpoint.y)
  (set player.vx 0)
  (set player.vy 0)
  (set player.jumps 2)
  (set player.au-sol false)
  (set player.dash-used false)
  (set player.dash-timer 0)
  (set player.coyote-timer 0)
  (set player.jump-buffer 0)
  ;; On vide les particules orphelines pour éviter les artefacts visuels
  (tset particules 1 nil)
  (set etat-jeu "jeu"))
(fn Gameover []
  (cls )
  (print "GAME OVER !" 87 64  2)
  (print "Restart ? Press down arrow" 57 94 12)
  (print "Exit ? Press upper arrow" 57 105 12)
  (if (btn E)
      (respawn)
     )
      (if (btn A)
  	(exit))
      )
;; Réinitialise complètement le jeu (depuis l'écran titre ou victoire)
(fn full-reset []
  (set checkpoint.x 16)
  (set checkpoint.y 16)
  (respawn)
  (set etat-jeu "accueil"))

;; ============================================================
;; 4. PARTICULES — DASH TRAIL
;;   Spawne N fantômes à la position courante du joueur.
;;   Chaque frame on les fait vieillir et on les dessine en fondu.
;; ============================================================

;; Crée une salve de particules au moment du déclenchement du dash
(fn spawn-dash-particules [flip id]
  ;; On pousse 5 fantômes d'un coup pour un trail dense
  (for [i 1 5]
    (table.insert particules
      {:x    player.x
       :y    player.y
       :life 10          ;; durée de vie en frames
       :max-life 10
       :flip flip
       :id   id})))

;; Met à jour et dessine toutes les particules actives
;; La transparence est simulée en changeant la palette (poke) ou
;; en dessinant le sprite uniquement sur les frames paires/impaires.
(fn update-particules [cam-x]
  (var i 1)
  (while (<= i (# particules))
    (let [p (. particules i)]
      (set p.life (- p.life 1))
      (if (<= p.life 0)
        ;; Supprime la particule morte (swap avec la dernière pour éviter les trous)
        (do
          (tset particules i (. particules (# particules)))
          (tset particules (# particules) nil))
        (do
          ;; Dessin conditionnel : visible seulement sur les frames impaires
          ;; → crée un scintillement naturel qui imite un fondu
          (if (= (% p.life 2) 1)
            (spr p.id (- p.x cam-x) p.y 0 1 p.flip 0 2 2))
          (set i (+ i 1)))))))

;; ============================================================
;; 5. BOUCLE PRINCIPALE
;; ============================================================
(fn _G.TIC []
  (set timer (+ timer 1))

  ;; ============================
  ;; ÉCRAN TITRE
  ;; ============================
  (if (= etat-jeu "accueil")
    (do
      (cls couleur-fond)
      (print "HACK THE SYSTEM" 65 40 11)
      (if (= (% (// timer 30) 2) 0)
        (print ">> PRESS Z TO BOOT <<" 70 90 couleur-texte))
      ;; FIX : btnp (edge) et non btn (hold) pour éviter le skip immédiat
      (if (btnp 4) (set etat-jeu "jeu")))

    ;; ============================
    ;; ÉCRAN DE VICTOIRE
    ;; FIX : sorti du bloc "jeu" — branche if indépendante
    ;; ============================
    (if (= etat-jeu "victoire")
      (do
        ;; 1. Un fond qui "glitch" légèrement (alterne noir et bleu très sombre)
        (cls (if (= (% (// timer 10) 2) 0) 0 12))

        ;; 2. Effet de lévitation fluide sur le texte (grâce à math.sin)
        (var wave-y (+ 35 (* (math.sin (/ timer 10)) 5)))

        ;; Ombre portée du texte (pour le style)
        (print "ROOT ACCESS GRANTED" 16 (+ wave-y 1) 0)
        (print "ROOT ACCESS GRANTED" 15 wave-y 11)

        ;; 3. Le texte de victoire qui clignote façon terminal
        (if (= (% (// timer 20) 2) 0)
          (print ">> SYSTEM HACKED <<" 20 65 couleur-texte))

        ;; 4. Le virus (ID 256) qui saute de joie au milieu de l'écran !
        ;; math.abs et math.sin créent une courbe de rebond parfaite
        (var rebond (* (math.abs (math.sin (/ timer 8))) -15))
        (spr 256 112 (+ 100 rebond) 0 1 0 0 2 2)

        (print "Press Z to reboot" 75 120 5)
        ;; FIX : full-reset remet aussi le checkpoint à l'origine
        (if (btnp 4) (full-reset)))

      ;; ============================
      ;; MODE JEU
      ;; ============================
      (do
        (cls couleur-fond)

        ;; --- CAMÉRA HORIZONTALE ---
        (var cam-x (- player.x 120))
        (if (< cam-x 0) (set cam-x 0))

        ;; --- CAMÉRA VERTICALE ---
        ;; FIX : la caméra suit le joueur sur Y avec un décalage centré.
        ;; On clamp à 0 pour ne pas afficher sous la map.
        (var cam-y (- player.y 68))
        (if (< cam-y 0) (set cam-y 0))

        ;; Rendu de la map avec les deux offsets caméra
        (map (// cam-x 8) (// cam-y 8) 32 17
             (- 0 (% cam-x 8))
             (- 0 (% cam-y 8)))

        ;; --- ÉTAT PRÉCÉDENT (pour coyote time) ---
        (var etait-au-sol player.au-sol)

        ;; --- DÉCRÉMENT DES TIMERS ---
        (if (> player.coyote-timer 0)
          (set player.coyote-timer (- player.coyote-timer 1)))
        (if (> player.jump-buffer 0)
          (set player.jump-buffer (- player.jump-buffer 1)))

        ;; --- SWITCH COULEUR (Bouton A / Touche Q ou A sur clavier) ---
        (if (btnp 6)
          (set player.mode-bleu (not player.mode-bleu)))

        ;; --- MISE À JOUR DIRECTION ---
        (if (btn 3) (set player.dir  1))
        (if (btn 2) (set player.dir -1))

        ;; --- DÉTECTION MURS LATÉRAUX ---
        (var sur-mur-droite (touche-mur-droite?))
        (var sur-mur-gauche (touche-mur-gauche?))
        (var sur-mur (and (not player.au-sol)
                          (or sur-mur-droite sur-mur-gauche)))

        ;; -----------------------------------------------
        ;; B. PHYSIQUE HORIZONTALE & DASH
        ;; -----------------------------------------------
        (if (> player.dash-timer 0)
          (do
            ;; Pendant le dash : applique le vecteur pré-calculé
            ;; et neutralise la gravité (feeling Celeste)
            (set player.dash-timer (- player.dash-timer 1))
            (set player.vx player.dash-vx)
            (set player.vy player.dash-vy))
          (do
            ;; Contrôles normaux avec accélération et vitesse max
            (if (btn 3) (set player.vx (math.min (+ player.vx 0.8)  3)))
            (if (btn 2) (set player.vx (math.max (- player.vx 0.8) -3)))
            ;; Friction : s'arrête progressivement si aucune touche
            (if (not (or (btn 2) (btn 3)))
              (set player.vx (* player.vx 0.75)))))

        ;; Déclenchement Dash (bouton X) — 8 directions
        ;; La direction dépend des touches directionnelles au moment du dash
        (if (and (btnp 5) (not player.dash-used))
          (do
            (var dvx (* player.dir DASH-SPEED))
            (var dvy (if (btn 0) (- DASH-SPEED) (if (btn 1) DASH-SPEED 0)))
            ;; Normalisation diagonale : vitesse constante dans toutes les directions
            ;; (= 1/√2 ≈ 0.707 stocké dans la constante DASH-DIAG)
            (if (and (~= dvx 0) (~= dvy 0))
              (do
                (set dvx (* dvx DASH-DIAG))
                (set dvy (* dvy DASH-DIAG))))
            (set player.dash-vx dvx)
            (set player.dash-vy dvy)
            (set player.dash-timer DASH-FRAMES)
            (set player.dash-used true)
            ;; Spawn du trail de particules au moment du déclenchement
            (var flip (if (= player.dir -1) 1 0))
            (var id (if player.mode-bleu 258 256))
            (spawn-dash-particules flip id)))

        ;; --- COLLISION HORIZONTALE ---
        (var futur-x (+ player.x player.vx))
        (var offset-x (if (> player.vx 0) 15 0))
        (if (or (solide? (+ futur-x offset-x) (+ player.y 2))
                (solide? (+ futur-x offset-x) (+ player.y 13)))
          (set player.vx 0)
          (set player.x futur-x))

        ;; -----------------------------------------------
        ;; C. PHYSIQUE VERTICALE
        ;; -----------------------------------------------

        ;; Wall slide : ralentit la chute sur un mur (Celeste)
        (if (and sur-mur (> player.vy 0))
          (set player.vy (math.min player.vy 1.5)))

        ;; Gravité variable : lâcher Z coupe le saut (style Mario)
        ;; Pas de gravité pendant le dash
        (if (= player.dash-timer 0)
          (do
            (var gravite
              (if (and (< player.vy 0) (not (btn 4))) 1.1 0.5))
            (set player.vy (math.min (+ player.vy gravite) 8))))

        ;; --- COLLISION VERTICALE ---
        (var futur-y (+ player.y player.vy))

        ;; FIX : Collision PLAFOND
        (if (and (< player.vy 0)
                 (or (solide? player.x           futur-y)
                     (solide? (+ player.x 15)    futur-y)))
          (do
            ;; Snap au bas de la tuile plafond
            (set futur-y (* (+ (// futur-y 8) 1) 8))
            (set player.vy 0)))

        ;; Collision SOL
        (if (and (> player.vy 0)
                 (or (solide? player.x           (+ futur-y 16))
                     (solide? (+ player.x 15)    (+ futur-y 16))))
          (do
            ;; Snap grille : aligne le bas du joueur sur le haut de la tuile
            (set futur-y (- (* (// (+ futur-y 16) 8) 8) 16))
            (set player.vy 0)
            (set player.au-sol true)
            (set player.jumps 2)
            (set player.dash-used false))  ;; Recharge du dash au sol
          (set player.au-sol false))

        (set player.y futur-y)

        ;; Coyote time : fenêtre de grâce si on vient de quitter le bord
        ;; Durée contrôlée par la constante COYOTE-MAX
        (if (and etait-au-sol (not player.au-sol))
          (set player.coyote-timer COYOTE-MAX))

        ;; -----------------------------------------------
        ;; D. LOGIQUE DE SAUT
        ;; -----------------------------------------------

        ;; Buffer : mémorise le saut JUMP-BUFFER frames à l'avance
        (if (btnp 4)
          (set player.jump-buffer JUMP-BUFFER))

        ;; Wall Jump (priorité sur saut normal)
        (if (and sur-mur (> player.jump-buffer 0))
          (do
            (set player.vy -5.5)
            ;; Rebond dans la direction opposée au mur
            (set player.vx (* (if sur-mur-droite -1 1) 3.5))
            (set player.jump-buffer 0))

          ;; Saut normal / coyote / double saut
          (if (and (> player.jump-buffer 0)
                   (or player.au-sol
                       (> player.coyote-timer 0)
                       (> player.jumps 0)))
            (do
              (set player.vy -6)
              (set player.jump-buffer 0)
              (set player.coyote-timer 0)
              (if (> player.jumps 0)
                (set player.jumps (- player.jumps 1))))))

        ;; -----------------------------------------------
        ;; -----------------------------------------------
        ;; E. MORT & REBOOT
        ;; -----------------------------------------------
        ;; Le plancher de la mort s'adapte automatiquement à l'étage actuel !
        (var plancher-mortel (+ checkpoint.y 150))

        (if (or (> player.y plancher-mortel)
                (mortel? (+ player.x 8) (+ player.y 8)))
          (Gameover))
        ;; -----------------------------------------------
        ;; F. RENDU
        ;; -----------------------------------------------

        ;; Mise à jour et dessin du trail de dash AVANT le joueur
        ;; (les fantômes s'affichent derrière le sprite principal)
        (update-particules cam-x)

        ;; FIX : flip horizontal selon la direction du joueur
        (var flip (if (= player.dir -1) 1 0))
        (var id (if player.mode-bleu 258 256))
        (spr id (- player.x cam-x) (- player.y cam-y) 0 1 flip 0 2 2)

        ;; -----------------------------------------------
        ;; G. PORTAIL, CHECKPOINTS ET OBJECTIF FINAL
        ;; -----------------------------------------------
        (let [tuile-actuelle (mget (// (+ player.x 8) 8) (// (+ player.y 8) 8))]

          ;; 1. Le portail de téléportation (IDs 10, 11, 26, 27)
          (if (or (= tuile-actuelle 10) (= tuile-actuelle 11)
                  (= tuile-actuelle 26) (= tuile-actuelle 27))
            (do
              ;; On déplace le joueur
              (set player.x (* 83 8))
              (set player.y (* 133 8))
              (set player.vx 0)
              (set player.vy 0)
              ;; HACK : On met à jour le checkpoint IMMÉDIATEMENT
              ;; Comme ça, si on meurt au niveau 2, on réapparaît ICI.
              (set checkpoint.x player.x)
              (set checkpoint.y player.y)))
          ;; 2. Checkpoint (ID 15) — sauvegarde la position courante
          ;;    Le joueur réapparaîtra ici après une mort au lieu du spawn initial.
          (if (= tuile-actuelle 15)
            (do
              (set checkpoint.x player.x)
              (set checkpoint.y player.y)))

          ;; 3. Le bloc de victoire (ID 14 — à placer tout en haut du niveau 2)
          (if (= tuile-actuelle 14)
            (set etat-jeu "victoire")))

        ;; DEBUG (à commenter en prod) : affiche les valeurs clés
        ;; (print (.. "vx:" (math.floor player.vx) " vy:" (math.floor player.vy)) 2 2 7)
        ;; (print (.. "j:" player.jumps " dash:" player.dash-timer) 2 10 7)
        ;; (print (.. "coy:" player.coyote-timer " buf:" player.jump-buffer) 2 18 7)
        ;; (print (.. "ckpt:" checkpoint.x "," checkpoint.y) 2 26 7)
        )))) 
