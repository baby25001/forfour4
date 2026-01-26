extends CharacterBody2D

const TOP_SPEED = 240
const MIN_SPEED = 80
var push_speed : float
var step = 20;
var target_x: float = position.x
var tile_map : TileMapLayer
var moving : bool = false
var push_direction: int = 0
var push_length: float = 0 

func _enter_tree() -> void:
	tile_map = get_node(get_meta("TileMap"))
	if tile_map != null:
		global_position = snap_to_grid()
		apply_floor_snap()
		step = tile_map.map_to_local(Vector2(1,0)).x - tile_map.map_to_local(Vector2(0,0)).x
	print(step)
	target_x = position.x


func _physics_process(delta):
	if $FloorDetector.get_collision_count() == 0:
		velocity += get_gravity() * delta
	else:
		velocity.y = 0
	
	if push_length > 0:
		#print("OKAY")
		push_speed = push_length/step * TOP_SPEED
		if push_speed < MIN_SPEED: push_speed = MIN_SPEED
		velocity.x = push_speed * push_direction
		#position.x = move_toward(position.x, target_x, push_speed * delta)
		push_length -= push_speed * delta
	else:
		velocity.x = 0
		push_length = 0
	
	if velocity == Vector2(0,0):
		moving = false
	else:
		moving = true
	move(velocity*delta)

func snap_to_grid(grid = tile_map):
	var locpos_to_center = grid.to_local(global_position) # local position to grid center
	var rounded_locpos = grid.map_to_local(grid.local_to_map(locpos_to_center))
	return tile_map.to_global(rounded_locpos)

func _on_block_push(direction):
	if moving: return
	#print("block_pushed")
	#if direction > 0:
	#	print("push right")
	#else:
	#	print("push_left")
	
	target_x = target_x + (step * direction)
	push_direction = direction
	push_length += step

func move(motion: Vector2):
	#print(motion, "MOTION")
	var x_portion = move_and_collide(Vector2(motion.x, 0))
	if x_portion:
		if x_portion.get_normal().x == 0:
			position.x += motion.x
		if motion.x > 0:
			modulate.g = 0.5
		modulate.r = 1
		if motion.y == 0:
			global_position.y = snap_to_grid().y
		debug_x(x_portion.get_normal())
	else:
		modulate.g = 1
		modulate.r = 0
		debug_x(Vector2(0,0))
	if motion.x == 0:
		global_position.x = snap_to_grid().x
	
	
	var y_portion = move_and_collide(Vector2(0, motion.y))
	if y_portion:
		var remain = y_portion.get_travel()
		print(remain)
		move_and_collide(remain)
		if y_portion.get_normal().y != 0:
			var collider = y_portion.get_collider()
			var colpos_transposed = to_local(collider.global_position) 
			var height_diff = abs(colpos_transposed.y - position.y)
			if height_diff < step:
				position.y = colpos_transposed.y + step
	#var ignore_y = false
	#var ignore_x = false
	#if global_position.x == snap_to_grid().x:
	#	ignore_x = true
	#if global_position.y == snap_to_grid().y:
	#	ignore_y = true
	#var test = move_and_collide(motion, true)
	#if test != null:
	#	print(test.get_normal())

func debug_x(collision_normal: Vector2):
	$X_Indicator.position = collision_normal * 20
