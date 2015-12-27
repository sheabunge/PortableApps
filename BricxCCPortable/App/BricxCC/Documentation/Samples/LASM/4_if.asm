
; Task 0 = main, size: 42 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
t0000006:
	dir	2, 5
	out	2, 5
	wait	2, 100
	setv	47, 4, 1
	chk	2, 0, 2, 0, 47, t0000032
	dir	0, 4
	out	2, 4
	jmp	t0000036
t0000032:
	dir	0, 1
	out	2, 1
t0000036:
	wait	2, 85
	jmp	t0000006
	endt

