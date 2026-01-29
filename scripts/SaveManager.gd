
extends Node

var save_path = "user://best_records.cfg"
var best_times = {} 

func _ready():
	load_data()

func save_data():
	var config = ConfigFile.new()
	for key in best_times.keys():
		config.set_value("BestRecords", key, best_times[key])
	config.save(save_path)

func load_data():
	var config = ConfigFile.new()
	if config.load(save_path) == OK:
		for key in config.get_section_keys("BestRecords"):
			best_times[key] = config.get_value("BestRecords", key)

func check_and_save(level_idx: int, time_achieved: float):
	var key = "level_" + str(level_idx)
	if not best_times.has(key) or time_achieved < best_times[key]:
		best_times[key] = time_achieved
		save_data()
		return true
	return false

func get_best_time(level_idx: int):
	var key = "level_" + str(level_idx)
	return best_times.get(key, null)
