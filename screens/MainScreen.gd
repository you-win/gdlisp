extends Control

const MAX_OUTPUT_COUNT: int = 50

onready var output: VBoxContainer = $CanvasLayer/OutputContainer/ScrollContainer/Output
onready var scroll_container: ScrollContainer = $CanvasLayer/OutputContainer/ScrollContainer
onready var input: LineEdit = $CanvasLayer/InputContainer/Input

var gd_lisp: GDLisp = GDLisp.new()

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("send_input"):
		var input_label := Label.new()
		input_label.text = input.text
		output.call_deferred("add_child", input_label)
		
		var lisp_label := Label.new()
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


