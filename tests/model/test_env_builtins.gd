extends "res://tests/base_test.gd"

# https://github.com/bitwes/Gut/wiki/Quick-Start

###############################################################################
# Builtin functions                                                           #
###############################################################################

func before_all():
	pass

func before_each():
	eb = ScopeBuiltins.new()

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

var eb: ScopeBuiltins

func test_plus():
	assert_eq(eb.plus(1, 2), 3)
	assert_eq(eb.plus(-1, 10), 9)
	assert_eq(eb.plus(0, 0), 0)

func test_minus():
	assert_eq(eb.minus(1, 2), -1)
	assert_eq(eb.minus(-1, -10), 9)
	assert_eq(eb.minus(0, 0), 0)

func test_multiply():
	assert_eq(eb.multiply(2, 3), 6)
	assert_eq(eb.multiply(-3, 4), -12)
	assert_eq(eb.multiply(0, 10), 0)

func test_divide():
	assert_eq(eb.divide(2, 4), 2 / 4)
	assert_eq(eb.divide(10, 2), 5)
	assert_eq(eb.divide(0, 10), 0)

func test_equals():
	assert_true(eb.equals(1, 1))
	assert_false(eb.equals(1, 2))

func test_not_equals():
	assert_true(eb.not_equals(1, 2))
	assert_false(eb.not_equals(1, 1))

func test_less_than():
	assert_true(eb.less_than(1, 2))
	assert_false(eb.less_than(2, 1))

func test_less_than_equal_to():
	assert_true(eb.less_than_equal_to(1, 2))
	assert_true(eb.less_than_equal_to(1, 1))
	assert_false(eb.less_than_equal_to(2, 1))

func test_greater_than():
	assert_true(eb.greater_than(2, 1))
	assert_false(eb.greater_than(1, 2))

func test_greater_than_equal_to():
	assert_true(eb.greater_than_equal_to(2, 1))
	assert_true(eb.greater_than_equal_to(2, 2))
	assert_false(eb.greater_than_equal_to(1, 2))
