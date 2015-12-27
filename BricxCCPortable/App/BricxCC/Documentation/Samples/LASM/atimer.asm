; timer tests

#define V_TIMER_START 87
#define V_TIMER       117
#define V_TIMER_DIFF  6

task 0

  playt 440, 200

  setv V_TIMER_START, 1, 0
slow_wait1:
  setv V_TIMER, 1, 0
  subv V_TIMER, 0, V_TIMER_START
  chk 0, V_TIMER, 0, 2, 5, slow_wait1 ; 5 == 1/2 sec
  
  playz

  setv V_TIMER_START, 1, 0
slow_wait2:
  setv V_TIMER, 1, 0
  subv V_TIMER, 0, V_TIMER_START
  chk 0, V_TIMER, 0, 2, 10, slow_wait2 ; 10 == 1 sec
  
  playt 440, 10
  waitp

  mute
  playt 440, 250
  waitp

  speak
  playt 440, 10
  waitp

  stop
endt