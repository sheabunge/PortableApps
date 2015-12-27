; PlatToneVar test commands

#define V_LOOP_COUNT 12
#define V_FREQUENCY  13
#define V_POINTER    14
#define V_TEMP       31

#define K_LOOP_COUNT 5
#define K_START_FREQ 220
#define K_DURATION 50
#define K_VOLUME 1

task 0

  volume K_VOLUME

  setv V_LOOP_COUNT, 2, K_LOOP_COUNT
  setv V_POINTER, 2, V_FREQUENCY  
  setv V_FREQUENCY, 2, K_START_FREQ
  
one_octave:
  decvjn V_LOOP_COUNT, the_end
  
  setv V_TEMP, 36, V_POINTER
  playv V_TEMP, K_DURATION
  mulv V_FREQUENCY, 2, 2
  waitp

  jmp one_octave

the_end:
  stop
endt