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
	var evaluator := GDLisp.Evaluator.new(result)

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

func test_while_loop() -> void:
	var output = GDLisp.new().parse_string('(def x 0)(while (< x 5)(print x)(= x (+ x 1)))(x)')

	assert(output[2] == 5)

	print(output)

func test_do() -> void:
	var output = GDLisp.new().parse_string('(def x 100)(do (def x 0) (= x (+ x 1)) (print x) (def x -10) (print x))(x)')
	
	assert(output[2] == 100)
	
	print(output)
