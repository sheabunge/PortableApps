
; Task 0 = main, size: 26 bytes
;main
	task	0
	pwr	7, 2, 7
	dir	2, 7
	start	1
t0000008:
	dir	2, 3
	out	2, 3
	wait	2, 300
	dir	0, 3
	out	2, 3
	wait	2, 300
	jmp	t0000008
	endt

; Task 1 = music, size: 34 bytes
;music
	task	1
t0010000:
	playt	262, 40
	wait	2, 50
	playt	294, 40
	wait	2, 50
	playt	330, 40
	wait	2, 50
	playt	294, 40
	wait	2, 50
	jmp	t0010000
	endt

