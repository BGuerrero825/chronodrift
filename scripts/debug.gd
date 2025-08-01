extends Node

var _tracker:= {}
var track_str:= ""

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
    print(value)
