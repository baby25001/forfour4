extends TileMapLayer

func _enter_tree() -> void:
	print(map_to_local(Vector2(1,0)).x - map_to_local(Vector2(0,0)).x)
