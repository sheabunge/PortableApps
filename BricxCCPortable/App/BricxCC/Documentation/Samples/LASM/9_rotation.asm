
; Task 0 = main, size: 58 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	sent	0, 4
	senm	0, 7, 0
	senz	0
	sent	2, 4
	senm	2, 7, 0
	senz	2
t0000022:
	chk	9, 0, 1, 9, 2, t0000037
	dir	2, 1
	out	2, 1
	out	0, 4
	jmp	t0000056
t0000037:
	chk	9, 0, 0, 9, 2, t0000052
	dir	2, 4
	out	2, 4
	out	0, 1
	jmp	t0000056
t0000052:
	dir	2, 5
	out	2, 5
t0000056:
	jmp	t0000022
	endt

