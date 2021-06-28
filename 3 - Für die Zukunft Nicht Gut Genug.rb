# listOnsets slightly modifed from https://in-thread.sonic-pi.net/t/onset-percussion/1101/5
define :listOnsets do |s|
  set :onsetsMaps, []
  l = lambda {|c| set :onsetsMaps, c.to_a; c[0]}
  sample s, onset: l, amp: 0, finish: 0 # trigger the lambda function played sample at 0 volume and finish=0
  sleep 0.2
  return get :onsetsMaps
end

use_debug false

s = SAMPLE_DIR() + "life.wav"

onsets = listOnsets s

samples = (ring :drum_bass_hard, :drum_cymbal_closed, :drum_cymbal_pedal, :drum_heavy_kick, :drum_snare_hard, :drum_tom_hi_hard, :drum_tom_lo_hard, :drum_tom_mid_hard)


live_loop :normal do
  sample s, amp: 7.0
  sleep sample_duration s
end

live_loop :a do
  i = tick % onsets.length
  rate = (onsets[i][:finish] - onsets[i][:start]) * (sample_duration s) / 0.25
  sample s, onset: i, amp: 7.0, rate: rate, pan: -0.5
  sleep 0.25
end

live_loop :b do
  i = tick % onsets.length
  rate = (onsets[i][:finish] - onsets[i][:start]) * (sample_duration s) / 0.5
  sample s, onset: i, amp: 7.0, rate: rate, pan: 0.5
  sleep 0.5
end

live_loop :c do
  sample s, onset: tick, amp: 7.0, pan: 0.5
  sleep 0.25
end

live_loop :d do
  sample s, onset: tick, amp: 7.0, pan: 0.5, rate: 0.1
  sleep 0.5
end

set :loopNum, 0

define :startBeatLoop do |beatSleepTime|
  n = get :loopNum
  set :loopNum, n+1
  
  live_loop ("loop" + n.to_s).to_sym do
    beatLength = rrand_i 50, 80
    atTimes = range 0, beatLength * beatSleepTime, step: beatSleepTime
    
    samp = (choose samples)
    amp = (rrand 0.2, 0.3) + beatSleepTime * beatSleepTime * 4
    pan = (rrand -0.1, 0.1)
    timing = (spread (rrand_i 2, 4), (rrand_i 7, 11))
    
    at atTimes do |t, idx|
      sample samp, amp: amp, pan: pan if timing[idx]
    end
    
    sleep beatLength * beatSleepTime
  end
end

startBeatLoop 0.5
startBeatLoop 0.5
startBeatLoop 0.5
startBeatLoop 0.25
startBeatLoop 0.25
startBeatLoop 0.25
startBeatLoop 0.25
startBeatLoop 0.25
startBeatLoop 0.125
startBeatLoop 0.125
startBeatLoop 0.125