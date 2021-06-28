eval_file KNOBS_RB_PATH()

midi_name = PAD_MIDI_NAME()

##| initKnobs
##| set :offset, 0

sleepTime = 0.5

minLoopLength = 0.2

with_fx :reverb, room: 1 do |rev1|
  with_fx :echo, max_phase: 13 do |echo|
    with_fx :tanh do |tanh|
      with_fx :reverb, room: 1 do |rev2|
        live_loop :playback do
          synth :sound_in_stereo, sustain: sleepTime, release: 0.0, amp: 5
          sleep sleepTime
        end
        
        live_loop :mixUpdates do
          control rev1, mix: (getKnob 5) / 127.0
          control echo, mix: (getKnob 6) / 127.0
          control tanh, mix: (getKnob 7) / 127.0
          control rev2, mix: (getKnob 8) / 127.0
          sleep 0.2
        end
        
        live_loop :echoUpdates do
          phase = (getKnob 4) / 10.0
          phase = 0.1 if phase < 0.1
          decay = (getKnob 3) / 5.0
          decay = 0.1 if decay < 0.1
          control echo, phase: phase, decay: decay
          sleep 0.5
        end
        
        
        
        live_loop :midiButtons do
          use_real_time
          note, velocity = sync midi_name + "note_on"
          
          in_thread do
            amp = velocity / 30.0
            loop do
              sample (sample_names :drum)[note + get(:offset)], amp: amp * (getKnob 2) / 127.0
              t = (getKnob 1) / 10.0
              sleep t > minLoopLength ? t : minLoopLength
            end
          end
        end
      end
    end
  end
end

live_loop :midiButtons2 do
  use_real_time
  note, velocity = sync midi_name + "program_change"
  
  set :offset, note
end