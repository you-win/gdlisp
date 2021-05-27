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

class GDLCollectionWrapper:
	var _value
	
	func set(key, value) -> void:
		_value[key] = value
	
	func get(key):
		return _value[key]
	
	func get_raw_value():
		return _value
	
	func duplicate():
		return _value.duplicate(true)
	
	func _to_string() -> String:
		return "GDLCollectionWrapper:%s" % str(_value)

class GDLArray extends GDLCollectionWrapper:
	func _init(value: Array = []) -> void:
		_value = value
	
	func append(value) -> void:
		_value.append(value)

class GDLDictionary extends GDLCollectionWrapper:
	func _init(value: Dictionary = {}) -> void:
		_value = value

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
	"!=": funcref(EnvUtils, "not_equals"),
	"<": funcref(EnvUtils, "less_than"),
	"<=": funcref(EnvUtils, "less_than_or_equal_to"),
	">": funcref(EnvUtils, "greater_than"),
	">=": funcref(EnvUtils, "greater_than_or_equal_to"),
	
	# Primitives
	"true": true,
	"false": false,
	
	# Builtin functions
	"print": funcref(EnvUtils, "print"),
	"self": self,

	# Label indexing
	"__labels__": {} # String: LabelData
}

var global_env: Env = Env.new()

class EnvUtils:
	static func plus(a: Array):
		if a.size() < 2:
			return a[0]

		var result = a[0]
		for i in a.slice(1, a.size() - 1):
			result += i
		return result
	
	static func minus(a: Array):
		if a.size() < 2:
			return -a[0]

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

	static func not_equals(a: Array):
		if a.size() != 2:
			return false
		return a[0] != a[1]
	
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

	func duplicate() -> Exp:
		return Exp.new(self.type, self.value)

class Tokenizer:
	enum { None = 0, ParseExpression, ParseSpace, ParseSymbol, ParseQuotation, ParseBracket }

	var current_type: int = None
	var is_escape_character: bool = false

	var token_builder: PoolStringArray = PoolStringArray()

	func _build_token(result: Array) -> void:
		if token_builder.size() != 0:
			result.append(token_builder.join(""))
			token_builder = PoolStringArray()

	func tokenize(value: String) -> Result:
		var result: Array = []
		var error

		var paren_counter: int = 0
		var square_bracket_counter: int = 0
		var curly_bracket_counter: int = 0
		
		# Checks for raw strings of size 1
		if value.length() <= 2:
			return Result.new(result, "Program too short")

		for i in value.length():
			var c: String = value[i]
			if c == '"':
				if is_escape_character: # This is a double quote literal
					token_builder.append(c)
					is_escape_character = false
				elif current_type == ParseQuotation: # Close the double quote
					token_builder.append(c)
					current_type = None
					_build_token(result)
				else: # Open the double quote
					token_builder.append(c)
					current_type = ParseQuotation
			elif current_type == ParseQuotation:
				if c == "\\":
					is_escape_character = true
				else:
					token_builder.append(c)
			else:
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
						square_bracket_counter += 1
						_build_token(result)
						current_type = ParseBracket
						result.append(c)
					"]":
						square_bracket_counter -= 1
						_build_token(result)
						current_type = None
						result.append(c)
					"{":
						curly_bracket_counter += 1
						_build_token(result)
						current_type = ParseBracket
						result.append(c)
					"}":
						curly_bracket_counter -= 1
						_build_token(result)
						current_type = None
						result.append(c)
					" ", "\r\n", "\n", "\t":
						_build_token(result)
						current_type = ParseSpace
					# "\\":
						# if current_type == ParseQuotation:
							# is_escape_character = true
					_:
						current_type = ParseSymbol
						token_builder.append(c)
		
		if paren_counter != 0:
			result.clear()
			error = "Mismatched parens"

		if square_bracket_counter != 0:
			result.clear()
			error = "Mismatched square brackets"

		if curly_bracket_counter != 0:
			result.clear()
			error = "Mismatched curly brackets"

		return Result.new(result, error)

class Parser:
	var _depth: int = 0
	var _result: Result

	var _is_quoted: bool = false

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
			"{":
				_depth += 1
				list_expression.append(Exp.new(Exp.Atom, _atom("table")))
				while tokens[tokens.size() - 1] != "}":
					list_expression.append(parse(tokens))
				tokens.pop_back() # Remove last '}'
			"}":
				return _error("Unexpected }")
			"'":
				_is_quoted = true
				return Exp.new(Exp.Atom, _atom("'"))
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
		_result.set_error(error_message)
		return None.new()

