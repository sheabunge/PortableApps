
; Task 0 = main, size: 34 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	tmrz	0
t0000008:
	dir	2, 5
	out	2, 5
	wait	4, 100
	dir	0, 4
	out	2, 4
	wait	4, 100
	chkl	2, 199, 1, 1, 0, t0000008
	out	1, 5
	endt

