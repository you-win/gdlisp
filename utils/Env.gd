class_name Env
extends Reference

var _inner: Dictionary # This scope
var _outer: Env # Outer scope

func _init(outer: Env = null, param_names: Array = [], param_values: Array = []):
	_inner = {}
	if outer: # If null, then there is probably no global scope
		_outer = outer

	# params and call_args must match up
	if param_names.size() != param_values.size():
		return
	
	for i in param_names.size():
		_inner[param_names[i]] = param_values[i]

func find(key: String):
	if key in _inner:
		return _inner[key]
	elif _outer:
		return _outer.find(key)

#	return null

	return Error.new("Attempted to reference non-existent value")

func add(key: String, value) -> void:
	_inner[key] = value

func remove(key: String) -> bool:
	return _inner.erase(key)

func set_existing_value(key: String, value) -> bool:
	if key in _inner:
		_inner[key] = value
		return true
	elif _outer:
		return _outer.set_existing_value(key, value)
	return false
