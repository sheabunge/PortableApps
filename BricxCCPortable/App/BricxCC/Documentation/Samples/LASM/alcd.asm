; LASM LCD butterfly

#define V_LOWERLEFT   10
#define V_LOWERRIGHT  11
#define V_UPPERLEFT   12
#define V_UPPERRIGHT  13

#define V_CENTER      20
#define V_RADIUS      21

#define V_LOCATION    30
#define V_SIZE        31

#define V_PIXEL       40

#define V_PRINT       50

task 0

  ; butterfly
  setv V_LOWERLEFT,  2, 0x0000
  setv V_LOWERRIGHT, 2, 0x6300
  setv V_UPPERLEFT,  2, 0x003F
  setv V_UPPERRIGHT, 2, 0x633F
    
  line V_LOWERLEFT,  V_UPPERRIGHT
  line V_UPPERRIGHT, V_LOWERRIGHT
  line V_LOWERRIGHT, V_UPPERLEFT
  line V_UPPERLEFT,  V_LOWERLEFT
  
  ; circle
  setv V_CENTER, 2, 0x311F
  setv V_RADIUS, 2, 20
  circle V_CENTER, V_RADIUS
  
  ; clear
  wait 2, 100
  blank
  
  ; rect
  setv V_LOCATION, 2, 0x311F
  setv V_SIZE,     2, 0x2020
  rect V_LOCATION, V_SIZE
  
  ; pixel
  setv V_PIXEL, 2, 0x2F1D
  pixel V_PIXEL
  
  ; clear
  wait 2, 100
  blank  
  
  ; print
  setv V_PRINT, 2, 0x2010
forever:
  print V_PRINT, 1, 0, 0 ; 
  jmp forever
endt

