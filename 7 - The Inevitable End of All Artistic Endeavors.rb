set :start, false
set :stopping, false
set :stopTalking, false
set :stop, false

dir = SAMPLE_DIR() + "Hanekawa/"

live_loop :talk do
  if current_bpm < 120
    sample dir + "1.wav", amp: 6.0
    sleep rrand 2.0, 3.0
  end
  sample dir + "2.wav", amp: 6.0
  sleep rrand 3.0, 4.0
  sample dir + "3.wav", amp: 6.0
  if !get :start
    sleep sample_duration dir + "3.wav"
    set :start, true
    sleep 4.0
  end
  sleep rrand 4.0, 5.0
  if !get :stopping
    if current_bpm > 600
      set :stopping, true
      in_thread do
        sleep 10.0
        set :stopTalking, true
        sleep 15.0
        set :stop, true
        sleep (sample_duration dir + "3.wav") + 1.0
        sample dir + "3.wav", amp: 6.0
      end
    else
      use_bpm_mul 1.2
    end
  end
  stop if get :stopTalking
end

sync :start

live_loop :drums do
  use_synth :chipnoise
  times = [0.0]
  t = tick
  times = [0.0, 0.1] if !one_in(3) and !factor? t, 4
  at times do
    play freq_band: (rrand_i 0, 10), release: 0.1, amp: 0.5
    play freq_band: (rrand_i 10, 15), release: 0.3, amp: 0.8 if factor? t, 4
  end
  sleep 0.2
  stop if get :stop
end

live_loop :bass do
  use_synth :chipbass
  times = [0.0]
  times = [0.0, 0.1] if one_in(3)
  at times do
    play (choose chord :E3, :minor7), release: 0.1
  end
  sleep 0.2
  stop if get :stop
end

set :mainLead, 0
live_loop :mainChanger do
  sleep (rrand 5.0, 6.0)
  set :mainLead, ((get :mainLead) + 1) % 3
  stop if get :stop
end

live_loop :lead do
  use_synth :chiplead
  times = [0.0]
  times = [0.0, 0.2] if one_in(2)
  at times do
    play (choose chord :E5, :minor7), release: 0.4, amp: 1.0, width: 2 - (get :mainLead)
  end
  sleep 0.4
  stop if get :stop
end

live_loop :lead2 do
  use_synth :chiplead
  times = [0.0]
  times = [0.0, 0.2] if one_in(2)
  at times do
    play (choose chord :E4, :minor7), release: 0.4, amp: 1.0, width: (get :mainLead)
  end
  sleep 0.4
  stop if get :stop
end

with_fx :distortion, distort: 0.1 do
  with_fx :reverb, room: 1.0, mix: 0.6 do
    with_fx :echo, phase: 0.2 do
      live_loop :dist_lead do
        use_synth :chiplead
        play (choose chord :E3, :minor7, num_octaves: 2), release: 2.0, amp: 0.6, width: 2
        sleep 1.0
        stop if get :stop
      end
    end
  end
end