extends Node2D

var collision = false
@onready var railing_area = get_node("ObjectDetector")

func _ready() -> void:
	if get_node(get_meta("tile_map")) != null:
		global_position = snap_to_grid(get_node(get_meta("tile_map")).get_node("Platform"))
	railing_area.modulate = Color("ffffff00")

func _process(_delta: float) -> void:
	if collision == true:
		self.set_collision_layer_value.call_deferred(2, true)
	elif collision == false:
		self.set_collision_layer_value.call_deferred(2, false)


func _on_object_detector_body_entered(body: Node2D) -> void:
	var target = body.get_name()
	if target != "Character":
		collision = true
		print("There's box")

func _on_object_detector_body_exited(body: Node2D) -> void:
	var target = body.get_name()
	if target != "Character":
		collision = false
		print("There's no box")

func snap_to_grid(grid):
	var locpos_to_center = grid.to_local(global_position) # local position to grid center
	var rounded_locpos = grid.map_to_local(grid.local_to_map(locpos_to_center))
	return grid.to_global(rounded_locpos)
