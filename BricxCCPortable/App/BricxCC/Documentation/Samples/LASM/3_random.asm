; Var 0 = move_time
; Var 1 = turn_time

; Task 0 = main, size: 34 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
t0000006:
	setv	0, 4, 60
	setv	1, 4, 40
	dir	2, 5
	out	2, 5
	wait	0, 0
	dir	0, 1
	out	2, 1
	wait	0, 1
	jmp	t0000006
	endt

