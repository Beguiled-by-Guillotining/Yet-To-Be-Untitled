samples = (ring :drum_bass_hard, :drum_cymbal_closed, :drum_cymbal_pedal, :drum_heavy_kick, :drum_snare_hard, :drum_tom_hi_hard, :drum_tom_lo_hard, :drum_tom_mid_hard)

use_debug false
use_sched_ahead_time 0.5

use_random_seed 1

use_bpm 30
baseBeatTime = 0.5

buffer_length = 90
temp = buffer :temp, buffer_length

with_fx :level, amp: 0 do
  with_fx :record, buffer: temp do
    with_fx :reverb, room: 0.2, damp: 1, mix: 1 do
      with_fx :compressor, slope_above: 0.5, slope_below: 0.5, clamp_time: 0, relax_time: 0, mix: 1 do
        with_fx :level, amp: 0.7 do
          set :loopNum, 0
          define :startBeatLoop do |beatSleepTime, timeMult = 1.0, offset = 0.0, alwaysPlay=false|
            n = get :loopNum
            set :loopNum, n+1
            
            live_loop ("loop" + n.to_s).to_sym do
              atTimes = range offset, timeMult * baseBeatTime + offset, step: beatSleepTime
              
              beatsLength = (rrand_i 50, 80) / atTimes.length / (alwaysPlay ? 4 : 1)
              
              samp = (choose samples)
              amp = (rrand 0.2, 0.3) + beatSleepTime
              pan = (rrand -0.1, 0.1)
              timing = (spread (rrand_i 2, 4), (rrand_i 8, 11))
              timing = ring true if alwaysPlay
              
              idxOffset = 0
              beatsLength.times do
                at atTimes do |t, idx|
                  sample samp, amp: amp, pan: pan,
                    compress: 1,
                    slope_below: 0.5,
                    slope_above: 0.5,
                    clamp_time: 0,
                    relax_time: 0 if timing[idxOffset + idx]
                end
                
                idxOffset += atTimes.length
                sleep baseBeatTime
              end
              
              stop if rt(vt) > buffer_length
            end
          end
          
          startBeatLoop 0.5, 1.0, 0.0, true
          startBeatLoop 0.5
          startBeatLoop 0.5
          startBeatLoop 2.0 / 7, 6.0 / 7.0
          startBeatLoop 2.0 / 7, 6.0 / 7.0
          startBeatLoop 2.0 / 7, 6.0 / 7.0, 1.0 / 7.0
          startBeatLoop 2.0 / 7, 6.0 / 7.0, 1.0 / 7.0
          startBeatLoop 1.0 / 7, 6.0 / 7.0
          startBeatLoop 1.0 / 7, 6.0 / 7.0
          startBeatLoop 1.0 / 7, 6.0 / 7.0, 1.0 / 7.0
          startBeatLoop 1.0 / 7, 6.0 / 7.0, 1.0 / 7.0
          startBeatLoop 0.5 / 7
          startBeatLoop 0.5 / 7
        end
        
        live_loop :b do
          sleep 4
          stop if rt(vt) > buffer_length
          
          use_synth [:tri, :sine, :saw].choose
          3.times do
            note = choose chord :C2, 'm7+5-9', num_octaves: 2
            amp = 40000.0 / (note * note * note)
            amp = 1.0 if amp > 1.0
            print amp
            play note, amp: amp, sustain: (rrand 2.0, 3.0), attack: (rrand 1.0, 2.0), release: 2.0, pan: (rrand -0.5, 0.5)
          end
          sleep (rrand 8.0, 10.0)
        end
      end
    end
  end
end

sleep 0.5 # Give the recording a headstart

step_time = 2

live_loop :replay do
  i = tick.to_f
  steps_in_buffer = buffer_length / step_time
  rate = 1.0 - (i / steps_in_buffer)
  start = i / steps_in_buffer
  finish = (i + 1 + 0.2) / steps_in_buffer
  release = 0.1
  if finish > 1
    finish = 1
    release = 2.0
  end
  
  stop if rate <= 0
  
  print start, rate
  
  sample temp, start: start, finish: finish, attack: 0.1, release: release, rate: rate
  sample temp, start: start, finish: finish, attack: step_time / 2, release: step_time / 2 if one_in(3) and rate < 1
  if rate > 0.25
    sample temp, start: start, finish: finish, attack: 0.1, release: release, beat_stretch: buffer_length / rate
  else
    sample temp, start: start, finish: finish, attack: 0.1, release: release, rate: rate, pitch: 24
  end
  sleep step_time / rate + 0.02 # adding a small number removes some interferance from playing the same time of the sample at different speeds at the same time
end