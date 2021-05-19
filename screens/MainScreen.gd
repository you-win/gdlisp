extends Control

const MAX_OUTPUT_COUNT: int = 50

const OUTPUT_CONTAINER: Resource = preload("res://entities/OutputContainer.tscn")

onready var output: VBoxContainer = $CanvasLayer/OutputContainer/ScrollContainer/Output
onready var scroll_container: ScrollContainer = $CanvasLayer/OutputContainer/ScrollContainer
onready var input: TextEdit = $CanvasLayer/InputContainer/Input

var _gd_lisp: GDLisp = GDLisp.new()

var _is_super_pressed: bool = false

var _current_history_position: int = 0
var _current_input_state: String = ""

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	if OS.is_debug_build():
		var oc0: MarginContainer = OUTPUT_CONTAINER.instance()
		output.call_deferred("add_child", oc0)
		
		yield(oc0, "ready")
		
		oc0.upper_label.text = "Running sanity tests"
		oc0.lower_label.text = "uwu"
		
		var sanity_test: TestBase = load("res://tests/SanityTests.gd").new()
		sanity_test.run_tests()
		
		var oc1: MarginContainer = OUTPUT_CONTAINER.instance()
		output.call_deferred("add_child", oc1)
		
		yield(oc1, "ready")
		
		oc1.upper_label.text = "Finished sanity tests"
		oc1.lower_label.text = "All passed (clearly)"
	
	input.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("super"):
		_is_super_pressed = true
	elif event.is_action_released("super"):
		_is_super_pressed = false
	elif _is_super_pressed:
		if event.is_action_pressed("send_input"):
			_send_input()
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_up"):
			_put_history_input(-1)
		elif event.is_action_pressed("ui_down"):
			_put_history_input(1)

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

func _send_input() -> void:
	var gd_lisp_result = _gd_lisp.parse_string(input.text)
	var gd_lisp_text: String = ""
	if gd_lisp_result:
		gd_lisp_text = str(gd_lisp_result)
	else:
		gd_lisp_text = "~done"
	
	var output_container: MarginContainer = OUTPUT_CONTAINER.instance()
	output.call_deferred("add_child", output_container)
	
	yield(output_container, "ready")
	
	output_container.upper_label.text = input.text
	output_container.lower_label.text = gd_lisp_text
	
	while output.get_child_count() > 50:
		output.get_child(0).free()
	
	yield(get_tree(), "idle_frame")
	
	scroll_container.scroll_vertical = int(scroll_container.get_v_scrollbar().max_value)
	
	# Clear input
	input.text = ""
	
	# Set history, child_count + 1 is the current input
	_current_history_position = output.get_child_count()
	_current_input_state = ""

func _put_history_input(direction: int) -> void:
	var child_count: int = output.get_child_count()
	var new_position: int = _current_history_position + direction
	if new_position == child_count:
		input.text = _current_input_state
		_current_history_position = new_position
	elif (new_position < child_count and new_position >= 0):
		if _current_history_position == child_count:
			_current_input_state = input.text
		
		_current_history_position = new_position
		
		input.text = output.get_child(_current_history_position).get_value().strip_edges()

###############################################################################
# Public functions                                                            #
###############################################################################


