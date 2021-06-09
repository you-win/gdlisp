class_name Exp
extends Reference

enum ExpType { None = 0, Atom, List }
var type
var value

func _init(exp_type, exp_value):
	type = exp_type
	value = exp_value

func _to_string() -> String:
	if type == ExpType.Atom:
		return value.to_string()
	return str(value)

func append(v) -> void:
	match type:
		ExpType.List:
			if typeof(v) == TYPE_ARRAY:
				(value as Array).append_array(v)
			else:
				(value as Array).append(v)
		ExpType.Atom:
			AppManager.log_message("Tried to append to an Atom")

func get_value():
	match type:
		ExpType.List:
			return (value as Array)
		ExpType.Atom:
			return value

func get_raw_value():
	match type:
		ExpType.List:
			return (value as Array)
		ExpType.Atom:
			return value.get_value()
