extends Node2D

var current_level = 0
var current_level_node: Node2D
var level_list = [
	{"name" : "Introduction to Cardboards",
	"level" : preload("res://scenes/Levels and tilemaps/level_one.tscn")},
	{"name" : "Sorting 101",
	"level" : preload("res://scenes/Levels and tilemaps/level_two.tscn")},
	{"name" : "Boxes in Motion",
	"level" : preload("res://scenes/Levels and tilemaps/level_three.tscn")},
	{"name" : "Multi-box tasking",
	"level" : preload("res://scenes/Levels and tilemaps/level_four.tscn")},
	{"name" : "Industrial Equipment",
	"level" : preload("res://scenes/Levels and tilemaps/level_rail_tut.tscn")},
	{"name" : "box gymnastics",
	"level" : preload("res://scenes/Levels and tilemaps/level_gymnastics.tscn")},
	{"name" : "not fragile?",
	"level" : preload("res://scenes/Levels and tilemaps/level_architecture.tscn")},
	{"name" : "musical boxes",
	"level" : preload("res://scenes/Levels and tilemaps/level_dizzy.tscn")},
]

signal bgm_changed

@onready var stopwatch = $Stopwatch
@onready var best_label = $BestLabel

func _ready():
	load_current()
	current_level_node.process_mode = Node.PROCESS_MODE_DISABLED
	$AnimationPlayer.play("enter")

func _on_restart_pressed() -> void:
	current_level_node.queue_free()
	load_current()
	current_level_node.process_mode = Node.PROCESS_MODE_DISABLED
	$AnimationPlayer.play("restart")

func _on_level_change(to) -> void:
	if stopwatch:
		SaveManager.check_and_save(current_level, stopwatch.get_time())
		stopwatch.stop()
	
	current_level += 1
	#current_level = to
	if current_level == 3 or current_level == 6:
		print("BGM CHANGED")
		bgm_changed.emit()
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
	
	if stopwatch and best_label:
		stopwatch.reset()
		stopwatch.start()
		update_best_display()


func update_best_display():
	var record = SaveManager.get_best_time(current_level)
	if record != null:
		best_label.text = "BEST TIME: " + stopwatch.format_time(record)
	else:
		best_label.text = "NO BEST TIME YET-"
