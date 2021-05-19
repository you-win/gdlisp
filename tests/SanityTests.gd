extends TestBase

func run_tests() -> void:
	var test_methods: Array = []
	var methods: Array = get_method_list()
	
	for method in methods:
		var method_name: String = method["name"]
		if method_name.left(4).to_lower() == "test":
			test_methods.append(method_name)
	
	print("Running %s tests" % test_methods.size())
	for method in test_methods:
		print("\n%s" % method)
		call(method)

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
	
	var result := _create_empty_result()
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
	input.append(_create_expression_from_atom(_create_atom("print")))
	input.append(_create_expression_from_atom(_create_atom('"hello world"')))
	
	var result := _create_empty_result()
	var evaluator := GDLisp.Evaluator.new(result)

	var eval_result = evaluator.eval(input, gdlisp.environment)

	assert(result.is_ok())
	
	assert(eval_result == "hello world")
	
	print(eval_result)

###############################################################################
# GDLisp                                                                      #
###############################################################################

func test_hello_world() -> void:
	var output = GDLisp.new().parse_string('(print "hello world")')
	
	print(output)

func test_simple_addition() -> void:
	var output = GDLisp.new().parse_string('(+ 1 1)')
	
	print(output)
