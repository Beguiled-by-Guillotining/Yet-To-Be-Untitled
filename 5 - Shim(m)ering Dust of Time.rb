loopNum = 0
curScale = chord :C3, 'm7+5-9', num_octaves: 3

set :stop, false

with_fx :level, slide: 5.0 do |l|
  define :startLoop do |name, bpm, amp, synthName|
    live_loop name.to_sym do
      use_bpm bpm
      use_synth synthName
      c = play (choose curScale), slide: 0.2, release: 0.2, pan: (rrand -1, 1), amp: amp * (rrand 0.7, 1.0)
      control c, note: (choose curScale)
      sleep [0.1, 0.2, 0.3].choose
      stop if get(:stop) and one_in(bpm * 3)
    end
  end
  
  define :startLoops do |bpm, amp|
    loopNum += 1
    startLoop 'pretty' + loopNum.to_s, bpm, amp, :pretty_bell
    startLoop 'dull' + loopNum.to_s, bpm, amp, :dull_bell
  end
  
  startLoops 60, 1.0
  startLoops 30, 0.7
  startLoops 15, 0.5
  startLoops 7.5, 0.3
  startLoops 7.5, 0.3
  startLoops 3.75, 0.2
  startLoops 3.75, 0.2
  startLoops 3.75 / 2.0, 0.15
  startLoops 3.75 / 2.0, 0.15
  startLoops 3.75 / 2.0, 0.15
  
  with_fx :reverb, mix: 0.5, room: 1 do
    live_loop :oceans do
      s = synth [:bnoise, :cnoise, :gnoise].choose, amp: (rrand 0.3, 0.5),
        attack: (rrand 1, 4), sustain: (rrand 1, 2), release: (rrand 2, 5),
        cutoff_slide: (rrand 0, 5), cutoff: (rrand 80, 100),
        pan_slide: (rrand 1, 5), pan: (rrand -0.5, 0.5)
      
      control s, pan: (rrand -0.5, 0.5), cutoff: (rrand 70, 100)
      sleep (rrand 2, 4)
    end
  end
  
  live_loop :levelController do
    v = sync :volume
    control l, amp: v
  end
  
  live_loop :slideController do
    v = sync :volumeSlide
    control l, slide: v
  end
end

sleep 0.5
set :volumeSlide, 5.0
set :volume, 1.0

sleep 7.0
set :volume, 0.5

sleep 5.0
with_fx :reverb, room: 0.8, mix: 0.25 do
  sample SAMPLE_DIR() + "AlanWattsTime.wav", amp: 5.0
end

sleep 144.0
set :volume, 0.0

sleep 21.0
set :volumeSlide, 0.2
sleep 1.0
set :volume, 1.0

sleep 60.0
set :stop, true
