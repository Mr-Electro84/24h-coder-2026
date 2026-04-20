(fn abs [n]
  (if (< n 0) (- 0 n) n))

(fn clamp [value low high]
  (math.min high (math.max low value)))

(fn list-length [xs]
  (# xs))

(fn in-rect? [mx my x y w h]
  (and (>= mx x) (<= mx (+ x w))
       (>= my y) (<= my (+ y h))))

(fn dist2 [ax ay bx by]
  (let [dx (- ax bx) dy (- ay by)]
    (+ (* dx dx) (* dy dy))))

(fn aabb-overlap [ax ay aw ah bx by bw bh]
  (and (< ax (+ bx bw))
       (< bx (+ ax aw))
       (< ay (+ by bh))
       (< by (+ ay ah))))