extends CharacterBody2D

const TOP_SPEED = 240
const MIN_SPEED = 80
var push_speed : float
var step = 20;
var target_x: float = position.x
var tile_map : TileMapLayer
var is_pushed : bool = false
var push_direction: int = 0
var push_length: float = 0 

func _enter_tree() -> void:
	tile_map = get_node(get_meta("TileMap"))
	if tile_map != null:
		global_position = snap_to_grid()
		step = tile_map.map_to_local(Vector2(1,0)).x - tile_map.map_to_local(Vector2(0,0)).x
	print(step)
	target_x = position.x

func _physics_process(delta):
	if $FloorDetector.get_collision_count() == 0:
		velocity.y += 10 * delta
		print(velocity)
	else:
		if velocity.y > 0:
			global_position.y = snap_to_grid().y
			velocity = Vector2(0,0)
	position += velocity
	
	if push_length > 0:
		print("OKAY")
		push_speed = push_length/step * TOP_SPEED
		if push_speed < MIN_SPEED: push_speed = MIN_SPEED
		#velocity.x = push_speed
		position.x = move_toward(position.x, target_x, push_speed * delta)
		push_length -= push_speed * delta
		if push_length < 0.2* step: is_pushed = false;
	else:
		global_position.x = snap_to_grid().x
		velocity.x = 0
		push_length = 0
		is_pushed = false

func snap_to_grid():
	var locpos_to_center = tile_map.to_local(global_position) # local position to grid center
	var rounded_locpos = tile_map.map_to_local(tile_map.local_to_map(locpos_to_center))
	return tile_map.to_global(rounded_locpos)

func _on_block_push(direction):
	if is_pushed: return
	#print("block_pushed")
	#if direction > 0:
	#	print("push right")
	#else:
	#	print("push_left")
	
	push_direction = direction
	target_x = target_x + (step * direction)
	push_length += step
	is_pushed = true

func move_x_pos(next):
	var start = position.x
	var direction = (next-start)/abs(next-start)
