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
	var direction_vector = Vector2((motion.x/abs(motion.x)),(motion.y/abs(motion.y)))
	if motion.x == 0:
		global_position.x = snap_to_grid().x
		direction_vector.x = 0
	if motion.y == 0:
		snap_to_floor()
		direction_vector.y = 0
	
	var x_test = move_and_collide(Vector2(motion.x, 0), true)
	if x_test == null:
		move_and_collide(Vector2(motion.x, 0))
		debug_x(Vector2(0,0))
		modulate.r = 0
	elif test_move(transform, Vector2(step * direction_vector.x, 0)):
		#print("collision happened?")
		modulate.r = 1
		move_and_collide(x_test.get_remainder())
		debug_x(x_test.get_normal())
#	else:
		#print("yeah stop em!")
	
	
	var y_test = move_and_collide(Vector2(0, motion.y), true)
	if y_test == null:
		move_and_collide(Vector2(0, motion.y))
	else:
		move_and_collide(y_test.get_remainder())
		#for i in 2:
		#	var y2_test = move_and_collide(Vector2(0, (1.0/(1.0+i) * motion.y)), true)
		#	if y2_test == null:
		#		move_and_collide(Vector2(0, (1.0/(1.0+i) * motion.y)))
		#	else:
		#		move_and_collide(y2_test.get_remainder())
		snap_to_floor()
		velocity.y = 0

func snap_to_floor():
	$FloorDetector.force_shapecast_update()
	var count = $FloorDetector.get_collision_count() 
	
	if  count == 0:
		return
	
	var furthest_distance: float = -10
	for n in count:
		var collision = $FloorDetector.get_collision_point(n)
		var delta = collision.y - global_position.y
		#print(position, "position", collision, "collision  ", delta)
		if delta < 0:
			continue
		if delta > furthest_distance:
			furthest_distance = delta
	
	if furthest_distance < 0: return
	
	var floor_distance = $BottomIndicator.global_position.y - global_position.y
	var snap =  furthest_distance - floor_distance
	global_position.y += snap

func debug_x(collision_normal: Vector2):
	$X_Indicator.position = collision_normal * 20
