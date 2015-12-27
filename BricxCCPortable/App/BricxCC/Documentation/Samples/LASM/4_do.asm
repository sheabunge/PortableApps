; Var 0 = move_time
; Var 1 = turn_time
; Var 2 = total_time

; Task 0 = main, size: 57 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	setv	2, 2, 0
t0000011:
	setv	0, 4, 100
	setv	1, 4, 100
	dir	2, 5
	out	2, 5
	wait	0, 0
	dir	0, 4
	out	2, 4
	wait	0, 1
	sumv	2, 0, 0
	sumv	2, 0, 1
	chkl	2, 1999, 1, 0, 2, t0000011
	out	1, 5
	endt

