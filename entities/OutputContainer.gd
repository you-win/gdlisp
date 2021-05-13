extends MarginContainer

onready var upper_label: Label = $MarginContainer/VBoxContainer/UpperLabel
onready var lower_label: Label = $MarginContainer/VBoxContainer/LowerLabel

var _is_mouse_entered: bool = false

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	connect("mouse_entered", self, "_mouse_entered")
	connect("mouse_exited", self, "_mouse_exited")

func _input(event: InputEvent) -> void:
	if _is_mouse_entered:
		if event.is_action_pressed("click"):
			OS.clipboard = upper_label.text

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

###############################################################################
# Public functions                                                            #
###############################################################################

func get_value() -> String:
	return upper_label.text.strip_edges()
