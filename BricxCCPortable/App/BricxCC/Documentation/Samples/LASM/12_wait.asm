
; Task 0 = main, size: 35 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	sent	0, 1
	senm	0, 1, 0
	tmrz	3
	dir	2, 5
	out	2, 5
t0000018:
	chk	2, 1, 3, 9, 0, t0000033
	chkl	2, 100, 1, 1, 3, t0000018
t0000033:
	out	1, 5
	endt

