; Var 0 = move_time

; Task 0 = main, size: 44 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	setv	0, 2, 20
	setv	47, 2, 50
t0000016:
	decvjn	47, t0000042
	dir	2, 5
	out	2, 5
	wait	0, 0
	dir	0, 4
	out	2, 4
	wait	2, 85
	sumv	0, 2, 5
	jmp	t0000016
t0000042:
	out	1, 5
	endt

