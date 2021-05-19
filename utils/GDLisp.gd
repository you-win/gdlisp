class_name GDLisp
extends Reference

class Result:
	var _tuple: Tuple2

	func _init(v0, v1) -> void:
		_tuple = Tuple2.new(v0, v1)

	func unwrap():
		# Error
		if _tuple.g1():
			AppManager.log_message("Unwrapped an error", true)
			return null
		else:
			return _tuple.g0()

	func unwrap_err() -> String:
		return _tuple.g1()

	func is_ok() -> bool:
		return not _tuple.g1()

	func is_err() -> bool:
		return not is_ok()

	func set_value(value) -> void:
		_tuple.s0(value)

	func set_error(value) -> void:
		_tuple.s1(value)

class Error extends Exp:
	func _init(error_message: String, exp_type: int = Exp.Atom).(exp_type, error_message) -> void:
		self.type = exp_type
		self.value = error_message

class None extends Exp:
	func _init(exp_type: int = Exp.None, exp_value = null).(exp_type, exp_value) -> void:
		self.type = exp_type
		self.value = exp_value

class Tuple2:
	var _v0
	var _v1

	func _init(v0, v1) -> void:
		_v0 = v0
		_v1 = v1

	func g0():
		return _v0
	
	func g1():
		return _v1
	
	func s0(value):
		_v0 = value

	func s1(value):
		_v1 = value

class Tuple3 extends Tuple2:
	var _v2

	func _init(v0, v1, v2).(v0, v1) -> void:
		_v2 = v2

	func g2():
		return _v2

	func s2(value):
		_v2 = value

var environment: Dictionary = {
	# Operators
	"+": funcref(EnvUtils, "plus"),
	"-": funcref(EnvUtils, "minus"),
	"*": funcref(EnvUtils, "multiply"),
	"/": funcref(EnvUtils, "divide"),
	"==": funcref(EnvUtils, "equals"),
	"<": funcref(EnvUtils, "less_than"),
	"<=": funcref(EnvUtils, "less_than_or_equal_to"),
	">": funcref(EnvUtils, "greater_than"),
	">=": funcref(EnvUtils, "greater_than_or_equal_to"),
	
	# Primitives
	"true": true,
	"false": false,
	
	# Builtin functions
	"print": funcref(EnvUtils, "print")
}

class EnvUtils:
	static func plus(a: Array):
		if a.size() < 2:
			return 0

		var result = a[0]
		for i in a.slice(1, a.size() - 1):
			result += i
		return result
	
	static func minus(a: Array):
		if a.size() < 2:
			return 0

		var result = a[0]
		for i in a.slice(1, a.size() - 1):
			result -= i
		return result
	
	static func multiply(a: Array):
		if a.size() < 2:
			return 0
		
		var result = a[0]
		for i in a.slice(1, a.size() - 1):
			result *= i
		return result
	
	static func divide(a: Array):
		if a.size() < 2:
			return 0
		
		var result = a[0]
		for i in a.slice(1, a.size() - 1):
			result /= i
		return result

	static func equals(a: Array):
		if a.size() != 2:
			return false
		return a[0] == a[1]
	
	static func less_than(a: Array):
		if a.size() != 2:
			return false
		return a[0] < a[1]
	
	static func less_than_or_equal_to(a: Array):
		if a.size() != 2:
			return false
		return a[0] <= a[1]
	
	static func greater_than(a: Array):
		if a.size() != 2:
			return false
		return a[0] > a[1]
	
	static func greater_than_or_equal_to(a: Array):
		if a.size() != 2:
			return false
		return a[0] >= a[1]
	
	static func print(a: Array):
		var result: String = ""
		if a.size() < 1:
			return result
		for i in a:
			result += str(i)
		print(result)
		return result

class Env:
	var _inner: Dictionary
	var _outer: Dictionary

	func _init(params: Array, call_args: Array, outer: Dictionary) -> void:
		_outer = outer

		# params and call_args must match up
		if params.size() != call_args.size():
			return
		
		for i in params.size():
			_inner[params[i]] = call_args[i]

	func find(value: String):
		if value in _inner:
			return _inner
		elif value in _outer:
			return _outer
		
		return null

class Atom:
	enum { Sym = 0, Num, Str }
	var type: int
	var value
	
	func _init(atom_type: int, atom_value) -> void:
		type = atom_type
		value = atom_value
	
	func _to_string() -> String:
		if type == Num:
			return str(value)
		return value
	
	func get_value():
		return value

class Exp:
	enum { None = 0, Atom, List }
	var type: int
	var value
	
	func _init(exp_type: int, exp_value) -> void:
		type = exp_type
		value = exp_value
	
	func _to_string() -> String:
		if type == Atom:
			return value.to_string()
		return str(value)
	
	func append(v) -> void:
		match type:
			List:
				if typeof(v) == TYPE_ARRAY:
					(value as Array).append_array(v)
				else:
					(value as Array).append(v)
			Atom:
				AppManager.log_message("Tried to append to an Atom")
	
	func get_value():
		match type:
			List:
				return (value as Array)
			Atom:
				return value
	
	func get_raw_value():
		match type:
			List:
				return (value as Array)
			Atom:
				return value.get_value()

