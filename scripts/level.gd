extends Node2D

signal start_monologue
signal level_changed(to: int)

@onready var rng = RandomNumberGenerator.new()

func _ready() -> void:
	if GM.first_time == true:
		await get_tree().create_timer(2.0).timeout
		start_monologue.emit()
		print("Monologue starts")
		GM.first_time = false
	elif GM.first_time == false:
		print("Monologue may start")
		if rng.randi_range(1, 5) == 1:
			await get_tree().create_timer(2.0).timeout
			start_monologue.emit()
			print("Monologue starts")

func _level_finished() -> void:
	print("Next level (2)", level_changed.get_connections())
	
	#get_tree().change_scene_to_file("res://scenes/Levels and tilemaps/level_two.tscn")
	level_changed.emit(get_meta("next_level"))
	
