extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -450.0
const RAY_LENGTH = 100
const BUFFER_WINDOW = 0.3

var grav_mod = 1.0
var push_left = Vector2(-300, 0)
var push_right = Vector2(300, 0)
var push_target = null

#Buffer system


@onready var ray = $RayCast2D

signal player_pushed(dir)
signal upwards_collision(motion: Vector2)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if $FloorDetector.get_collision_count() == 0:
		velocity += get_gravity() * grav_mod * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and $FloorDetector.get_collision_count() != 0:
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_pressed("ui_accept") and velocity.y < 200:
		grav_mod = 0.8
	else:
		grav_mod = 1
	
	if Input.is_action_just_released("ui_accept") and velocity.y <0:
		velocity.y = 0
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	ray.target_position.x = direction * RAY_LENGTH
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	change_push_target(ray.get_collider())
	if Input.is_action_just_pressed("ui_push"):
		player_pushed.emit(direction)
	
	move(velocity * delta)
	
	#for collide in get_slide_collision_count():
	#    var collision = get_slide_collision((collide))
	#    var collider = collision.get_collider()
	#    if ( 
	#        collider is RigidBody2D 
	#        and Input.is_action_just_pressed("ui_push") and Input.is_action_pressed("ui_left")
	#    ) :
	#        collision.get_collider().apply_central_impulse(push_left)
	#    elif ( 
	#        collider is RigidBody2D 
	#        and Input.is_action_just_pressed("ui_push") and Input.is_action_pressed("ui_right")
	#    ) :
	#        collision.get_collider().apply_central_impulse(push_right)

func move(motion: Vector2):
	var direction_vector = Vector2((motion.x/abs(motion.x)),(motion.y/abs(motion.y)))
	if motion.x == 0:
		direction_vector.x = 0
	if motion.y == 0:
		direction_vector.y = 0
		snap_to_floor()
	
	#print(motion, "MOTION")
	var x_test = move_and_collide(Vector2(motion.x, 0), true)
	if x_test == null:
		move_and_collide(Vector2(motion.x, 0))
	else:
		#position.y -= 0.08
		#if test_move(self.transform, Vector2(motion.x, 0)):
		#	move_and_collide(Vector2(motion.x, 0))
		#else:
		#	position.y += 0.08
			move_and_collide(x_test.get_remainder())
	var y_test = move_and_collide(Vector2(0, motion.y), true)
	if y_test == null:
		move_and_collide(Vector2(0, motion.y))
	else:
		move_and_collide(Vector2(0, motion.y))
		if y_test.get_collider() is CharacterBody2D and direction_vector.y == -1:
			if y_test.get_collider().has_method("_on_under_moved"):
				var fail_code = y_test.get_collider()._on_under_moved(self, motion, true)
				if fail_code == 0:
					return
		elif y_test.get_normal().y != 0:
			snap_to_floor()
		velocity.y = 0
		

func change_push_target(collider: Object) -> bool: # changes push target, returns bool if push target was changed
	
	if collider == push_target:
		return false
	
	if push_target != null:
		player_pushed.disconnect(push_target._on_block_push)
		push_target = null
	
	if collider == null:
	#	print("NOT")
		return false
	#else:
	#	print("COLLIDING")
	
	if collider.has_method("_on_block_slide") and collider.is_sliding == true:
		push_target = collider
		player_pushed.connect(push_target._on_block_slide)
	elif collider.has_method("_on_block_push"):
		push_target = collider
		player_pushed.connect(push_target._on_block_push)
	return true

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
