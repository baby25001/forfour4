extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const RAY_LENGTH = 100
var push_left = Vector2(-300, 0)
var push_right = Vector2(300, 0)
var push_target = null

@onready var ray = $RayCast2D

signal player_pushed(dir)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if $FloorDetector.get_collision_count() == 0:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and $FloorDetector.get_collision_count() != 0:
		velocity.y = JUMP_VELOCITY

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
	#print(motion, "MOTION")
	var x_portion = move_and_collide(Vector2(motion.x, 0))
	if not x_portion:
		pass
	var y_portion = move_and_collide(Vector2(0, motion.y))
	if y_portion:
		if y_portion.get_normal() == Vector2(0, 1):
			velocity.y = 0
		var remain = y_portion.get_travel()
		move_and_collide(remain)

func change_push_target(collider: Object) -> void: # changes push target
	
	if collider == push_target:
		return
	
	if push_target != null:
		player_pushed.disconnect(push_target._on_block_push)
		push_target = null
	
	if collider == null:
		print("NOT")
		return
	else:
		print("COLLIDING")
	
	if collider.has_method("_on_block_push"):
		push_target = collider
		player_pushed.connect(push_target._on_block_push)
