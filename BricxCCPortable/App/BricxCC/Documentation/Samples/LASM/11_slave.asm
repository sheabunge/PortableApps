
; Task 0 = main, size: 48 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
t0000006:
	msgz
t0000007:
	chkl	2, 0, 3, 15, 0, t0000007
	chk	2, 1, 2, 15, 0, t0000026
	dir	2, 5
	out	2, 5
t0000026:
	chk	2, 2, 2, 15, 0, t0000037
	dir	0, 5
	out	2, 5
t0000037:
	chk	2, 3, 2, 15, 0, t0000046
	out	1, 5
t0000046:
	jmp	t0000006
	endt

