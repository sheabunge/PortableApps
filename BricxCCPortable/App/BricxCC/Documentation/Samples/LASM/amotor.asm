; motor test commands

#define MOTORS 1
#define LOW_POWER 1
#define MED_POWER 4
#define HIGH_POWER 7
#define SRC_CONST 2

task 0

  pwr MOTORS, SRC_CONST, LOW_POWER
  dir 2, MOTORS ; FWD, MOTORS
  out 2, MOTORS ; ON, MOTORS

  start 1
  wait 2, 200

  pwr MOTORS, 2, MED_POWER 
  
  start 1
  wait 2, 200

  pwr MOTORS, 2, HIGH_POWER 
  
  start 1
  wait 2, 200

  out 0, MOTORS ; FLOAT, MOTORS

  start 1
  wait 2, 400

  out 1, MOTORS ; OFF, MOTORS

  tacz MOTORS
  setv 27, 5, 0
  
  chk 0,27,2,2,0,nonzero
zero:  
  start 1
  
nonzero:
  playt 1760, 10
  
  wait 2, 400

  setv 28, 5, 0

  chk 0,27,2,0,28,unsteady
steady:
  playt 440, 10
  jmp stopping
unsteady:
  playt 880, 100

stopping:
  waitp
  stop
  
endt

task 1
  playt 440, 10
endt