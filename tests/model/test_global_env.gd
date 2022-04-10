extends "res://tests/base_test.gd"

# https://github.com/bitwes/Gut/wiki/Quick-Start

###############################################################################
# Builtin functions                                                           #
###############################################################################

func before_all():
	pass

func before_each():
	pass

func after_each():
	pass

func after_all():
	ge.clear()

###############################################################################
# Utils                                                                       #
###############################################################################

###############################################################################
# Tests                                                                       #
###############################################################################

var ge = Gdlisp.new().global_env

func test_plus():
	if not assert_true(ge.has("+")):
		return
	assert_eq(ge["+"].call_funcv([1, 2]), 3)

func test_minus():
	if not assert_true(ge.has("-")):
		return
	assert_eq(ge["-"].call_funcv([1, 2]), -1)

func test_multiply():
	if not assert_true(ge.has("*")):
		return
	assert_eq(ge["*"].call_funcv([2, 3]), 6)

func test_divide():
	if not assert_true(ge.has("/")):
		return
	assert_eq(ge["/"].call_funcv([6, 3]), 2)

func test_equals():
	if not assert_true(ge.has("==")):
		return
	assert_true(ge["=="].call_funcv([1, 1]))

func test_not_equals():
	if not assert_true(ge.has("!=")):
		return
	assert_true(ge["!="].call_funcv([1, 2]))

func test_less_than():
	if not assert_true(ge.has("<")):
		return
	assert_true(ge["<"].call_funcv([1, 2]))

func test_less_than_equal_to():
	if not assert_true(ge.has("<=")):
		return
	assert_true(ge["<="].call_funcv([2, 2]))

func test_greater_than():
	if not assert_true(ge.has(">")):
		return
	assert_true(ge[">"].call_funcv([2, 1]))

func test_greater_than_equal_to():
	if not assert_true(ge.has(">=")):
		return
	assert_true(ge[">="].call_funcv([2, 2]))

func test_true():
	if not assert_true(ge.has("true")):
		return
	assert_true(ge["true"])

func test_false():
	if not assert_true(ge.has("false")):
		return
	assert_false(ge["false"])

func test_print():
	# Nothing to really test here except for checking if it exists
	assert_true(ge.has("print"))

func test_self():
	if not assert_true(ge.has("self")):
		return
	assert_not_null(ge["self"].global_env)
