extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const RAY_LENGTH = 40
var push_left = Vector2(-300, 0)
var push_right = Vector2(300, 0)
var push_target = null

@onready var ray = $RayCast2D

signal player_pushed

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
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
		player_pushed.emit()
	
	move_and_slide()
	
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
