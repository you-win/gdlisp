extends Control

const MAX_OUTPUT_COUNT: int = 50

const OUTPUT_CONTAINER: Resource = preload("res://entities/OutputContainer.tscn")

const HELP_TEXT: String = """*** GDLisp ***
There are several REPL-only commands for convenience.
	help
		Show this message
	syntax
		Show a list of reserved symbols in GDLisp and usage
	clear
		Clears the current repl output (DOES NOT RESET THE REPL STATE)
	reset
		Resets the current REPL state
	blurb
		Get a random blurb
	exit
		Exits the repl"""

const CUSTOM_REPL_COMMANDS := ["help", "syntax", "clear", "reset", "blurb", "exit", "ls", "cd"]

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
		_create_output_box("Running sanity tests", "uwu")
		
		var sanity_test: TestBase = load("res://tests/SanityTests.gd").new()
		sanity_test.run_tests()
		
		_create_output_box("Finished running sanity tests", "owo")
	
	input.grab_focus()
	
	_create_output_box(HELP_TEXT, _generate_random_blurb())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("super"):
		_is_super_pressed = true
	elif event.is_action_released("super"):
		_is_super_pressed = false
	elif _is_super_pressed:
		if event.is_action_pressed("send_input"):
			if input.text in CUSTOM_REPL_COMMANDS:
				_handle_custom_repl_commands()
			else:
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
	
	_create_output_box(input.text, gd_lisp_text)
	
	_update_input_box()

func _create_output_box(upper: String, lower: String) -> void:
	var output_container: MarginContainer = OUTPUT_CONTAINER.instance()
	output_container.upper_text = _fix_text(upper)
	output_container.lower_text = _fix_text(lower)
	output.call_deferred("add_child", output_container)

func _fix_text(text: String) -> String:
	return text.replace("\t", "    ")

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

func _handle_custom_repl_commands() -> void:
	var output_text: String
	match input.text:
		"help":
			output_text = HELP_TEXT
		"syntax":
			output_text = GDLispSyntaxDoc.get_long()
		"clear":
			output_text = _generate_random_blurb()
			for c in output.get_children():
				c.free()
			yield(get_tree(), "idle_frame")
		"reset":
			output_text = "Creating a new GDLisp environment!?"
			_gd_lisp = GDLisp.new()
		"blurb":
			output_text = _generate_random_blurb()
		"exit":
			get_tree().quit()
		"ls", "cd":
			output_text = "wrong terminal bud\n\n%s" % _generate_random_blurb()
		_:
			AppManager.log_message("This shouldn't be possible lmao: %s" % input.text, true)
	
	if input.text != "clear":
		_create_output_box(input.text, output_text)
	
	_update_input_box()

func _update_input_box() -> void:
	yield(get_tree(), "idle_frame")
	
	while output.get_child_count() > 50:
		output.get_child(0).free()
	
	yield(get_tree(), "idle_frame")
	
	scroll_container.scroll_vertical = int(scroll_container.get_v_scrollbar().max_value)
	
	# Clear input
	input.text = ""
	
	# Set history, child_count + 1 is the current input
	_current_history_position = output.get_child_count()
	_current_input_state = ""

func _generate_random_blurb() -> String:
	"""
	Not setting this list as a const at the top since it's not really relevant
	10/10 software dev
	"""
	var blurbs := [
		# small
		"glhf", "send help", "uwu", "owo", "nl is egg", "ur mum", "tuturu~",
		"exusai gang", "ggez", "gottem",
		
		# long
		"but my performance q.q", "try using a goto ;)", "what is this garbage",
		"to boldly go where humans have collectively agreed not to go",
		"I've been using the same reusable water bottle for 15 years *flexes*",
		
		# promo
		"remember to lik an subscrb", "github.com/you-win/openseeface-gd",
		"hi youtube", "hi twitch", "sometimes youwin"
	]
	return blurbs[randi() % blurbs.size()]

###############################################################################
# Public functions                                                            #
###############################################################################


