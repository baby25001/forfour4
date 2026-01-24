extends RigidBody2D

@onready var surface_detector = get_node("SurfaceDetector")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if surface_detector.is_colliding:
		var surface = surface_detector.get_collider(0)
		var box = surface_detector.get_parent()
		if surface is RigidBody2D:
			box.mass = 0.001
			box.global_position.x = surface.global_position.x
		elif surface is CharacterBody2D:
			pass
			#still need to make the box hover above player and follow player's movement
		else:
			box.mass = 1
