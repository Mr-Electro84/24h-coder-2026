# Extraits de code (potentiellement utile pour jeu)

```fnl
;; Définition du prototype (la "classe")
(local Personne {})
(set Personne.__index Personne)

;; Constructeur
(fn Personne.new [nom age]
  (let [instance {:nom nom :age age}]
    (setmetatable instance Personne)))

;; Méthode
(fn Personne.saluer [self]
  (print (.. "Bonjour, je m'appelle " self.nom " et j'ai " self.age " ans.")))

;; Utilisation
(local jean (Personne.new "Jean" 30))
(jean:saluer) ; Affiche: Bonjour, je m'appelle Jean et j'ai 30 ans.
```