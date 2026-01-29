extends Control

var time := 0.0
var running := false

@onready var label: Label = $Label

func _process(delta):
	if running:
		time += delta
		label.text = format_time(time)

func start():
	running = true

func stop():
	running = false

func reset():
	time = 0.0
	label.text = format_time(time)

func get_time() -> float:
	return time

func format_time(t: float) -> String:
	var minutes := int(t) / 60
	var seconds := int(t) % 60
	var millis := int((t - int(t)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, millis]
