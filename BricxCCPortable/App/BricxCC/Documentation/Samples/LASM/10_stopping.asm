
; Task 0 = main, size: 16 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	sent	0, 1
	senm	0, 1, 0
	start	2
	start	1
	endt

; Task 1 = move_square, size: 18 bytes
;move_square
	task	1
t0010000:
	dir	2, 5
	out	2, 5
	wait	2, 100
	dir	0, 4
	out	2, 4
	wait	2, 85
	jmp	t0010000
	endt

; Task 2 = check_sensors, size: 29 bytes
;check_sensors
	task	2
t0020000:
	chk	2, 1, 2, 9, 0, t0020027
	stop	1
	dir	0, 5
	out	2, 5
	wait	2, 50
	dir	2, 1
	out	2, 1
	wait	2, 85
	start	1
t0020027:
	jmp	t0020000
	endt

