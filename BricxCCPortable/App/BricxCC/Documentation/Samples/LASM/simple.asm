#define x 35
#define y 34
#define SND_CLICK 0
#define SND_SWEEP_DOWN 2
#define OUT_ABC 7
#define OUT_A 1
#define OUT_C 4
#define Forward 2
#define srcVar 0
#define srcConst 2
#define main 8
#define LessThan 1
#define GreaterThan 0
;main
	task	main
	pwr	OUT_ABC, srcConst, 3
	dir	Forward, OUT_ABC
	setv	x, srcConst, 9
	setv	y, srcConst, 30
	chk	srcVar, x, LessThan, srcVar, y, x_is_not_less_than_y
	pwr	OUT_A, srcConst, 3
	jmp	end_if_x_less_than_y
x_is_not_less_than_y:
	pwr	OUT_C, srcConst, 3
end_if_x_less_than_y:
	plays	SND_SWEEP_DOWN
	wait	srcConst, 200
infinite_loop:
	plays	SND_CLICK
	wait	srcConst, 200
	chk	srcConst, 10, GreaterThan, srcVar, x, keep_looping
	jmp	stop_looping
keep_looping:
	jmp	infinite_loop
stop_looping:
	endt

