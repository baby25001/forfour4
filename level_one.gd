extends Node2D

func _level_finished() -> void:
	print("Next level (2)")
	get_tree().change_scene_to_file("res://level_two.tscn")
