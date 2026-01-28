extends Node2D

signal level_changed(to: int)

func _level_finished() -> void:
	print("Next level (2)", level_changed.get_connections())
	
	#get_tree().change_scene_to_file("res://scenes/Levels and tilemaps/level_two.tscn")
	level_changed.emit(get_meta("next_level"))
	
