extends "res://tests/base_test.gd"

# https://github.com/bitwes/Gut/wiki/Quick-Start

###############################################################################
# Builtin functions                                                           #
###############################################################################

func before_all():
	pass

func before_each():
	var gdlisp := Gdlisp.new()
	var scope := Scope.new()
	scope._inner = gdlisp.global_scope_builtins
	evaluator = Evaluator.new(scope)

func after_each():
	evaluator._scope._inner.clear()

func after_all():
	pass

###############################################################################
# Utils                                                                       #
###############################################################################

###############################################################################
# Tests                                                                       #
###############################################################################

var evaluator: Evaluator

func test_hello_world():
	# (print "hello world")
	var e := Exp.new(Exp.Type.LIST, [
		Exp.new(Exp.Type.SYM, "print"),
		Exp.new(Exp.Type.STR, "hello world")
	])

	var res = evaluator.run(Exp.new(Exp.Type.LIST, [e]))
	
	assert_null(res)

func test_add_1_2():
	var e := Exp.new(Exp.Type.LIST, [
		Exp.new(Exp.Type.SYM, "+"),
		Exp.new(Exp.Type.NUM, 1.0),
		Exp.new(Exp.Type.NUM, 2.0)
	])
	
	var res = evaluator.run(Exp.new(Exp.Type.LIST, [e]))
	
	assert_eq(res, 3.0)

func test_add_1_2_3_4():
	var e := Exp.new(Exp.Type.LIST, [
		Exp.new(Exp.Type.SYM, "+"),
		Exp.new(Exp.Type.NUM, 1.0),
		Exp.new(Exp.Type.NUM, 2.0),
		Exp.new(Exp.Type.NUM, 3.0),
		Exp.new(Exp.Type.NUM, 4.0)
	])

	var res = evaluator.run(Exp.new(Exp.Type.LIST, [e]))
	
	assert_eq(res, 10.0)

func test_minus_10_100():
	var e := Exp.new(Exp.Type.LIST, [
		Exp.new(Exp.Type.SYM, "-"),
		Exp.new(Exp.Type.NUM, 10.0),
		Exp.new(Exp.Type.NUM, 100.0)
	])

	var res = evaluator.run(Exp.new(Exp.Type.LIST, [e]))
	
	assert_eq(res, -90.0)

func test_minus_10_10_10():
	var e := Exp.new(Exp.Type.LIST, [
		Exp.new(Exp.Type.SYM, "-"),
		Exp.new(Exp.Type.NUM, 10.0),
		Exp.new(Exp.Type.NUM, 10.0),
		Exp.new(Exp.Type.NUM, 10.0)
	])

	var res = evaluator.run(Exp.new(Exp.Type.LIST, [e]))
	
	assert_eq(res, -10.0)
