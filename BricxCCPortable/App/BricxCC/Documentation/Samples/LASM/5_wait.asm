
; Task 0 = main, size: 26 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	sent	0, 1
	senm	0, 1, 0
	dir	2, 5
	out	2, 5
t0000016:
	chkl	2, 1, 2, 9, 0, t0000016
	out	1, 5
	endt

