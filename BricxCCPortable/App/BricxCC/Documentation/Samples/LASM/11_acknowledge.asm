
; Task 0 = main, size: 22 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
t0000006:
	msg	2, 1
	msgz
	wait	2, 10
	chkl	2, 255, 2, 15, 0, t0000006
	endt

