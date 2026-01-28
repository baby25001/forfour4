extends Node2D

var current_level = 0
var current_level_node: Node2D
var level_list = [
	{"name" : "default",
	"level" : preload("res://scenes/Levels and tilemaps/level_one.tscn")},
]

func _ready():
	var loaded = level_list[current_level]["level"].instantiate()
	add_child(loaded)
	current_level_node = loaded


func _on_restart_pressed() -> void:
	current_level_node.queue_free()
	
	var loaded = level_list[current_level]["level"].instantiate()
	add_child(loaded)
	current_level_node = loaded
