; Var 0 = ttt
; Var 1 = tt2

; Task 0 = main, size: 42 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	start	1
	sent	0, 3
	senm	0, 0, 0
t0000014:
	chk	2, 99, 1, 9, 0, t0000028
	chk	2, 750, 1, 9, 0, t0000040
t0000028:
	stop	1
	dir	0, 5
	out	2, 5
	wait	2, 30
	start	1
t0000040:
	jmp	t0000014
	endt

; Task 1 = moverandom, size: 68 bytes
;moverandom
	task	1
t0010000:
	setv	0, 4, 50
	sumv	0, 2, 40
	setv	1, 4, 1
	chk	2, 0, 1, 0, 1, t0010036
	dir	0, 1
	out	2, 1
	dir	2, 4
	out	2, 4
	wait	0, 0
	jmp	t0010048
t0010036:
	dir	0, 4
	out	2, 4
	dir	2, 1
	out	2, 1
	wait	0, 0
t0010048:
	setv	0, 4, 150
	sumv	0, 2, 50
	dir	2, 5
	out	2, 5
	wait	0, 0
	jmp	t0010000
	endt

