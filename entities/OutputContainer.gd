extends MarginContainer

@onready var upper_label: Label = $MarginContainer/VBoxContainer/UpperLabel
@onready var lower_label: Label = $MarginContainer/VBoxContainer/LowerLabel

var _is_mouse_entered: bool = false

var upper_text: String = ""
var lower_text: String = ""

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	self.mouse_entered.connect(_mouse_entered)
	self.mouse_exited.connect(_mouse_exited)
	
	upper_label.text = upper_text
	lower_label.text = lower_text

func _input(event: InputEvent) -> void:
	if _is_mouse_entered:
		if event.is_action_pressed("click"):
#			OS.clipboard = _fix_text(upper_label.text)
			# TODO not yet implemented in Godot 4
			pass

###############################################################################
# Connections                                                                 #
###############################################################################

func _mouse_entered() -> void:
	_is_mouse_entered = true

func _mouse_exited() -> void:
	_is_mouse_entered = false

###############################################################################
# Private functions                                                           #
###############################################################################

func _fix_text(text: String) -> String:
	return text.replace("    ", "\t")

###############################################################################
# Public functions                                                            #
###############################################################################

func get_value() -> String:
	return upper_label.text.strip_edges()
