
; Task 0 = main, size: 48 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	sent	0, 1
	senm	0, 3, 0
t0000012:
	senz	0
t0000014:
	chkl	2, 0, 1, 9, 0, t0000014
	wait	2, 100
	chk	2, 1, 2, 9, 0, t0000035
	out	1, 5
t0000035:
	chk	2, 2, 2, 9, 0, t0000046
	dir	2, 5
	out	2, 5
t0000046:
	jmp	t0000012
	endt

