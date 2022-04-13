extends "res://tests/base_test.gd"

# https://github.com/bitwes/Gut/wiki/Quick-Start

###############################################################################
# Builtin functions                                                           #
###############################################################################

func before_all():
	pass

func before_each():
	p = Parser.new()

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

var p: Parser

func test_stack():
	var stack := Parser.ParserStack.new()

	if not assert_eq(stack.size(), 0):
		return

	stack.push(Exp.new(Exp.Type.LIST, []))

	if not assert_eq(stack.size(), 1):
		return

	stack.push(Exp.new(Exp.Type.SYM, "print"))

	if not assert_eq(stack.size(), 1):
		return
	if not assert_eq(stack.back().value()[0].value(), "print"):
		return

	var popped: Exp = stack.pop()

	if not assert_eq(stack.size(), 0):
		return
	if not assert_not_null(popped):
		return
	if not assert_false(stack.is_invalid):
		return
	if not assert_eq(typeof(popped.value()), TYPE_ARRAY):
		return
	assert_eq(popped.value()[0].value(), "print")

	assert_null(stack.pop())

	stack.push(Exp.new(Exp.Type.LIST, []))
	stack.push(Exp.new(Exp.Type.SYM, "print"))
	stack.push(Exp.new(Exp.Type.STR, "hello"))
	stack.push(Exp.new(Exp.Type.LIST, []))

	if not assert_eq(stack.size(), 2):
		return

	popped = stack.finish()

	assert_not_null(popped)
	if not assert_eq(stack.size(), 0):
		return
	assert_eq(stack.is_invalid, false)

func test_atom():
	var str_atom: Exp = p._atom("\"Hello world\"")

	assert_eq(str_atom.value(), "Hello world")

	var num_atom: Exp = p._atom("12")

	assert_eq(num_atom.value(), 12.0)

	var sym_atom: Exp = p._atom("hello world")

	assert_eq(sym_atom.value(), "hello world")

	var sym_atom_2: Exp = p._atom("12_asdf")

	assert_eq(sym_atom_2.value(), "12_asdf")

func test_simple_parse():
	"""
	Simple parse test with additional structural checks
	"""
	var input := [
		"(", "print", "\"hello world\"", ")"
	]
	
	var res: Result = p.run(input)

	if not assert_true(res.is_ok()):
		return

	var e: Exp = res.unwrap()
	
	if not assert_not_null(e):
		return
	
	var val = e.value()
	
	# The main containing Expression must be a list type
	if not assert_true(typeof(val) == TYPE_ARRAY):
		return
	if not assert_eq(val.size(), 1):
		return

	e = val[0]

	if not assert_true(e is Exp):
		return
	
	val = e.value()

	# Each sub Expression must also be a list type
	if not assert_true(typeof(val) == TYPE_ARRAY):
		return
	if not assert_eq(val.size(), 2):
		return
	
	assert_eq(val[0].value(), "print")
	assert_eq(val[1].value(), "hello world")

func test_simple_nested():
	var input := [
		"(","print",
			"(", "add", "1", "1", ")", ")"
	]

	var res: Result = p.run(input)

	if not assert_true(res.is_ok()):
		return

	var e: Exp = res.unwrap()

	if not assert_not_null(e):
		return

	var val = e.value()

	if not assert_eq(val.size(), 1):
		return

	e = val[0]

	val = e.value()

	if not assert_eq(val.size(), 2):
		return

	assert_eq(val[0].value(), "print")

	e = val[1]

	val = e.value()

	if not assert_eq(val.size(), 3):
		return

	assert_eq(val[0].value(), "add")
	assert_eq(val[1].value(), 1.0)
	assert_eq(val[1].value(), 1.0)

func test_simple_double_root_level():
	var input := [
		"(", "print", "\"hello world\"", ")",
		"(", "print", "\"world hello\"", ")"
	]

	var res = p.run(input)

	if not assert_true(res.is_ok()):
		return

	var root: Exp = res.unwrap()

	var root_val = root.value()

	if not assert_eq(root_val.size(), 2):
		return

	var e: Exp = root_val[0]

	var val = e.value()

	assert_eq(val[0].value(), "print")
	assert_eq(val[1].value(), "hello world")

	e = root_val[1]

	val = e.value()

	assert_eq(val[0].value(), "print")
	assert_eq(val[1].value(), "world hello")

func test_empty():
	var input := ["(", ")"]

	var res = p.run(input)

	if not assert_true(res.is_ok()):
		return

	var e: Exp = res.unwrap()

	var val: Array = e.value()

	assert_eq(val.size(), 1)

	e = val[0]

	val = e.value()

	assert_eq(val.size(), 0)
