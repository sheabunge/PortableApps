
; Task 0 = main, size: 35 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	msgz
	wait	2, 200
	wait	4, 400
	chk	2, 0, 1, 15, 0, t0000026
	start	2
	jmp	t0000035
t0000026:
	msg	2, 1
	wait	2, 400
	start	1
t0000035:
	endt

; Task 1 = master, size: 17 bytes
;master
	task	1
	msg	2, 1
	wait	2, 200
	msg	2, 2
	wait	2, 200
	msg	2, 3
	endt

; Task 2 = slave, size: 42 bytes
;slave
	task	2
t0020000:
	msgz
t0020001:
	chkl	2, 0, 3, 15, 0, t0020001
	chk	2, 1, 2, 15, 0, t0020020
	dir	2, 5
	out	2, 5
t0020020:
	chk	2, 2, 2, 15, 0, t0020031
	dir	0, 5
	out	2, 5
t0020031:
	chk	2, 3, 2, 15, 0, t0020040
	out	1, 5
t0020040:
	jmp	t0020000
	endt

