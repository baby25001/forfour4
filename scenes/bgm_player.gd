extends Node2D

@export var BPM: float = 110
var next_variation: int = 0
var current_variation: int = 0
var loop: int = 0
var in_transition: bool = false

func _ready() -> void:
	var BPS = BPM/60
	var SPB = 1/BPS
	var measure_length = SPB * 4
	var loop_length = measure_length * 8
	
	$Timer.start(loop_length)
	_on_timer_timeout()

func _on_timer_timeout() -> void:
	loop += 1
	if in_transition:
		play_transition(current_variation, loop)
		return
	
	if current_variation == next_variation or is_even(loop):
		play_loop(current_variation)
	if next_variation > current_variation and not in_transition and not is_even(loop):
		current_variation += 1
		print("TRANSITION!!")
		in_transition = true
		loop = 1
		play_transition(current_variation, loop)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		next_variation += 1
		if next_variation > 2:
			next_variation = 2
	$Label.text = str(next_variation)
	$Label2.text = str(current_variation)

func is_even(number):
	if number % 2 == 0:
		return true
	return false

func play_loop(number):
	if not is_even(loop):
		print("play pad 1")
		$Pad1.play()
	else:
		print("play pad 2")
		$Pad2.play()
	
	if number >= 1:
		$Perc.play()
		$Drums.play()
	
	if number >= 2:
		$Bass.play()

func play_transition(variant, measure):
	if variant == 1:
		if measure == 1:
			$Bass.play()
			$Perc.play()
		elif measure == 2:
			$Bass.play()
			$Perc.play()
			$Drums.play()
		elif measure == 3:
			play_loop(variant)
		elif measure == 4:
			current_variation += 1
			in_transition = false
			play_loop(variant)
	if variant == 2:
		if measure == 1:
			$Bass.play()
		elif measure == 2:
			$Bass.play()
			$Pad2.play()
		elif measure == 3:
			play_loop(variant)
		elif measure == 4:
			current_variation += 1
			in_transition = false
			play_loop(variant)
