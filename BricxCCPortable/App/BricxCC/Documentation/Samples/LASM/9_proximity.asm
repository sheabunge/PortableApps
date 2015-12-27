; Var 0 = lastlevel

; Task 0 = main, size: 20 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	sent	1, 3
	senm	1, 0, 0
	dir	2, 5
	out	2, 5
	start	1
	start	2
	endt

; Task 1 = send_signal, size: 9 bytes
;send_signal
	task	1
t0010000:
	msg	2, 0
	wait	2, 10
	jmp	t0010000
	endt

; Task 2 = check_signal, size: 36 bytes
;check_signal
	task	2
t0020000:
	setv	0, 9, 1
	setv	47, 0, 0
	sumv	47, 2, 200
	chk	9, 1, 0, 0, 47, t0020034
	dir	0, 4
	out	2, 4
	wait	2, 85
	dir	2, 5
	out	2, 5
t0020034:
	jmp	t0020000
	endt

