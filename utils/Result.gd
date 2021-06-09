class_name Result
extends Reference

var _tuple: Tuple2

func _init(v0, v1):
	_tuple = Tuple2.new(v0, v1)

func unwrap():
	# Error
	if _tuple.g1():
		AppManager.log_message("Unwrapped an error", true)
		return null
	else:
		return _tuple.g0()

func unwrap_err() -> String:
	return _tuple.g1()

func is_ok() -> bool:
	return not _tuple.g1()

func is_err() -> bool:
	return not is_ok()

func set_value(value) -> void:
	_tuple.s0(value)

func set_error(value) -> void:
	_tuple.s1(value)
