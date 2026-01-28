extends Node2D

signal level_changed(to: int)

func _level_finished() -> void:
	print("Next level (2)", level_changed.get_connections())
	
	level_changed.emit(1)
	
