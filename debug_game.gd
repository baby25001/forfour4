extends Node2D


func _physics_process(_delta: float) -> void:
	var push_box_1 = $"push_box 1".velocity
	var PushBox = $PushBox.velocity
	var PushBox2 = $PushBox2.velocity
	var character = $Character.velocity
	#print(push_box_1,"     ",PushBox,"     ",PushBox2, "     ", character)
	#if push_box_1 == PushBox:
	#	print("SAME")
	#else:
	#	print("NOPE")
