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
	pass

###############################################################################
# Utils                                                                       #
###############################################################################

###############################################################################
# Tests                                                                       #
###############################################################################

func test_to_string():
	var e := Exp.new(Exp.Type.SYM, "print")

	assert_eq(e.to_string(), "{\"type\":\"SYM\",\"value\":\"print\"}")

func test_smoke():
	var e := Exp.new(Exp.Type.SYM, "print")

	assert_eq(e.value(), "print")

	# Nothing should happen except for stderr output
	e.append("hello")

	e = Exp.new(Exp.Type.LIST, [])

	if not assert_eq(typeof(e.value()), TYPE_ARRAY):
		return

	e.append(Exp.new(Exp.Type.STR, "hello world"))

	assert_eq(e.value().size(), 1)

	var inner = e.value()[0]

	assert_eq(inner.value(), "hello world")
