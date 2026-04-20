(fn update-clone [clone]
  (when clone.alive
    (if (<= clone.frame (list-length clone.inputs))
      (let [mask (. clone.inputs clone.frame)
            [left right jump] (decode-bitmask mask)]
        (update-entity clone left right jump)
        (set clone.frame (+ clone.frame 1))
        (set clone.immobile (and (= clone.vx 0) (= clone.vy 0))))
      (do (set clone.vx 0) (set clone.vy 0) (set clone.immobile true)))))

(fn update-clones []
  (each [_ clone (ipairs active-clones)] (update-clone clone))
  (rebuild-solid-clones))

(fn spawn-clones-from-recordings []
  (set active-clones [])
  (each [_ recording (ipairs ghost-recordings)]
    (table.insert active-clones
      {:x recording.start-x :y recording.start-y
       :vx 0 :vy 0 :on-ground false :dir 1
       :alive true :kind :clone :w 8 :h 16
       :frame 1 :inputs recording.inputs :immobile false}))
  (rebuild-solid-clones))

(fn save-current-run-as-clone []
  (when (< (list-length ghost-recordings) MAX-CLONES)
    (table.insert ghost-recordings
      {:inputs current-recording
       :start-x current-start-x :start-y current-start-y})
    (play-clone-sound)))