class Evaluator:
	class EvalStack:
		var input_expression: Exp
		var last_se: Exp

		var call_stack: Array
		var current_index: int

		func _init(p_exp: Exp) -> void:
			input_expression = Exp.new(Exp.List, [])
			# TODO add end label
			input_expression.append(p_exp)
			last_se = p_exp
			# Stack of s-expression indices
			call_stack = [] # int
			# Current index inside of s-expression
			current_index = -1
		
		func get_se_at_abs(location: Array, index: int = 0) -> Exp:
			"""
			Used for jumping out of the current call stack
			"""
			var result: Exp = input_expression

			for i in location:
				result = input_expression.get_raw_value()[i]

			return result.get_raw_value()[index]

		func get_se_at_rel(index: int) -> Exp:
			call_stack.append(index)

			last_se = last_se.get_raw_value()[index]

			return last_se

	var _depth: int = 0
	var _result: Result
	
	var _eval_stack

	func _init(result: Result, env: Env) -> void:
		_result = result
		env.add("__evaluator__", self)

	# TODO change v to be an exp pointer
	# Access actual expressions from the stored expressions
	func eval(v: Exp, env: Env):
		"""
		TODO work example, remove later
		(do
			(def x 0)
			(print "hello")
			(print x))
		"""
		_eval_stack = EvalStack.new(v)
		# The result of an s-expression
		var eval_value
		# The result of searching for an atom
		var atom_values: Array = []
		
		while true:
			_eval_stack.current_index += 1
			var se: Exp = _eval_stack.get_se_at_rel(_eval_stack.current_index)

			if se.type == Exp.Atom:
				match se.get_value().type:
					Atom.Sym:
						var raw_value = se.get_raw_value()
						var env_value = env.find(raw_value)
						
						if env_value == null:
							AppManager.log_message("Undefined symbol %s" % raw_value)
							eval_value = "Undefined symbol"
							_result.set_error(eval_value)
							continue
						
						# eval_value = env_value
						atom_values.append(env_value)
					Atom.Str:
						# eval_value = se.get_raw_value()
						atom_values.append(se.get_raw_value())
					Atom.Num:
						# eval_value = se.get_raw_value()
						atom_values.append(se.get_raw_value())
			elif se.type == Exp.List:
				var list: Array = se.get_value()
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
							eval_value = eval(expression, env)
						"do": # (do () ...)
							if not _has_enough_args(list.size(), 2, "do"):
								return
							var inner_env = Env.new(env)
							for s in list.slice(1, list.size()):
								eval_value = eval(s, inner_env)
						"while": # (while (test) ())
							if not _has_enough_args(list.size(), 3, "while"):
								return
							var test = list[1]
							while eval(test, env):
								for s in list.slice(2, list.size()):
									eval_value = eval(s, env)
						"for": # (for [] ())
							pass
						"def": # Create new variable in the current scope (def () ())
							if not _has_exact_args(list.size(), 3, "def"):
								return
							var symbol = list[1]
							var expression = list[2]
							env.add(symbol.get_raw_value(), eval(expression, env))
						"=": # Sets a variable in the current or outer scope (= () ())
							if not _has_exact_args(list.size(), 3, "="):
								return
							var symbol = list[1]
							var expression = list[2]
							if not env.set_existing_value(symbol.get_raw_value(), eval(expression, env)):
								eval_value = "Tried to set a non-existent variable %s" % symbol
								_result.set_error(eval_value)
								return
						"list": # Returns a Godot array (list () ...)
							eval_value = GDLArray.new()
							if list.size() >= 2:
								for item in list.slice(1, list.size() - 1, 1, true):
									eval_value.append(eval(item, env))
						"table":
							eval_value = GDLDictionary.new()
							if list.size() >= 2:
								# Check for equal pairs
								if not (list.size() - 1) % 2 == 0:
									eval_value = "Unbalanced key/value pairs for table"
									_result.set_error(eval_value)
									return
								var idx: int = 1
								while idx < list.size():
									eval_value.set(eval(list[idx], env), eval(list[idx + 1], env))
									idx += 2
						"lam": # Lambda (lam [] () ...)
							if not _has_enough_args(list.size(), 3, "lam"):
								return
							var arg_names = list[1].get_raw_value()
							if not arg_names is Array:
								eval_value = "lam expects a list of parameter names"
								_result.set_error(eval_value)
								return
							if arg_names.size() == 1: # Can never be 0, so let us crash if it somehow is
								arg_names = []
							else:
								arg_names = arg_names.slice(1, arg_names.size() - 1)
								for i in arg_names.size():
									arg_names[i] = arg_names[i].get_raw_value()

							var expressions = Exp.new(Exp.List, [])
							expressions.append(Exp.new(Exp.Atom, Atom.new(Atom.Sym, "do")))
							for expression in list.slice(2, list.size() - 1, 1, true):
								expressions.append(expression)

							eval_value = Procedure.new(arg_names, expressions, Env.new(env))
						"macro": # (macro [] () ...)
							if not _has_enough_args(list.size(), 3, "macro"):
								return
							var arg_names = list[1].get_raw_value()
							if arg_names.size() < 2:
								arg_names = []
							else:
								arg_names = arg_names.slice(1, arg_names.size() - 1)
								for i in arg_names.size():
									arg_names[i] = arg_names[i].get_raw_value()

							eval_value = Macro.new(arg_names, list.slice(2, list.size() - 1, 1, true), Env.new(env))
						"raw": # (raw () () ...)
							if not _has_enough_args(list.size(), 3, "raw"):
								return
							var object = eval(list[1], env)
							var method = list[2].get_raw_value()
							if not method is String:
								eval_value = "method in raw call must be a String"
								_result.set_error(eval_value)
								return
							var call_args := []
							if list.size() > 3:
								for i in list.slice(3, list.size() - 1, 1, true):
									call_args.append(i.get_raw_value())
							eval_value = object.callv(method, call_args)
						"expr": # (expr ())
							if not _has_exact_args(list.size(), 2, "expr"):
								return
							var input_expression = list[1].get_raw_value()
							if not input_expression is String:
								eval_value = "Expression body must be a String"
								_result.set_error(eval_value)
								return
							var godot_expression: Expression = Expression.new()
							var error = godot_expression.parse(input_expression)
							if error != OK:
								eval_value = "Failed to parse expression"
								_result.set_error(eval_value)
								return
							eval_value = godot_expression.execute()
						"label": # Label all nested S-expressions (label ())
							if not _has_exact_args(list.size(), 2, "label"):
								return
							pass
						"goto": # Goto specified label (goto ())
							if not _has_exact_args(list.size(), 2, "goto"):
								return
							var global_label_dictionary: Dictionary = env.find("__labels__")
							var label_data: LabelData
							pass
						# TODO fill this out
						"import": # Import file from relative path (import ())
							pass
						_:
							var procedure = eval(list[0], env)
							if procedure is Macro:
								# We don't want to evaluate anything yet until the macro is expanded
								eval_value = eval(procedure.expand(list.slice(1, list.size() - 1, 1, true)), Env.new(env))
								continue
							elif (not procedure is FuncRef and not procedure is Procedure):
								eval_value = procedure
								# NOTE this is the catch-all match, so this continue is okay
								continue
							var args: Array = []
							for arg in list.slice(1, list.size() - 1, 1, true):
								args.append(eval(arg, env))
							if procedure is String:
								eval_value = "Invalid procedure: %s" % procedure
								_result.set_error(eval_value)
								return
							eval_value = procedure.call_func(args)
		
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

	func _init(arg_names: Array, expressions: Exp, env: Env) -> void:
		stored_arg_names = arg_names
		stored_expressions = expressions
		stored_env = env

	func call_func(arg_values: Array):
		for i in stored_arg_names.size():
			stored_env.add(stored_arg_names[i], arg_values[i])
		
		return stored_env.find("__evaluator__").eval(stored_expressions, stored_env)

