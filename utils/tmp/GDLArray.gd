class_name GDLArray
extends GDLCollectinWrapper

func _init(value: Array = []):
	_value = value

func append(value) -> void:
	_value.append(value)
