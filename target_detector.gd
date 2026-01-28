extends Sprite2D

var is_target:bool
var target: Node2D
var tile_map: TileMapLayer
var moving: bool = false
var in_target: bool = false

signal reached_target

func _enter_tree() -> void:
	is_target = get_meta("IsTarget")
	
	if is_target:
		if get_node(get_meta("TileMap")).get_node("Platform") is TileMapLayer:
			tile_map = get_node(get_meta("TileMap")).get_node("Platform")
			global_position = snap_to_grid()
			z_index = -1
	else:
		target = get_node(get_meta("TargetPos")).get_node("Area2D")
		z_index = 3

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_target:
		return
	
	if area == target:
		print("target_reached!!")
		#reached_target.emit()
		in_target = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if is_target:
		return
	
	if area == target:
		print("target_exited :(")
		#reached_target.emit()
		in_target = false

func snap_to_grid(grid = tile_map):
	var locpos_to_center = grid.to_local(global_position) # local position to grid center
	var rounded_locpos = grid.map_to_local(grid.local_to_map(locpos_to_center))
	return tile_map.to_global(rounded_locpos)

func _on_start_moving():
	moving = true

func _on_stop_moving():
	if in_target:
		reached_target.emit()
	moving = false
