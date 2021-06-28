samples = (ring :drum_bass_hard, :drum_cymbal_closed, :drum_cymbal_pedal, :drum_heavy_kick, :drum_snare_hard, :drum_tom_hi_hard, :drum_tom_lo_hard, :drum_tom_mid_hard)

use_debug false

use_bpm 40
baseBeatTime = 0.5
with_fx :bitcrusher, bits: 4, sample_rate: 1000, mix: 1 do
  with_fx :reverb, room: 1.0, mix: 0.6 do
    define :startBeatLoop do |beatTime, stopSig, beatSleepTime, timeMult = 1.0, offset = 0.0, alwaysPlay=false|
      n = get :loopNum
      set :loopNum, n+1
      
      live_loop ("loop" + n.to_s).to_sym do
        atTimes = range offset, timeMult * beatTime + offset, step: beatSleepTime
        
        beatsLength = (rrand_i 60, 100) / atTimes.length / (alwaysPlay ? 4 : 1)
        
        samp = (choose samples)
        amp = (rrand 0.2, 0.3) + beatSleepTime * beatSleepTime * 4
        pan = (rrand -0.1, 0.1)
        timing = (spread (rrand_i 2, 4), (rrand_i 8, 11))
        timing = ring true if alwaysPlay
        
        idxOffset = 0
        beatsLength.times do
          at atTimes do |t, idx|
            sample samp, amp: amp, pan: pan if timing[idxOffset + idx]
          end
          
          idxOffset += atTimes.length
          sleep beatTime
          stop if get(stopSig)
        end
        
        print "Changing beat in loop " + n.to_s, beatSleepTime
      end
    end
    
    define :startBeatLoops do |timeSigUpper, timeSigLower|
      set :loopNum, 0
      stopSig = ("stop" + timeSigLower.to_s + " " + timeSigUpper.to_s).to_sym
      
      set stopSig, false
      print "Changing time to " + timeSigUpper.to_s + " over " + timeSigLower.to_s
      
      beatTime = baseBeatTime * timeSigUpper / timeSigLower
      
      i = 1
      while i < timeSigUpper
        hitsPerBeat = (timeSigUpper / i).to_i
        beatSleepTime = beatTime * i / timeSigUpper
        timeMult = hitsPerBeat * i.to_f / timeSigUpper
        
        2.times do
          startBeatLoop beatTime, stopSig, beatSleepTime, timeMult
        end
        2.times do
          startBeatLoop beatTime, stopSig, beatSleepTime, timeMult, beatTime * (1.0 - timeMult)
        end
        
        i *= 2
      end
      
      startBeatLoop beatTime, stopSig, beatTime, 1.0, 0.0, true
      2.times do
        startBeatLoop beatTime, stopSig, beatTime
      end
      
      sleep (quantise 10, beatTime) + 0.1
      set stopSig, true
      sleep beatTime - 0.1
    end
    
    use_random_seed 4 # This is just to start with a beat that is not too fast
    
    live_loop :starter do
      startBeatLoops (rrand_i 3, 12), (rrand_i 3, 12)
    end
    
    live_loop :a do
      use_synth :square
      at (range 0, tick * 0.04, 0.1) do
        play (rrand :C3, :C7), amp: (rrand 0.2, 0.6), pan: (rrand -0.5, 0.5)
      end
      sleep rrand 1.0, 3.0
    end
  end
end