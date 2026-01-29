extends Node2D

signal text_finished(move_by: float)
signal dialogue_ended(move_by: float)


var path = "res://dialogue test/tester.json"
var text_box = preload("res://dialogue test/textbox.tscn")
var dialogue_library = []
var monologue_library = []
var dialogue = []
var code = 0 #keeps track of the current dialog

@onready var rng = RandomNumberGenerator.new()
@onready var speaker_list =[
	{
		"voice" : get_node("undeep male"),
		"pitch" : 1,
		"color" : Color.DARK_BLUE
	},
	{
		"voice": get_node("from telephone"),
		"pitch" : rng.randf_range(1,1.5),
		"color": Color.DARK_RED
	}
]


enum {
	EMPTY,
	DIALOGUE,
	MONOLOGUE,
}
var printing : int = EMPTY

func _ready() -> void:
	dialogue_library = read_JSON_data(path).get("DIALOGUE", [])
	monologue_library = read_JSON_data(path).get("MONOLOGUE", [])


var count = 0
var recent_text:Node
func next():
	if count >= dialogue.size():
		finish()
		return
	print("where instantiate happens")
	var new_text = text_box.instantiate()
	
	add_child(new_text)
	new_text.is_finished.connect(on_text_finish)
	new_text.tween_finished.connect(on_tween_finish)
	recent_text = new_text


func on_text_finish(box_code):
	if box_code != code:
		pass
		return
	count += 1
	text_finished.emit(-400)

func on_tween_finish(source):
	source.is_finished.disconnect(on_text_finish)
	source.tween_finished.disconnect(on_tween_finish)
	next()

func read_JSON_data(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var data = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(data) != OK:
		return {}
	return json.get_data()

func finish(fail: bool = false):
	var was_printing = printing
	print("okay it should STOP NOW")
	dialogue = []
	dialogue_ended.emit(-300)
	await child_exiting_tree
	
	count = 0
	if was_printing == DIALOGUE:
		pass
	if not fail:
		printing = EMPTY

func dialogue_from_dict(type: Variant, dict: Dictionary, previous: int = -1) -> int:
	if count < dialogue.size():
		await recent_text.tween_finished
	
	code += 1
	count = 0
	printing = type
	if printing == DIALOGUE: print("IM JUST CHECKING OKAY")
	var num = rng.randi_range(1, dict.size())
	if num == previous:
		num = rng.randi_range(1,dict.size())
	dialogue = dict[str(num)]
	print(dialogue)
	next()
	return num

var prev_dia: int = -1
func _on_dialogue_timer_timeout() -> void:
	if printing == DIALOGUE:
		return
	elif printing != EMPTY:
		finish(true)
	prev_dia = await dialogue_from_dict(DIALOGUE, dialogue_library, prev_dia)

var prev_mon:int = -1
func _on_start_monologue() -> void:
	if printing != EMPTY:
		print("MONOLOGUE STOPPED")
		return

	if true:
		prev_mon = await dialogue_from_dict(MONOLOGUE, monologue_library, prev_mon)
