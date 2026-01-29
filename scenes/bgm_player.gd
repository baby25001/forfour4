extends Node2D

@export var BPM: float = 110
var next_variation: int = 0
var current_variation: int = 0
var loop: int = 0

func _ready() -> void:
	var BPS = BPM/60
	var SPB = 1/BPS
	var measure_length = SPB * 4
	var loop_length = measure_length * 8
	
	$Timer.start(loop_length)
	_on_timer_timeout()

func _on_timer_timeout() -> void:
	loop += 1
	if next_variation == 0:
		play_loop()

func is_even(number):
	if number % 2 == 0:
		return true
	return false

func play_loop():
	if not is_even(loop):
		print("play pad 1")
		$Pad1.play()
	else:
		print("play pad 2")
		$Pad2.play()
	
