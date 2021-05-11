extends Control

const MAX_OUTPUT_COUNT: int = 50

const OUTPUT_LABEL: Resource = preload("res://entities/OutputLabel.tscn")

onready var output: VBoxContainer = $CanvasLayer/OutputContainer/ScrollContainer/Output
onready var scroll_container: ScrollContainer = $CanvasLayer/OutputContainer/ScrollContainer
onready var input: TextEdit = $CanvasLayer/InputContainer/Input

var gd_lisp: GDLisp = GDLisp.new()

var is_super_pressed: bool = false

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	input.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("super"):
		is_super_pressed = true
	elif event.is_action_released("super"):
		is_super_pressed = false
	elif (event.is_action_pressed("send_input") and is_super_pressed):
		# var input_label := LineEdit.new()
		var input_label: Label = OUTPUT_LABEL.instance()
		input_label.text = input.text
		output.call_deferred("add_child", input_label)
		
		# var lisp_label := LineEdit.new()
		var lisp_label: Label = OUTPUT_LABEL.instance()
		var gd_lisp_result = gd_lisp.parse_string(input.text)
		if gd_lisp_result:
			lisp_label.text = str(gd_lisp_result)
		else:
			lisp_label.text = "~done"
		output.call_deferred("add_child", lisp_label)
		
		yield(lisp_label, "ready")
		
		while output.get_child_count() > 50:
			output.get_child(0).free()
		
		yield(get_tree(), "idle_frame")
		
		scroll_container.scroll_vertical = int(scroll_container.get_v_scrollbar().max_value)
		
		# Clear input
		input.text = ""

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################


