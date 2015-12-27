// simple LASM program

#define LOOP_COUNT 2
#define VOLUME 2
#define LOW_POWER 2
#define HIGH_POWER 6
#define MOTORS 3

task 0
/*
  setv 12, 2, -LOOP_COUNT
  absv 12, 0, 12

  volume VOLUME ; new command range 0-4 = 0-100% in steps of 25%

start:
  decvjn 12, finish
  calls 2
  jmp start
finish:
  */

  start 7
  
  start 3
  
  // wait for touch sensor 1 being pressed
  //
  // configure sensor
  sent 0, 1     ; SWITCH (1) on port 1 (0)
  senm 0, 1, 0  ; BOOLEAN (1) on port 1 (0) with slope 0 (0)
  waits 0
  
released:
  setv 5, 9, 0  ; read sensor (9) port 1 (0) into global 5 (5)
  chk 0, 5, 2, 2, 1, released 
                ; repeat as long as the read value is different from TRUE
                
  stop 3 ; stop background playing in task 3
                
pressed:
  setv 5, 9, 0  ; read sensor (9) port 1 (0) into global 5 (5)
  chk 0, 5, 2, 2, 0, pressed
                ; repeat as long as the read value is different from TRUE
                
  stop ; stop entire program
endt

sub 2
  playt 440, 50
  waitp
  wait 2, 50
  rets
ends

task 3 ; play continuously with rising volume
start:
  volume 1
  calls 2
  
  volume 2
  calls 2
  
  volume 3
  calls 2
  
  volume 4
  calls 2
  
  jmp start
endt 

task 7
  pwr MOTORS, 2, LOW_POWER ; MOTORS, PBConst, POWER
  dir 2, MOTORS ; forwards, MOTORS
  out 2, MOTORS ; on, MOTORS

  wait 2, 100

  pwr MOTORS, 2, HIGH_POWER ; MOTORS, PBConst, POWER
  
/*  dir 1, MOTORS ; reverse, MOTORS
  out 2, MOTORS ; on, MOTORS

  wait 2, 100
  
  out 1, MOTORS ; brake, MOTORS

  wait 2, 100*/
endt