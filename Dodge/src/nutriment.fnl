(fn generate-nutriment []
  (if (> nutr-temps 30)
    (set nutr-temps (- nutr-temps 2)))
  (set nutr-delai nutr-temps)

  (set nutr-x (* (+ (math.random 16) 6) 8))
  (set nutr-y (* (math.random 15) 8))

  (local rand (math.random 5))
  (if (= rand 5)
    (set nutr-index 33)
    (set nutr-index 32))

  (set nutr-affiche 1))

(fn render-nutriment []
  (var decalage-x (* (math.cos t) 1))
  (var decalage-y (* (math.sin t) 2))
  (spr 34 (+ nutr-x decalage-x) (+ (+ nutr-y 0 decalage-y) 4) 0)
  (spr nutr-index (+ nutr-x decalage-x) (+ nutr-y 0 decalage-y) 0))

(fn manage-ingere-nutriment []
  (set nutr-x -1)
  (set nutr-y -1)

  (set nutr-affiche 0)

  (if (= nutr-index 32)
    (set score (+ score 100))
    (set score (+ score 500)))
  
  (if (= nutr-index 32)
    (sfx 1 c6 -1)
    (sfx 2 c6 -1))
  
  (if (= nutr-index 32)
    (set chad-mult (* 1.01 chad-mult))
    (set chad-mult (* 1.05 chad-mult))))