# TODO only works for single-level macros, nested expressions don't work
# probably want to write a custom eval function that only evaluates atoms
class Macro:
	"""
	Example
	(def infix (macro [code]
		(raw code get 0)
		(raw code get 1)
		(raw code get 2)))
	(infix (1 + 1))
	"""
	var stored_arg_names: Array
	var stored_expression: Array
	var stored_env: Env

	func _init(arg_names: Array, expression: Array, env: Env) -> void:
		stored_arg_names = arg_names
		stored_expression = expression
		stored_env = env

	func expand(expressions: Array) -> Exp:
		var result_expression := Exp.new(Exp.List, [])
		
		for i in stored_arg_names.size():
			var raw_value = expressions[i].get_raw_value()
			stored_env.add(stored_arg_names[i], GDLArray.new(raw_value))

		var evaluator: Evaluator = stored_env.find("__evaluator__")
		var is_quoted: bool = false
		for se in stored_expression:
			var raw_value = se.get_raw_value()
			if (raw_value is String and raw_value == "'"):
				is_quoted = true
			elif is_quoted:
				is_quoted = false
				result_expression.append(se)
			else:
				result_expression.append(evaluator.eval(se, stored_env))
		
		return result_expression

class LabelData:
	var name: String
	var scope: Env
	var stack: Array

	func _init(label_name: String, outer_env: Env, label_stack: Array) -> void:
		name = label_name
		scope = outer_env
		stack = label_stack

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
