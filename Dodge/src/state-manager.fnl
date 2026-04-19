(fn switch-state [btn next-state]
  (if (= true btn)
    (set state next-state)))

(fn change-state [sfx-id sfx-note new-state]
  (sfx sfx-id sfx-note (* 60 3))
  (set state new-state)
  (set is-initializing-game true))

(fn change-state [sfx-id sfx-note new-state]
  (sfx sfx-id sfx-note -1)
  (set state new-state))