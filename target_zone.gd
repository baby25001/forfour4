extends Node2D

var left = false
var right = false
var up = false
var down = false
signal level_finished

func _process(_delta: float) -> void:
	if left == true and right == true and up == true and down == true:
		print("Target box in")
		left = false
		right = false
		up = false
		down = false
		level_finished.emit()
	

func _on_left_body_entered(body: Node2D) -> void:
	var target = body.get_name()
	if target == "TargetBox":
		left = true
	#elif target == "Character":
		#left = true

func _on_right_body_entered(body: Node2D) -> void:
	var target = body.get_name()
	if target == "TargetBox":
		right = true
	#elif target == "Character":
		#right = true

func _on_up_body_entered(body: Node2D) -> void:
	var target = body.get_name()
	if target == "TargetBox":
		up = true
	#elif target == "Character":
		#up = true

func _on_down_body_entered(body: Node2D) -> void:
	var target = body.get_name()
	if target == "TargetBox":
		down = true
	#elif target == "Character":
		#down = true
	
