extends CharacterBody2D

const TOP_SPEED = 500
const MIN_SPEED = 100
const SLIDE_SPEED = 400
var push_speed : float
var step = 20;
var target_x: float = position.x
var tile_map : TileMapLayer
var moving : bool = false
var push_direction: int = 0
var push_length: float = 0 
var is_sliding = false
var sliding: int = 0

signal stopped_moving
signal started_moving

func _enter_tree() -> void:
	is_sliding = get_meta("is_sliding")
	tile_map = get_node(get_meta("TileMap")).get_node("Platform")
	if tile_map != null:
		global_position = snap_to_grid()
		apply_floor_snap()
		step = tile_map.map_to_local(Vector2(1,0)).x - tile_map.map_to_local(Vector2(0,0)).x
	print(step)
	target_x = position.x

var prev_floor;
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
	
	if sliding:
		velocity.x = sliding * SLIDE_SPEED
	
	#if velocity.y != 0:
	#	print(self)
	if velocity == Vector2(0,0):
		if moving == true:
			print("STOPPED MOVING")
			stopped_moving.emit()
		moving = false
	else:
		if moving == false:
			print("STARTED MOVING")
			started_moving.emit()
		moving = true
	move(velocity*delta)

func snap_to_grid(grid = tile_map):
	var locpos_to_center = grid.to_local(global_position) # local position to grid center
	var rounded_locpos = grid.map_to_local(grid.local_to_map(locpos_to_center))
	return tile_map.to_global(rounded_locpos)

func _on_block_push(direction):
	if moving: return
	if get_top_box():
		get_top_box()._on_block_push(direction)
	
	$WallDetector.target_position.x = direction * step
	$WallDetector.force_raycast_update()
	if $WallDetector.is_colliding():
		print("NEATO")
		return
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
	
	if direction_vector.y > 0 and sliding:
		if check_low_wall():
			sliding = 0
			velocity.x = 0
			motion.x = 0
			print("LowWall!!")
	var x_test = move_and_collide(Vector2(motion.x, 0), true)
	if x_test == null:
		move_and_collide(Vector2(motion.x, 0))
		debug_x(Vector2(0,0))
		self_modulate.r = 0
	else:
		#print("collision happened?")
		self_modulate.r = 1
		sliding = 0
		push_length = 0
		global_position.x = snap_to_grid().x
		#move_and_collide(x_test.get_remainder())
		debug_x(x_test.get_normal())
		if x_test.get_normal().y != 0:
			print(self, x_test.get_collider())
#	else:
		#print("yeah stop em!")
	
	
	var y_test = move_and_collide(Vector2(0, motion.y))
	if y_test == null:
		pass
	else:
		if y_test.get_collider() is CharacterBody2D and direction_vector.y == -1:
			if y_test.get_collider().has_method("_on_under_moved"):
				var fail_code = y_test.get_collider()._on_under_moved(self, motion, true)
				if fail_code == 1:
					velocity.y = 0
		elif y_test.get_normal().y != 0:
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
	move_and_collide(Vector2(0, snap))

func get_top_box():
	var count = $BoxDetector.get_collision_count()
	
	for n in count:
		var collider = $BoxDetector.get_collider(n)
		if collider is CharacterBody2D and collider.has_method("_on_block_push"):
			return collider
	return null

func _on_under_moved(under: Node, motion: Vector2, ignore_x = false):
	var error_code = 0
	var test = move_and_collide(motion, true)
	if test:
		error_code = 1
		if test.get_collider().has_method("_on_under_moved"):
			error_code = 0
	
	if ignore_x:
		velocity.y = motion.y/under.get_physics_process_delta_time()
		move(motion)
	else:
		velocity.y = motion.y/under.get_physics_process_delta_time()
		move(motion)
	return error_code

func debug_x(collision_normal: Vector2):
	$X_Indicator.position = collision_normal * 20

func slide(direction):
	sliding = direction

func check_low_wall():
	$LowWallDetector.target_position.x = sliding * 100
	$LowWallDetector.force_shapecast_update()
	var count =  $LowWallDetector.get_collision_count()
	if count == 0:
		return false
	
	for n in count:
		var collision_norm = $LowWallDetector.get_collision_normal(n)
		if collision_norm.x == -sliding:
			print($LowWallDetector.get_collision_point(n))
			return true
	
	return false

func _on_block_slide(direction):
	print("sliding box pusheeeddd")
	if moving: return
	if get_top_box():
		get_top_box()._on_block_slide(direction)
	
	#print("block_pushed")
	#if direction > 0:
	#	print("push right")
	#else:
	#	print("push_left")
	
	slide(direction)
