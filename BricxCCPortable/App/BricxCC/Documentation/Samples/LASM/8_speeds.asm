; Var 0 = speed
; Var 1 = __speed

; Task 0 = main, size: 53 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	setv	0, 2, 0
	start	1
	setv	0, 2, 1
	wait	2, 200
	setv	0, 2, -10
	wait	2, 200
	setv	0, 2, 5
	wait	2, 200
	setv	0, 2, -2
	wait	2, 200
	stop	1
	out	1, 3
	endt

; Task 1 = run_motor, size: 50 bytes
;run_motor
	task	1
t0010000:
	setv	1, 0, 0
	chk	2, 0, 1, 0, 1, t0010016
	dir	2, 3
	out	2, 3
t0010016:
	chk	2, 0, 0, 0, 1, t0010042
	dir	0, 3
	out	2, 3
	setv	47, 2, 0
	subv	47, 0, 1
	setv	1, 0, 47
t0010042:
	wait	0, 1
	out	1, 3
	jmp	t0010000
	endt

