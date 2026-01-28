extends Node2D

var collision = false
@onready var railing = get_node("../Railing")
@onready var railing_area = get_node("ObjectDetector")

func _ready() -> void:
	railing_area.modulate = Color("ffffff00")

func _process(_delta: float) -> void:
	if collision == true:
		railing.set_collision_layer_value.call_deferred(2, true)
	elif collision == false:
		railing.set_collision_layer_value.call_deferred(2, false)


func _on_object_detector_body_entered(body: Node2D) -> void:
	var target = body.get_name()
	if target != "Character":
		collision = true
		print("There's box")

func _on_object_detector_body_exited(body: Node2D) -> void:
	var target = body.get_name()
	if target != "Character":
		collision = false
		print("There's no box")
