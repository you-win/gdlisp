extends Label

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
			OS.clipboard = self.text

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


