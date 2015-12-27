
; Task 0 = main, size: 45 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	sent	1, 3
	senm	1, 4, 0
	dir	2, 5
	out	2, 5
t0000016:
	chk	2, 40, 1, 9, 1, t0000043
	dir	0, 4
	out	2, 4
	wait	2, 10
t0000031:
	chkl	2, 41, 0, 9, 1, t0000031
	dir	2, 5
	out	2, 5
t0000043:
	jmp	t0000016
	endt

