##| set :stop, true
##| stop

samples = (ring :drum_bass_hard, :drum_cymbal_closed, :drum_cymbal_pedal, :drum_heavy_kick, :drum_snare_hard, :drum_tom_hi_hard, :drum_tom_lo_hard, :drum_tom_mid_hard)

use_debug false
use_sched_ahead_time 1.0

use_random_seed 4

randomness = 3

set :loopNum, 0
set :loopNumMelody, 0

set :stop, false

with_fx :level, amp_slide: 5.0 do |l|
  define :startBeatLoop do |beatSleepTime, alwaysPlay=false|
    n = get :loopNum
    set :loopNum, n+1
    
    live_loop ("loop" + n.to_s).to_sym do
      beatLength = rrand_i 50, 80
      atTimes = range 0, beatLength * beatSleepTime, step: beatSleepTime
      
      samp = (choose samples)
      amp = (rrand 0.3, 0.4) + beatSleepTime * beatSleepTime * 4
      pan = (rrand -0.1, 0.1)
      timing = (spread (rrand_i 2, 4), (rrand_i 7, 11))
      timing = ring true if alwaysPlay
      
      at atTimes do |t, idx|
        sample samp, amp: amp, pan: pan if timing[idx]
      end
      
      sleep beatLength * beatSleepTime
      stop if get :stop
    end
  end
  
  live_loop :volume_changer do
    vol = sync :drum_volume
    print "New drum volume: ", vol
    control l, amp: vol
  end
  
  in_thread do
    startBeatLoop 0.5
    startBeatLoop 0.5
    startBeatLoop 0.5
    sleep 5.0
    startBeatLoop 0.25
    startBeatLoop 0.25
    startBeatLoop 0.25
    startBeatLoop 0.25
    startBeatLoop 0.25
    sleep 5.0
    startBeatLoop 0.5, true
    sleep 5.0
    startBeatLoop 0.25
    sleep 5.0
    startBeatLoop 0.125
    sleep 5.0
    startBeatLoop 0.125
    sleep 5.0
    startBeatLoop 0.125
  end
end

#instrument, sleepTime, amp, note_offset
instrs = [
  [
    [:square, 1.0  , 0.4 , 0],
    [:square, 0.5  , 0.4 , 0],
    
    [:saw   , 1.0  , 0.6 , 0],
    [:saw   , 0.5  , 0.6 , 0]
  ],
  [
    [:square, 0.25 , 0.45, -12],
    [:square, 0.25 , 0.4 , 0],
    [:square, 0.25 , 0.2 , 12],
    
    [:saw   , 0.25  , 0.4, 0]
  ],
  [
    [:square, 0.125, 0.5 , -24],
    [:square, 0.125, 0.45, -12],
    [:square, 0.125, 0.4 , 0],
    [:square, 0.125, 0.1 , 12],
    
    
    [:saw   , 0.125, 0.4 , 0]
  ],
  [
    [:mod_pulse, 0.125, 0.5 , -24],
    [:mod_pulse, 0.125, 0.4 , 0],
    [:mod_pulse, 0.125, 0.1 , 12],
    
    [:mod_saw   , 0.125, 0.4 , 0]
  ],
  [
    [:mod_pulse, 1.0  , 0.3 , 0],
    [:mod_pulse, 0.5  , 0.3 , 0],
    [:mod_pulse, 0.25 , 0.3, -12],
    [:mod_pulse, 0.25 , 0.3 , 0],
    [:mod_pulse, 0.25 , 0.2 , 12],
    
    [:mod_saw   , 1.0  , 0.4 , 0],
    [:mod_saw   , 0.5  , 0.4 , 0],
    [:mod_saw   , 0.25  , 0.3, 0]
  ],
  [
    [:mod_sine, 0.125, 0.7 , -24],
    [:mod_sine, 0.125, 0.6 , 0],
    [:mod_sine, 0.125, 0.3 , 12]
  ],
  [
    [:mod_tri, 0.125, 0.7 , -24],
    [:mod_tri, 0.125, 0.6 , 0],
    [:mod_tri, 0.125, 0.2 , 12]
  ]
]

scales =
(ring
 (chord :C3, 'm7+5-9', num_octaves: 2),
 (chord :C3, 'm7+5', num_octaves: 2),
 (chord :C3, :minor7, num_octaves: 2),
 (chord :C3, :minor, num_octaves: 2),
 (scale :C3, :minor, num_octaves: 2),
 (scale :C2, :minor, num_octaves: 3),
 (scale :C2, :minor, num_octaves: 2)
 ).reflect

drumVolumes = (line 1.0, 0.15, steps: (scales.length + 1) / 2).reflect

set :curScale, scales[0]


define :getRandomElement do |pauses, curScale|
  return [(knit :r, pauses, (rrand_i 0, curScale.length), 1).choose,
          (rrand 0.8, 1.2),
          (rrand -0.2, 0.2)]
end

define :liveLoop do |inst, sleepTime, amp, offset|
  use_synth inst
  use_synth_defaults mod_phase: sleepTime / 2
  
  len = (4 / sleepTime).to_i #rrand_i 4, 8
  
  pauses = 1
  
  melody = []
  curScale = get :curScale
  len.times do
    melody.append(getRandomElement(pauses, curScale))
  end
  
  n = get :loopNumMelody
  set :loopNumMelody, n+1
  
  live_loop ("loopMelody" + n.to_s).to_sym do
    curScale = get :curScale
    
    idx = tick % len
    if one_in(get(:stop) ? 3 : randomness / sleepTime)
      melody[idx] = getRandomElement(pauses, curScale)
    end
    
    if melody[idx][0] != :r
      play curScale[melody[idx][0]] + offset,
        amp: melody[idx][1] * amp,
        pan: melody[idx][2],
        release: sleepTime * 2,
        mod_range: curScale[melody[idx][0] + 1] - curScale[melody[idx][0]]
    end
    
    pauses = (rrand 1, 8) if one_in 40 / sleepTime
    pauses = 99999 if get :stop
    
    sleep sleepTime
  end
end

for instr in instrs
  for inst in instr
    liveLoop inst[0], inst[1], inst[2], inst[3]
  end
  sleep 5.0
end

live_loop :scaleChanger do
  stop if get :stop
  set :curScale, scales.tick
  set :drum_volume, drumVolumes.look
  print "new scale: ", (get :curScale)
  sleep 20.0
end