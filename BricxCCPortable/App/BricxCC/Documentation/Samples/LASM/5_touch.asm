
; Task 0 = main, size: 45 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	sent	0, 1
	senm	0, 1, 0
	dir	2, 5
	out	2, 5
t0000016:
	chk	2, 1, 2, 9, 0, t0000043
	dir	0, 5
	out	2, 5
	wait	2, 30
	dir	2, 1
	out	2, 1
	wait	2, 30
	dir	2, 5
	out	2, 5
t0000043:
	jmp	t0000016
	endt

