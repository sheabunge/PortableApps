; Var 0 = sem

; Task 0 = main, size: 62 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	setv	0, 2, 0
	start	1
	sent	0, 1
	senm	0, 1, 0
t0000019:
	chk	2, 1, 2, 9, 0, t0000060
t0000026:
	chkl	2, 0, 2, 0, 0, t0000026
	setv	0, 2, 1
	dir	0, 5
	out	2, 5
	wait	2, 50
	dir	2, 1
	out	2, 1
	wait	2, 85
	setv	0, 2, 0
t0000060:
	jmp	t0000019
	endt

; Task 1 = move_square, size: 54 bytes
;move_square
	task	1
t0010000:
	chkl	2, 0, 2, 0, 0, t0010000
	setv	0, 2, 1
	dir	2, 5
	out	2, 5
	setv	0, 2, 0
	wait	2, 100
t0010026:
	chkl	2, 0, 2, 0, 0, t0010026
	setv	0, 2, 1
	dir	0, 4
	out	2, 4
	setv	0, 2, 0
	wait	2, 85
	jmp	t0010000
	endt

