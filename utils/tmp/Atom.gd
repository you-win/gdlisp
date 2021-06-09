class_name Atom
extends Reference

enum { Sym = 0, Num, Str }

var type: int
var value

func _init(atom_type: int, atom_value):
	type = atom_type
	value = atom_value

func _to_string() -> String:
	if type == Num:
		return str(value)
	return value

func get_value():
	return value
