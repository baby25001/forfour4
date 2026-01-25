extends CharacterBody2D

var step = 20;

func _enter_tree() -> void:
	var tile_map : TileMapLayer= get_node(get_meta("TileMap"))
	var locpos_to_center = tile_map.to_local(global_position) # local position to grid center
	var rounded_locpos = tile_map.map_to_local(tile_map.local_to_map(locpos_to_center))
	global_position = tile_map.to_global(rounded_locpos)
	if tile_map != null:
		step = tile_map.map_to_local(Vector2(1,0)).x - tile_map.map_to_local(Vector2(0,0)).x
	print(step)

func _on_block_push(direction):
	print("block_pushed")
	position.x += step * direction
