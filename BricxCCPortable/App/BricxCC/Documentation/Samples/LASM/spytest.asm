; Var 35 = x
; Var 34 = y
; Task 8 = main, size: 88 bytes
#define x 35
#define y 34
#define my_animation 10
#define my_effect 64
#define trill 65
;main
	task	8
	pwr	7, 2, 3
	dir	2, 7
	setv	x, 2, 10
	setv	y, 2, 30
	chk	0, x, 1, 0, 34, t0080029
	pwr	1, 2, 3
	jmp	t0080033
t0080029:
	pwr	4, 2, 3
t0080033:
	playm my_animation
	plays my_effect
	wait	2, 200
	plays trill
	wait	2, 200
	set	53, 0, 2, 100
	plays	66
	wait	2, 200
	set	53, 0, 2, 200
t0080065:
	plays	66
	wait	2, 200
	playm	11
	wait	2, 500
	chk	2, 10, 0, 20, 1, t0080086
	jmp	t0080088
t0080086:
	jmp	t0080065
t0080088:
	endt
; sub 128 = Fred, size: 25 bytes
;Fred
	sub	128
	push	2, 769
	push	2, 500
	calls	47
	pop	2
	chk	2, 100, 0, 9, 0, s1280023
	playm	10
	jmp	s1280025
s1280023:
	playm	11
s1280025:
	ends
; Sound 64 = my_effect, size: 10 bytes
;my_effect
	sound	64
	startg	10, 3
	freqs	60, 294, 660
	stopg
	ends
; Sound 65 = trill, size: 15 bytes
;trill
	sound	65
	startg	10, 4
	tones	50, 1000
	startg	5, 1
	tones	50, 2000
	repeats
	ends
; Sound 66 = beep, size: 29 bytes
;beep
	sound	66
	startg	10, 1
	freqs	60, 294, 660
	stopg
	pauses	255
	freqv	60, 294, 660
	pausef	100
	tonef	50, 500
	tones	50, 300
	repeats
	ends
; Animation 8 = ScanUp, size: 8 bytes
;ScanUp
	mood	8
	1 10
	2 10
	4 10
	255 0
	endm
; Animation 9 = ScanDown, size: 6 bytes
;ScanDown
	mood	9
	1 10
	2 10
	4 10
	endm
; Animation 10 = my_animation, size: 10 bytes
;my_animation
	mood	10
	1 50
	2 50
	4 50
	2 50
	255 0
	endm
; Animation 11 = animation2, size: 8 bytes
;animation2
	mood	11
	1 50
	2 50
	4 50
	2 50
	endm
;Total size: 199 bytes
