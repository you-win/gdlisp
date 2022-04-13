extends "res://tests/base_test.gd"

# https://github.com/bitwes/Gut/wiki/Quick-Start

###############################################################################
# Builtin functions                                                           #
###############################################################################

func before_all():
	pass

func before_each():
	d = GdlDictionary.new()

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

var d: GdlDictionary

func test_to_string():
	d._inner = {
		"hello": "world"
	}

	assert_eq(d.to_string(), "{hello:world}")

func test_smoke():
	d.set("hello", "world")

	if not assert_eq(d.size(), 1):
		return
	assert_eq(d.get("hello"), "world")

	d.set("hello", 1)
	d.set(2, 4)

	if not assert_eq(d.size(), 2):
		return
	assert_eq(d.get("hello"), 1)
	assert_eq(d.get(2), 4)

	var e = d.duplicate()

	if not assert_not_null(e):
		return
	if not assert_eq(e.size(), 2):
		return

	e.set("other", "string")

	assert_eq(e.size(), 3)
	assert_eq(d.size(), 2)

	var dict = e.inner()

	if not assert_not_null(dict):
		return
	if not assert_eq(dict.size(), 3):
		return

	assert_eq(dict["other"], "string")
