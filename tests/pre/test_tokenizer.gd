extends "res://tests/base_test.gd"

# https://github.com/bitwes/Gut/wiki/Quick-Start

###############################################################################
# Builtin functions                                                           #
###############################################################################

func before_all():
	pass

func before_each():
	t = Tokenizer.new()

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

var t: Tokenizer

func test_simple_variable_assign():
	var res := t.run("""
(def x 1)
	""")

	if not assert_true(res.is_ok()):
		return

	var tokens: Array = res.unwrap()

	if not assert_eq(tokens.size(), 5):
		return
	
	var expected := ["(", "def", "x", "1", ")"]
	
	for idx in tokens.size():
		assert_eq(tokens[idx], expected[idx])

func test_simple_list_assign():
	# Extra spaces are ok
	var res := t.run("""
(def x [1 2 3  
	4 ])
	""")

	if not assert_true(res.is_ok()):
		return

	var tokens: Array = res.unwrap()

	if not assert_eq(tokens.size(), 10):
		print(tokens)
		return

	var expected := ["(", "def", "x", "[", "1", "2", "3", "4", "]", ")"]

	for idx in tokens.size():
		assert_eq(tokens[idx], expected[idx])

func test_simple_comment():
	var res := t.run("""
;; Takes a value and doubles it
(def double (
	lam [x] (
		;; Assign the result to y
		(def y (+ x x))
		;; Returns y
		(y))))
	""")

	if not assert_true(res.is_ok()):
		return

	var tokens: Array = res.unwrap()

	if not assert_eq(tokens.size(), 24):
		return

	var expected := [
"(", "def", "double", "(",
	"lam", "[", "x", "]", "(",
		"(", "def", "y", "(", "+", "x", "x", ")", ")",
		"(", "y", ")", ")", ")", ")"
	]

	for idx in tokens.size():
		assert_eq(tokens[idx], expected[idx])
