extends Node2D

func _level_finished() -> void:
	print("Next level (3)")
	get_tree().change_scene_to_file("res://level_three.tscn")
