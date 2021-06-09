class_name GDLCollectinWrapper
extends Reference

var _value
	
func set(key, value):
	_value[key] = value

func get(key):
	return _value[key]

func get_raw_value():
	return _value

func duplicate():
	return _value.duplicate(true)

func _to_string() -> String:
	return "GDLCollectionWrapper:%s" % str(_value)
