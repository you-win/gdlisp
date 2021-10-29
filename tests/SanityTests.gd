extends TestBase

###############################################################################
# Tokenizer                                                                   #
###############################################################################

func test_simple_tokenizer() -> void:
	var tokenizer: GDLisp.Tokenizer = GDLisp.Tokenizer.new()
	
	var result: GDLisp.Result = tokenizer.tokenize('(print "hello world")')
	
	assert(result.is_ok())
	
	var unwrapped_results: Array = result.unwrap()
	
	assert(unwrapped_results == ['(', 'print', '"hello world"', ')'])
	
	print(unwrapped_results)

###############################################################################
# Parser                                                                      #
###############################################################################

func test_simple_parser() -> void:
	var input: Array = ['(', 'print', '"hello world"', ')']
	input.invert()
	
	var result = _create_empty_result()
	var parser := GDLisp.Parser.new(result)
	
	var expression := parser.parse(input)
	
	assert(expression.type == GDLisp.Exp.List)
	
	assert(result.is_ok())
	
	var unwrapped_results = result.unwrap()
	
	assert(unwrapped_results.to_string() == "[print, hello world]")
	
	print(unwrapped_results)

###############################################################################
# Evaluator                                                                   #
###############################################################################

func test_simple_evaluator() -> void:
	var gdlisp := GDLisp.new()

	var input := GDLisp.Exp.new(GDLisp.Exp.List, [])
	input.append(_create_expression_from_atom(_create_atom("+")))
	input.append(_create_expression_from_atom(_create_atom('1')))
	input.append(_create_expression_from_atom(_create_atom('1')))
	
	var result = _create_empty_result()
	var evaluator := GDLisp.Evaluator.new(result, gdlisp.global_env)

	var eval_result = evaluator.eval(input, gdlisp.global_env)

	assert(result.is_ok())
	
	var unwrapped_results = result.unwrap()
	
	assert(unwrapped_results == 2)
	
	print(unwrapped_results)

###############################################################################
# GDLisp                                                                      #
###############################################################################

func test_hello_world() -> void:
	var output = GDLisp.new().parse_string('(print "hello world")')
	
	print(output)

func test_simple_addition() -> void:
	var output = GDLisp.new().parse_string('(+ 1 1)')

	assert(output[0] == 2)
	
	print(output)

func test_nested_simple_addition() -> void:
	var output = GDLisp.new().parse_string('(+ 1 (+ 1 (+ 1 1)))')

	assert(output[0] == 4)

	print(output)

func test_setting_variables() -> void:
	var output = GDLisp.new().parse_string('(def x 1) (+ 1 x)')

	assert(output[1] == 2)

	print(output)

func test_simple_return() -> void:
	var output = GDLisp.new().parse_string('(def x 1)(x)')
	
	assert(output[1] == 1)
	
	print(output)

func test_while_loop() -> void:
	var output = GDLisp.new().parse_string('(def x 0)(while (< x 5)(print x)(= x (+ x 1)))(x)')

	assert(output[2] == 5)

	print(output)

func test_do() -> void:
	var output = GDLisp.new().parse_string('(def x 100)(do (def x 0) (= x (+ x 1)) (print x) (def x -10) (print x))(x)')
	
	assert(output[2] == 100)
	
	print(output)

func test_list() -> void:
	var output = GDLisp.new().parse_string('(def x [1 2 3 4])(x)')
	
	assert(output[1].get_raw_value()[2] == 3)
	
	print(output)

func test_table() -> void:
	var output = GDLisp.new().parse_string('(def x { "1" 2 "3" 4 })(x)')
	
	assert(output[1].get_raw_value()["3"] == 4)
	
	print(output)

func test_lambda_simple() -> void:
	var output = GDLisp.new().parse_string("""
(def x
	(lam [x y]
		(def z (+ x y))
		(print z)
		(z)))
(x 1 1)
	""")

	assert(output[1] == 2)

	print(output)

func test_lambda_redefine_builtin() -> void:
	var input: String = """
(def +
	(lam [x y]
		(- x (- 0 y))))

(def sign
	(lam [x]
		(if (> x 0)
			(1)
			(-1))))

(def *
	(lam [x y]
		(def return-value 0)
		(def counter y)
		(def incrementer (sign y))
		(= incrementer (- 0 incrementer))
		(while (!= counter 0)
			(= return-value (+ return-value x))
			(= counter (+ counter incrementer)))
		(return-value)))

(* 10 2)
	"""

	var output = GDLisp.new().parse_string(input)

	assert(output[3] == 20)

	print(output)

func test_macro_simple() -> void:
	var output = GDLisp.new().parse_string("""
(def infix (macro [code]
	(raw code get 1)
	(raw code get 0)
	(raw code get 2)))

(infix (1 + 1))
""")
	
	assert(output[1] == 2)

	print(output)

func test_goto() -> void:
	print("not yet implemented")
	pass
