extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var push_left = Vector2(-300, 0)
var push_right = Vector2(300, 0)
@onready var up_detector = get_node("UpDetector") #not used in code yet

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# Handle collision
	for collide in get_slide_collision_count():
		var collision = get_slide_collision((collide))
		var collider = collision.get_collider()
		if ( 
			collider is RigidBody2D 
			and Input.is_action_just_pressed("ui_push") and Input.is_action_pressed("ui_left")
		) :
			collider.apply_central_impulse(push_left)
		elif ( 
			collider is RigidBody2D 
			and Input.is_action_just_pressed("ui_push") and Input.is_action_pressed("ui_right")
		) :
			collider.apply_central_impulse(push_right)
