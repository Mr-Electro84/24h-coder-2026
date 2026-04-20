(fn start-sound-sequence [steps]
  (set sound-sequence {:steps steps :index 1 :timer 0}))

(fn update-sound-sequence []
  (when sound-sequence
    (if (> sound-sequence.timer 0)
      (set sound-sequence.timer (- sound-sequence.timer 1))
      (if (<= sound-sequence.index (list-length sound-sequence.steps))
        (let [step (. sound-sequence.steps sound-sequence.index)]
          (sfx step.id step.note step.duration step.channel step.volume step.speed)
          (set sound-sequence.index (+ sound-sequence.index 1))
          (set sound-sequence.timer step.wait))
        (set sound-sequence nil)))))

(fn play-jump-sound []
  (if USE-CART-SFX (sfx 0)
    (start-sound-sequence
      [{:id 0 :note "C-5" :duration 5 :channel 0 :volume 9  :speed 0 :wait 2}
       {:id 0 :note "E-5" :duration 5 :channel 0 :volume 10 :speed 0 :wait 2}
       {:id 0 :note "G-5" :duration 6 :channel 0 :volume 11 :speed 0 :wait 3}
       {:id 0 :note "C-6" :duration 8 :channel 0 :volume 12 :speed 0 :wait 4}])))

(fn play-death-sound []
  (if USE-CART-SFX (sfx 1)
    (start-sound-sequence
      [{:id 1 :note "A-4" :duration 6  :channel 1 :volume 15 :speed -1 :wait 2}
       {:id 1 :note "F-4" :duration 6  :channel 1 :volume 15 :speed -1 :wait 2}
       {:id 1 :note "D-4" :duration 8  :channel 1 :volume 14 :speed -2 :wait 3}
       {:id 1 :note "C-4" :duration 9  :channel 1 :volume 14 :speed -2 :wait 3}
       {:id 1 :note "A-3" :duration 12 :channel 1 :volume 15 :speed -3 :wait 4}
       {:id 1 :note "F-3" :duration 16 :channel 1 :volume 15 :speed -4 :wait 8}])))

(fn play-win-sound []
  (if USE-CART-SFX (sfx 3)
    (start-sound-sequence
      [{:id 3 :note "C-5" :duration 5  :channel 2 :volume 11 :speed 1 :wait 2}
       {:id 3 :note "E-5" :duration 5  :channel 2 :volume 11 :speed 1 :wait 2}
       {:id 3 :note "G-5" :duration 6  :channel 2 :volume 12 :speed 1 :wait 2}
       {:id 3 :note "C-6" :duration 7  :channel 2 :volume 13 :speed 1 :wait 2}
       {:id 3 :note "E-6" :duration 8  :channel 2 :volume 14 :speed 1 :wait 2}
       {:id 3 :note "G-6" :duration 12 :channel 2 :volume 15 :speed 1 :wait 6}])))

(fn play-clone-sound []
  (if USE-CART-SFX (sfx 2)
    (start-sound-sequence
      [{:id 2 :note "E-4" :duration 4 :channel 3 :volume 9  :speed 0 :wait 2}
       {:id 2 :note "G-4" :duration 4 :channel 3 :volume 10 :speed 0 :wait 2}
       {:id 2 :note "B-4" :duration 5 :channel 3 :volume 11 :speed 0 :wait 2}
       {:id 2 :note "E-5" :duration 8 :channel 3 :volume 12 :speed 0 :wait 4}])))