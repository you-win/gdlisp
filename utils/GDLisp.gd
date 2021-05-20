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

class Env:
	var _inner: Dictionary # This scope
	var _outer: Env # Outer scope

	func _init(outer: Env = null, param_names: Array = [], param_values: Array = []) -> void:
		_inner = {}
		if outer: # If null, then there is probably no global scope
			_outer = outer

		# params and call_args must match up
		if param_names.size() != param_values.size():
			return
		
		for i in param_names.size():
			_inner[param_names[i]] = param_values[i]

	func find(key: String):
		if key in _inner:
			return _inner[key]
		elif _outer:
			return _outer.find(key)

		return null

		# return Error.new("Attempted to reference non-existent value")

	func add(key: String, value) -> void:
		_inner[key] = value

	func remove(key: String) -> bool:
		return _inner.erase(key)

	func set_existing_value(key: String, value) -> bool:
		if key in _inner:
			_inner[key] = value
			return true
		elif _outer:
			return _outer.set_existing_value(key, value)
		return false

var global_environment_dictionary: Dictionary = {
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

var global_env: Env = Env.new()

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
	enum { None = 0, ParseExpression, ParseSpace, ParseSymbol, ParseQuotation, ParseBracket }

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
		var bracket_counter: int = 0
		
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
					current_type = None
					result.append(c)
				"[":
					bracket_counter += 1
					_build_token(result)
					current_type = ParseBracket
					result.append(c)
				"]":
					bracket_counter -= 1
					_build_token(result)
					current_type = None
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

		if bracket_counter != 0:
			result.clear()
			error = "Mismatched brackets"

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
				return _error("Unexpected )")
			"[":
				_depth += 1
				list_expression.append(Exp.new(Exp.Atom, _atom("list")))
				while tokens[tokens.size() - 1] != "]":
					list_expression.append(parse(tokens))
				tokens.pop_back() # Remove last ']'
			"]":
				return _error("Unexpected ]")
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

	func _init(result: Result, env: Env) -> void:
		_result = result
		env.add("evaluator", self)

	func eval(v: Exp, env: Env):
		var eval_value
		_depth += 1
		
		if v.type == Exp.Atom:
			match v.get_value().type:
				Atom.Sym:
					var raw_value = v.get_raw_value()
					var env_value = env.find(raw_value)
					
					if env_value == null:
						AppManager.log_message("Undefined symbol %s" % raw_value)
						eval_value = "Undefined symbol"
						_result.set_error(eval_value)
						continue
					
					eval_value = env_value
				Atom.Str:
					eval_value = v.get_raw_value()
				Atom.Num:
					eval_value = v.get_raw_value()
		elif v.type == Exp.List:
			var list: Array = v.get_value()
			if list.size() != 0:
				match list[0].get_raw_value():
					"if": # (if () () ())
						# TODO maybe change this to be varargs?
						if not _has_exact_args(list.size(), 4, "if"):
							return
						var test = list[1]
						var consequence = list[2]
						var alt = list[3]
						var expression
						if (eval(test, env)):
							expression = consequence
						else:
							expression = alt
						eval_value = eval(expression, Env.new(env))
					"do": # (do () ...)
						if not _has_enough_args(list.size(), 2, "do"):
							return
						var inner_env = Env.new(env)
						for s in list.slice(1, list.size()):
							eval(s, inner_env)
					"while": # (while (test) ())
						if not _has_enough_args(list.size(), 3, "while"):
							return
						var test = list[1]
						while eval(test, env):
							for s in list.slice(2, list.size()):
								eval(s, Env.new(env))
					"for": # (for [] ())
						pass
					"def": # Create new variable in the current scope (def () ())
						if not _has_exact_args(list.size(), 3, "def"):
							return
						var symbol = list[1]
						var expression = list[2]
						env.add(symbol.get_raw_value(), eval(expression, Env.new(env)))
					"=": # Sets a variable in the current or outer scope (= () ())
						if not _has_exact_args(list.size(), 3, "="):
							return
						var symbol = list[1]
						var expression = list[2]
						if not env.set_existing_value(symbol.get_raw_value(), eval(expression, Env.new(env))):
							eval_value = "Tried to set a non-existent variable %s" % symbol
							_result.set_error(eval_value)
							return
					"list": # Returns a Godot array (list () ...)
						eval_value = []
						if list.size() >= 2:
							for item in list.slice(1, list.size() - 1, true):
								eval_value.append(eval(item, Env.new(env)))
					"lam": # Lambda (lam [] ())
						if not _has_enough_args(list.size(), 3, "lam"):
							return
						var arg_names = list[1].get_raw_value()
						if not arg_names is Array:
							eval_value = "lam expects a list of parameter names"
							_result.set_error(eval_value)
						if arg_names.size() == 1: # Can never be 0, so fail if it somehow is
							arg_names = []
						else:
							arg_names = arg_names.slice(1, arg_names.size() - 1)
							for i in arg_names.size():
								arg_names[i] = arg_names[i].get_raw_value()

						var expressions = Exp.new(Exp.List, [])
						expressions.append(Exp.new(Exp.Atom, Atom.new(Atom.Sym, "do")))
						for expression in list.slice(2, list.size() - 1, true):
							expressions.append(expression)

						eval_value = Procedure.new(arg_names, expressions, Env.new(env), weakref(self))
					"label": # Label all nested S-expressions (label ())
						pass
					"goto": # Goto specified label (goto ())
						pass
					_:
						var procedure = eval(list[0], Env.new(env))
						if (not procedure is FuncRef and not procedure is Procedure):
							eval_value = procedure
							# NOTE this is the catch-all match, so this continue is okay
							continue
						var args: Array = []
						for arg in list.slice(1, list.size() - 1, 1, true):
							args.append(eval(arg, Env.new(env)))
						if procedure is String:
							eval_value = "Invalid procedure: %s" % procedure
							_result.set_error(eval_value)
							return
						eval_value = procedure.call_func(args)
		
		_depth -= 1
		
		if _depth == 0:
			_result.set_value(eval_value)
		
		return eval_value

	func _has_exact_args(list_size: int, expected_size: int, statement_type: String) -> bool:
		if list_size != expected_size:
			_result.set_error("Unexpected amount of arguments (%s vs %s) for %s" % [list_size, expected_size, statement_type])
			return false
		return true
	
	func _has_enough_args(list_size: int, minimum_size: int, statement_type: String) -> bool:
		if list_size < minimum_size:
			_result.set_error("Insufficient arguments for %s" % statement_type)
			return false
		return true

class Procedure:
	var stored_arg_names: Array
	var stored_expressions: Exp
	var stored_env: Env
	var evaluator: WeakRef

	func _init(arg_names: Array, expressions: Exp, env: Env, eval: WeakRef) -> void:
		stored_arg_names = arg_names
		stored_expressions = expressions
		stored_env = env
		evaluator = eval

	func call_func(arg_values: Array):
		for i in stored_arg_names.size():
			stored_env.add(stored_arg_names[i], arg_values[i])
		
		stored_env.find("evaluator").eval(stored_expressions, stored_env)

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _init() -> void:
	# NOTE we don't duplicate here since it doesn't really matter + it's a global
	global_env._inner = global_environment_dictionary

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

func _eval(v: Exp, result: Result, eval_env: Env = global_env):
	var evaluator: Evaluator = Evaluator.new(result, eval_env)

	return evaluator.eval(v, eval_env)

###############################################################################
# Public functions                                                            #
###############################################################################

func parse_string(value: String):
	var result: Array = []
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
		_eval(i, eval_result)

		if eval_result.is_err():
			return eval_result.unwrap_err()

		result.append(eval_result.unwrap())
	
	return result
