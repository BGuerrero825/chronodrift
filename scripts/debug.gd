extends Node

var _tracker := {}
var track_str := ""

var _log := []
const log_max_count := 5
var log_str := ""

func track(track_id: String, value: Variant = "") -> void:
	if not OS.is_debug_build():
		return

	_tracker[track_id] = value
	
	var result_str:= ""
	for key: String in _tracker.keys():
		result_str += key + ": " + str(_tracker[key]) + "\n"
	
	track_str = result_str

func log(value: Variant) -> void:
	# TODO: add a HUD print console
	
	_log.insert(0, str(Time.get_ticks_msec()) + ": " + value)

	if _log.size() > log_max_count:
		_log.pop_back()
	
	log_str = "\n".join(_log)
