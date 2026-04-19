(fn play-music [musi]
  (music musi)
  (set music-start-time t)
  (set music-state musi))

(fn reset-music-game []
  (music -1)
  (set music-start-time 0)
  (set music-state -1)
  (set game-start-time t))

(fn start-game-music-logic []
  (set game-start-time t)
  (music -1)
  (set music-state -1))