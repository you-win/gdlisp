extends "res://tests/base_test.gd"

# https://github.com/bitwes/Gut/wiki/Quick-Start

###############################################################################
# Builtin functions                                                           #
###############################################################################

func before_all():
	pass

func before_each():
	a = GdlArray.new()

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

var a: GdlArray

func test_to_string():
	a._inner = [1, 2, 3]
	assert_eq(a.to_string(), "[1, 2, 3]")

func test_smoke():
	a.push(1)

	if not assert_eq(a.size(), 1):
		return
	if not assert_eq(a.pop(), 1):
		return

	assert_eq(a.size(), 0)

	a.append(2)
	a.append(5)

	if not assert_eq(a.size(), 2):
		return
	if not assert_eq(a.pop(), 5):
		return

	a.set(0, 100)

	assert_eq(a.get(0), 100)

	var b = a.duplicate()

	if not assert_not_null(b):
		return
	if not assert_eq(b.size(), 1):
		return
	
	assert_eq(b.get(0), 100)

	b.push(10)

	assert_eq(b.size(), 2)
	assert_eq(a.size(), 1)

	var array = b.inner()

	if not assert_not_null(array):
		return
	if not assert_eq(typeof(array), TYPE_ARRAY):
		return
	if not assert_eq(array[0], 100):
		return
