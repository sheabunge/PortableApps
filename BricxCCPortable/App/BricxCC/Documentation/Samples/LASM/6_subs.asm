
; Task 0 = main, size: 30 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	dir	2, 5
	out	2, 5
	wait	2, 100
	calls	0
	wait	2, 200
	calls	0
	wait	2, 100
	calls	0
	out	1, 5
	endt

; Sub 0 = turn_around, size: 12 bytes
;turn_around
	sub	0
	dir	0, 4
	out	2, 4
	wait	2, 340
	dir	2, 5
	out	2, 5
	ends

