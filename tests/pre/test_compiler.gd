extends "res://tests/base_test.gd"

# https://github.com/bitwes/Gut/wiki/Quick-Start

###############################################################################
# Builtin functions                                                           #
###############################################################################

func before_all():
	pass

func before_each():
	tokenizer = Tokenizer.new()
	parser = Parser.new()

func after_each():
	pass

func after_all():
	pass

###############################################################################
# Utils                                                                       #
###############################################################################

###############################################################################
# Tests                                                                       #
###############################################################################

var tokenizer: Tokenizer
var parser: Parser

func test_hello_world():
	var input := """
(print "hello world")
	"""
	
	var res: Result = tokenizer.run(input)

	if not assert_true(res.is_ok()):
		return

	res = parser.run(res.unwrap())

	if not assert_true(res.is_ok()):
		return

	var e: Exp = res.unwrap()

	if not assert_not_null(e):
		return

	var val = e.value()

	if not assert_eq(typeof(val), TYPE_ARRAY):
		return

	e = val[0]
	val = e.value()

	if not assert_eq(val.size(), 2):
		return

	assert_eq(val[0].value(), "print")
	assert_eq(val[1].value(), "hello world")
