; Var 47 = turntime
; Var 47 = turntime
; Var 47 = turntime

; Task 0 = main, size: 75 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	dir	2, 5
	out	2, 5
	wait	2, 100
	setv	47, 2, 200
	dir	0, 4
	out	2, 4
	wait	0, 47
	dir	2, 5
	out	2, 5
	wait	2, 200
	setv	47, 2, 50
	dir	0, 4
	out	2, 4
	wait	0, 47
	dir	2, 5
	out	2, 5
	wait	2, 100
	setv	47, 2, 300
	dir	0, 4
	out	2, 4
	wait	0, 47
	dir	2, 5
	out	2, 5
	out	1, 5
	endt