class Tokenizer:
	enum { None = 0, ParseExpression, ParseSpace, ParseSymbol, ParseQuotation }

	var current_type: int = None

	var token_builder: PoolStringArray = PoolStringArray()

	func _build_token(result: Array) -> void:
		if token_builder.size() != 0:
			result.append(token_builder.join(""))
			token_builder = PoolStringArray()

	func tokenize(value: String) -> Result:
		var result: Array = []
		var error

		var paren_counter: int = 0
		
		# Checks for raw strings of size 1
		if value.length() <= 2:
			return Result.new(result, "Program too short")

		for i in value.length():
			var c: String = value[i]
			match c:
				"(":
					paren_counter += 1
					_build_token(result)
					current_type = ParseExpression
					result.append(c)
				")":
					paren_counter -= 1
					_build_token(result)
					current_type = ParseExpression
					result.append(c)
				" ", "\r\n", "\n", "\t":
					if current_type == ParseQuotation:
						token_builder.append(c)
					else:
						_build_token(result)
						current_type = ParseSpace
				'"':
					if current_type == ParseSpace:
						token_builder.append(c)
						current_type = ParseQuotation
					elif current_type == ParseQuotation:
						token_builder.append(c)
						current_type = None
						_build_token(result)
				_:
					if current_type == ParseQuotation:
						token_builder.append(c)
					else:
						current_type = ParseSymbol
						token_builder.append(c)
		
		if paren_counter != 0:
			result.clear()
			error = "Mismatched parens"

		return Result.new(result, error)

class Parser:
	var _depth: int = 0
	var _result: Result

	func _init(result: Result) -> void:
		_result = result
	
	func parse(tokens: Array) -> Exp:
		var list_expression: Exp = Exp.new(Exp.List, [])

		if _result.is_err():
			return _error("Aborting due to previous error")

		if tokens.size() == 0:
			return _error("Unexpected EOF")
		
		var token: String = tokens.pop_back()
		
		if tokens.size() == 0:
			return _error("Unexpected EOF")
		
		match token:
			"(":
				_depth += 1
				while tokens[tokens.size() - 1] != ")":
					list_expression.append(parse(tokens))
				tokens.pop_back() # Remove last ')'
			")":
				return _error("Unexpected token")
			_:
				return Exp.new(Exp.Atom, _atom(token))

		_depth -= 1
		if _depth == 0:
			_result.set_value(list_expression)

		return list_expression
	
	func _atom(token: String) -> Atom:
		if token.begins_with('"'):
			return Atom.new(Atom.Str, token.substr(1, token.length() - 2))
		elif token.is_valid_float():
			return Atom.new(Atom.Num, token.to_float())
		else:
			return Atom.new(Atom.Sym, token)

	func _error(error_message: String) -> Exp:
		_result = Result.new(null, Error.new(error_message))
		return None.new()

class Evaluator:
	var _depth: int = 0
	var _result: Result

	func _init(result: Result) -> void:
		_result = result

	func _eval(v: Exp, env: Dictionary):
		_depth -= 1
		return eval(v, env)

	func eval(v: Exp, env: Dictionary):
		_depth += 1
		if v.type == Exp.Atom:
			match v.get_value().type:
				Atom.Sym:
					var raw_value = v.get_raw_value()
					
					if not env.has(raw_value):
						AppManager.log_message("Undefined symbol %s" % raw_value)
						return "Undefined symbol"
					
					return env[v.get_raw_value()]
				Atom.Str:
					return v.get_raw_value()
				Atom.Num:
					return v.get_raw_value()
		elif v.type == Exp.List:
			var list: Array = v.get_value()
			if list.size() == 0:
				return "Empty S-expression"
			match list[0].get_raw_value():
				"if": # (if () () ())
					var test = list[1]
					var consequence = list[2]
					var alt = list[3]
					var expression
					if (eval(test, env)):
						expression = consequence
					else:
						expression = alt
					return eval(expression, env)
				"for": # (for [] ())
					pass
				"def": # Create new variable (def () ())
					var symbol = list[1]
					var expression = list[2]
					env[symbol.get_raw_value()] = eval(expression, env)
				"lam": # Lambda (lam [] ())
					pass
				"label": # Label all nested S-expressions (label ())
					pass
				"goto": # Goto specified label (goto ())
					pass
				_:
					var procedure = eval(list[0], env)
					var args: Array = []
					for arg in list.slice(1, list.size() - 1, 1, true):
						args.append(eval(arg, env))
					if procedure is String:
						return
					return procedure.call_func(args)

class Procedure:
	pass

###############################################################################
# Builtin functions                                                           #
###############################################################################

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

func _tokenize(value: String) -> Result:
	var tokenizer: Tokenizer = Tokenizer.new()

	return tokenizer.tokenize(value)

func _parse(tokens: Array, result: Result) -> Exp:
	var parser: Parser = Parser.new(result)

	return parser.parse(tokens)

func _eval(v: Exp, result: Result, env: Dictionary = environment):
	var evaluator: Evaluator = Evaluator.new(result)

	return evaluator.eval(v, env)

###############################################################################
# Public functions                                                            #
###############################################################################

func parse_string(value: String):
	var result
	# String
	var tokenize_result: Result = _tokenize(value)
	if tokenize_result.is_err():
		return tokenize_result.unwrap_err()
	var tokens: Array = tokenize_result.unwrap()
	
	tokens.invert()

	var parsed_tokens_array: Array = []
	while tokens.size() != 0:
		var parser_result: Result = Result.new(null, null)
		_parse(tokens, parser_result)

		if parser_result.is_err():
			return parser_result.unwrap_err()
		
		parsed_tokens_array.append(parser_result.unwrap())

	for i in parsed_tokens_array:
		var eval_result: Result = Result.new(null, null)
		result = _eval(i, eval_result)
	
	return result
