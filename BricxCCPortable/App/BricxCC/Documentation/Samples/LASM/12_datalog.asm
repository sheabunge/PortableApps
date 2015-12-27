; Var 47 = x
; Var 46 = y

; Task 0 = main, size: 65 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	logz	100
	dir	2, 3
	out	2, 3
	setv	47, 2, 0
	setv	46, 2, 50
	setv	45, 2, 50
t0000028:
	decvjn	45, t0000063
	setv	0, 0, 47
	log	0, 0
	setv	0, 0, 46
	log	0, 0
	wait	2, 20
	sumv	47, 2, 1
	subv	46, 2, 1
	jmp	t0000028
t0000063:
	out	1, 3
	endt

