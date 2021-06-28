live_loop :a do
  use_synth :hollow
  play (choose chord :E6, :minor7), sustain: 5.0, release: 0.0, amp: 0.1
  sleep 5.0
end

NOISE_TIME = 5.0
res = 0.5
live_loop :b do
  use_synth_defaults sustain: NOISE_TIME, release: 0.05
  
  synth :gnoise, cutoff: 60, amp: 0.4
  n = synth :noise, cutoff: 70, res: res, amp: 1, slide: NOISE_TIME
  
  res = rrand 0.4, 1.0
  control n, res: res
  
  sleep NOISE_TIME
end

sleep 60.0

samp = SAMPLE_DIR() + "no.wav"
with_fx :reverb, mix: 0.8, damp: 1, room: 0.6 do
  sample samp, amp: 6.0
end
sleep (sample_duration samp) + 0.25

sample :drum_cymbal_closed
sleep 0.25
sample :drum_cymbal_closed
sleep 0.25
sample :drum_cymbal_closed
sleep 0.25
sample :drum_cymbal_closed
sleep 0.25

fxs = fx_names.to_a
fxs.delete(:record)
fxs.delete(:sound_out)
fxs.delete(:sound_out_stereo)

define :melody do
  cur_sample = choose sample_names choose sample_groups
  cur_rate = rrand 0.1, 5.0
  sd = sample_duration cur_sample, rate: cur_rate
  sd = 0.05 if sd < 0.05
  repeats = rrand_i 5, 20
  with_fx choose fxs do
    repeats.times do
      sample cur_sample, rate: cur_rate, pan: (rrand -0.5, 0.5), amp: (rrand 0.5, 1.0)
      sleep sd
    end
  end
end

100.times do |i|
  live_loop (("loop" + i.to_s).to_sym) do
    melody
  end
  sleep 0.05
end
