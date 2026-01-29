extends Node2D

var label : Label
var timer : Timer
var parent

signal is_finished(code)
signal tween_finished(from : Node2D)
signal deleted

var code: int = 0
var text: String = "my balls are itchy \ntest"

# this is for tweening
var tween: Tween
var target_color: Color
var final_position: Vector2
var speed: float
var pause: float
var audio: AudioStreamPlayer2D




func _enter_tree() -> void:
	label = get_node("MarginContainer/MarginContainer/Label")
	
	
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	parent = get_parent()
	code = parent.code
	var count = parent.count
	
	var dictionary = parent.dialogue[count]
	label.text = dictionary["text"]
	speed = dictionary["scroll"]
	pause = dictionary["pause"]
	
	var speaker = parent.speaker_list[dictionary["speaker"] -1]
	audio = speaker["voice"]
	audio.pitch_scale = speaker["pitch"]
	label.modulate = speaker["color"]
	
	parent.text_finished.connect(play_finished)
	parent.dialogue_ended.connect(move_delete)
	
	play_text(speed)

var visible_delta: float
func play_text(char_ps : float):
	visible_delta = 1.0/label.text.length()
	timer.start(char_ps)


func _on_timer_timeout() -> void:
	label.set_visible_ratio(label.get_visible_ratio() + visible_delta)
	audio.play()
	if label.visible_characters == -1:
		timer.stop()
		await get_tree().create_timer(pause).timeout
		is_finished.emit(code)

var step = 0
func play_finished(by: float):
	if step >= 2:
		move_delete(by)
	else:
		move_up(by)
	step+=1



func move_up(by: float):
	tween = get_tree().create_tween().set_parallel(true)
	final_position = position + Vector2(0, by) * (step+1)
	
	var cur_color = $MarginContainer.self_modulate
	target_color = cur_color - Color(0,0,0,0.3)
	
	tween.tween_property($MarginContainer, "position", final_position, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($MarginContainer, "modulate", target_color, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.finished.connect(moveup_ended)

func move_delete(by: float):
	parent.text_finished.disconnect(play_finished)
	parent.dialogue_ended.disconnect(move_delete)
	tween = get_tree().create_tween().set_parallel(true)
	final_position = position + Vector2(0, by) * (step+1)
	
	var cur_color = $MarginContainer.self_modulate
	target_color = cur_color - Color(0,0,0,1)
	
	tween.tween_property($MarginContainer, "position", final_position, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($MarginContainer, "modulate", target_color, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.finished.connect(movedel_ended)

func moveup_ended():
	tween_finished.emit(self)

func movedel_ended():
	deleted.emit()
	queue_free()
