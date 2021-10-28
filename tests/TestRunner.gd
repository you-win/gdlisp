extends Control

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	find_node("Sanity").pressed.connect(_sanity_test)
	find_node("Tokenizer").pressed.connect(_tokenizer_test)
	find_node("Parser").pressed.connect(_parser_test)
	find_node("Evaluator").pressed.connect(_evaluator_test)
	find_node("EndToEnd").pressed.connect(_end_to_end_test)
	
	find_node("RunAll").pressed.connect(_run_all_tests)

###############################################################################
# Connections                                                                 #
###############################################################################

func _sanity_test() -> void:
	var sanity_test: TestBase = load("res://tests/SanityTests.gd").new()
	
	sanity_test.run_tests()

func _tokenizer_test() -> void:
	pass

func _parser_test() -> void:
	pass

func _evaluator_test() -> void:
	pass

func _end_to_end_test() -> void:
	pass

func _run_all_tests() -> void:
	_sanity_test()
	_tokenizer_test()
	_parser_test()
	_evaluator_test()
	_end_to_end_test()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################


