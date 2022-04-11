extends "res://addons/gut/test.gd"

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

func assert_ok(input) -> bool:
	.assert_eq(input, OK)
	return typeof(input) == TYPE_INT and input == OK

func assert_true(input, _text = "") -> bool:
	.assert_true(input)
	return input == true

func assert_false(input, _text = "") -> bool:
	.assert_false(input)
	return input == false

func assert_eq(a, b, _text = "") -> bool:
	.assert_eq(a, b)
	return a == b

func assert_null(input, _text = "") -> bool:
	.assert_null(input)
	return input == null

func assert_not_null(input, _text = "") -> bool:
	.assert_not_null(input)
	return input != null

###############################################################################
# Tests                                                                       #
###############################################################################

const Gdlisp = preload("res://addons/gdlisp/gdlisp.gd")

#region Utils

const Result = Gdlisp.Result
const Error = Gdlisp.Error

#endregion

#region Model

const ScopeBuiltins = Gdlisp.ScopeBuiltins

const GdlArray = Gdlisp.GdlArray
const GdlDictionary = Gdlisp.GdlDictionary

const Stack = Gdlisp.Stack

const Scope = Gdlisp.Scope

const Exp = Gdlisp.Exp

#endregion

#region Compiler

const Tokenizer = Gdlisp.Tokenizer
const Parser = Gdlisp.Parser

#endregion

#region Interpreter

const Evaluator = Gdlisp.Evaluator

#endregion
