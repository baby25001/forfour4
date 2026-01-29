extends Node2D

var current_level = 0
var current_level_node: Node2D
var level_list = [
	{"name" : "default",
	"level" : preload("res://scenes/Levels and tilemaps/level_one.tscn")},
	#"level" : preload("res://scenes/Levels and tilemaps/level_two.tscn")},
	{"name" : "default",
	"level" : preload("res://scenes/Levels and tilemaps/level_two.tscn")},
	{"name" : "default",
	"level" : preload("res://scenes/Levels and tilemaps/level_three.tscn")},
	{"name" : "musical boxes",
	"level" : preload("res://scenes/Levels and tilemaps/level_dizzy.tscn")},
]



func _ready():
	
	load_current()
	#await ge"res://scenes/Levels and tilemaps/level_dizzy.tscn"t_tree().create_timer(0.1).timeout
	current_level_node.process_mode = Node.PROCESS_MODE_DISABLED
	$AnimationPlayer.play("enter")
	
	


func _on_restart_pressed() -> void:
	current_level_node.queue_free()
	load_current()
	current_level_node.process_mode = Node.PROCESS_MODE_DISABLED
	$AnimationPlayer.play("restart")

func _on_level_change(to) -> void:
	current_level = to
	if current_level >= level_list.size():
		return
	
	current_level_node.process_mode = Node.PROCESS_MODE_DISABLED
	$AnimationPlayer.play("leave")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "enter":
		current_level_node.process_mode = Node.PROCESS_MODE_INHERIT
	
	if anim_name == "restart":
		current_level_node.process_mode = Node.PROCESS_MODE_INHERIT
	
	if anim_name == "leave":
		current_level_node.queue_free()
		
		load_current()
		current_level_node.process_mode = Node.PROCESS_MODE_DISABLED
		$AnimationPlayer.play("enter")

func load_current():
	var loaded = level_list[current_level]["level"].instantiate()
	$Animate.add_child(loaded)
	loaded.position = Vector2(0,0)
	loaded.level_changed.connect(_on_level_change)
	current_level_node = loaded
