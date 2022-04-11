extends Reference

###############################################################################
# Utils                                                                       #
###############################################################################

class Result:
	var _value
	var _error: Error

	func _init(v) -> void:
		if not v is Error:
			_value = v
		else:
			_error = v

	func is_ok() -> bool:
		return not is_err()
	
	func is_err() -> bool:
		return _error != null
	
	func unwrap():
		return _value

	func unwrap_err() -> Error:
		return _error

	static func ok(v = null) -> Result:
		return Result.new(v if v != null else OK)

	static func err(error_code: int, description: String = "") -> Result:
		return Result.new(Error.new(error_code, description))

class Error:
	enum Code {
		NONE = 0,

		#region Compiler

		# Preprocessor
		INVALID_PREPROCESSOR_REPLACEMENTS,

		# Tokenizer
		PROGRAM_TOO_SHORT,
		MISMATCHED_PARENS,
		MISMATCHED_SQUARE_BRACKETS,
		MISMATCHED_CURLY_BRACKETS,

		# Parser
		DEPTH_NOT_ZERO,

		#endregion
	}

	var _error: int
	var _description: String

	func _init(error: int, description: String = "") -> void:
		_error = error
		_description = description

	func error_code() -> int:
		return _error

	func error_name() -> String:
		return Code.keys()[_error]

	func error_description() -> String:
		return _description

###############################################################################
# Model                                                                       #
###############################################################################

class ScopeBuiltins:
	static func plus(a, b):
		return a + b

	static func minus(a, b):
		return a - b

	static func multiply(a, b):
		return a * b

	static func divide(a, b):
		return a / b

	static func equals(a, b):
		return a == b

	static func not_equals(a, b):
		return a != b

	static func less_than(a, b):
		return a < b
	
	static func less_than_equal_to(a, b):
		return a <= b

	static func greater_than(a, b):
		return a > b

	static func greater_than_equal_to(a, b):
		return a >= b

	static func print(a):
		print(a)

var global_scope_builtins := {
	#region Operators

	"+": funcref(ScopeBuiltins, "plus"),
	"-": funcref(ScopeBuiltins, "minus"),
	"*": funcref(ScopeBuiltins, "multiply"),
	"/": funcref(ScopeBuiltins, "divide"),
	"==": funcref(ScopeBuiltins, "equals"),
	"!=": funcref(ScopeBuiltins, "not_equals"),
	"<": funcref(ScopeBuiltins, "less_than"),
	"<=": funcref(ScopeBuiltins, "less_than_equal_to"),
	">": funcref(ScopeBuiltins, "greater_than"),
	">=": funcref(ScopeBuiltins, "greater_than_equal_to"),

	#endregion

	#region Primitives

	"true": true,
	"false": false,

	#endregion

	#region Builtin funcs

	"print": funcref(ScopeBuiltins, "print"),
	"self": self,
	
	#endregion
}

class GdlCollection:
	var _inner # Array or Dictionary

	func _to_string() -> String:
		return str(_inner)

	func set(key, value) -> void:
		_inner[key] = value

	func get(key):
		return _inner[key]

	func size() -> int:
		return _inner.size()

	func inner():
		return _inner

	func duplicate():
		return _inner.duplicate(true)

	func clear() -> void:
		_inner.clear()

class GdlArray extends GdlCollection:
	func _init(value: Array = []) -> void:
		_inner = value

	func append(v) -> void:
		push(v)

	func push(v) -> void:
		_inner.append_array(v) if typeof(v) == TYPE_ARRAY else _inner.append(v)

	func pop():
		return _inner.pop_back() if _inner.size() > 0 else null

	func duplicate() -> GdlArray:
		return GdlArray.new(.duplicate())

class GdlDictionary extends GdlCollection:
	func _init(value: Dictionary = {}) -> void:
		_inner = value

	func keys() -> Array:
		return _inner.keys()

	func values() -> Array:
		return _inner.values()

	func duplicate() -> GdlDictionary:
		return GdlDictionary.new(.duplicate())

class Stack:
	var _stack := [] # Exp
	
	var is_invalid := false

	func push(e) -> void:
		"""
		Pushes an element to the back of the stack
		"""
		_stack.push_back(e)

	func pop():
		"""
		Pops an element from the stack if possible or returns null
		"""
		if _stack.size() < 1:
			printerr("Invalid pop, nothing on stack")
			return null

		_stack.pop_back()

	func back():
		"""
		Returns the last element on the stack or null if there is no element

		Does not use the builtin back() function to avoid stderr logs
		"""
		return _stack[-1] if _stack.size() > 0 else null

	func size() -> int:
		"""
		Gets the size of the stack
		"""
		return _stack.size()

	func finish():
		"""
		Pops everything from the stack so that the stack is completely
		empty
		"""
		while _stack.size() > 1:
			pop()

		return _stack.pop_back()

class Scope:
	var _inner := {}
	var _outer: Scope

	func _init(outer: Scope = null, var_names: Array = [], var_values: Array = []) -> void:
		if outer:
			_outer = outer
		
		if var_names.size() != var_values.size():
			printerr("Input variable names do not match values")
			return

		for i in var_names.size():
			_inner[var_names[i]] = var_values[i]

	# TODO this uses recursion
	func find(key: String):
		"""
		Finds a value in the current or outer scopes
		"""
		return _inner.get(key, _outer.find(key) if _outer else null)

	func add(key: String, value) -> void:
		"""
		Add a key/value to the current scope
		"""
		_inner[key] = value

	# TODO this uses recursion
	func set_existing_value(key: String, value) -> bool:
		"""
		Try and set 
		"""
		if key in _inner:
			_inner[key] = value
			return true
		elif _outer:
			return _outer.set_existing_value(key, value)
		return false

class Exp:
	enum Type {
		NONE = 0,
		
		#region Atoms
		
		SYM,
		NUM,
		STR,

		#endregion

		LIST
	}

	var type: int
	var _value

	func _init(exp_type: int, exp_value) -> void:
		type = exp_type
		_value = exp_value

	func _to_string() -> String:
		return to_json({
			"type": Type.keys()[type],
			"value": _value
		})

	func value():
		return _value as Array if type == Type.LIST else _value

	func append(v) -> int:
		if not type == Type.LIST:
			printerr("Tried to append to an Atom")
			return ERR_BUG

		_value.append_array(v) if typeof(v) == TYPE_ARRAY else _value.append(v)
		return OK

###############################################################################
# Compiler                                                                    #
###############################################################################

class Preprocessor:
	var replacements := {} # Search key: String -> replacement value: String

	var _is_valid := true

	func _init(p_replacements: Dictionary) -> void:
		replacements = p_replacements

		var keys := replacements.keys()
		for val in replacements.values():
			if val in keys:
				_is_valid = false

	func run(input: String) -> Result:
		if not _is_valid:
			return Result.err(Error.Code.INVALID_PREPROCESSOR_REPLACEMENTS)

		for key in replacements.keys():
			input = input.replace(key, replacements[key])

		return Result.ok()

class Tokenizer:
	enum Token {
		NONE = 0,
		EXPRESSION,
		SPACE,
		SYMBOL,
		QUOTATION,
		BRACKET,
		ESCAPE_CHARACTER,
		COMMENT
	}

	const NEWLINE_CHAR := "\n"
	const DOUBLE_QUOTE_CHAR := "\""
	const ESCAPE_CHAR := "\\"
	const COMMENT_CHAR := ";"

	var _result := []

	var _token_builder := []
	var _last_token: int = Token.NONE

	#region Flags

	var _is_escape_character := false
	var _is_comment := false

	#endregion

	#region Counters

	var _paren_counter: int = 0
	var _square_bracket_counter: int = 0
	var _curly_bracket_counter: int = 0

	#endregion

	static func _build_token(builder: Array, output: Array) -> void:
		"""
		Builds a String from an array and adds it to an output array
		"""
		if builder.size() > 0:
			var pool := PoolStringArray(builder)
			builder.clear()

			output.append(pool.join(""))

	func _handle_double_quote(input: String) -> void:
		"""
		Handles a double quote character that is NOT yet known to be a
		String literal
		"""
		if _is_escape_character:  # Double quote literal
			_token_builder.append(input)
			_is_escape_character = false
		elif _last_token == Token.QUOTATION: # Close double quote
			_token_builder.append(input)
			_last_token = Token.NONE
			_build_token(_token_builder, _result)
		else: # Open double quote
			_token_builder.append(input)
			_last_token = Token.QUOTATION

	func _handle_open_quotation(input: String) -> void:
		"""
		Handles a double quote character that acts as a String literal
		"""
		if input == ESCAPE_CHAR:
			_is_escape_character = true
		else:
			_token_builder.append(input)

	func _handle_char(input: String) -> void:
		"""
		Handles non-special characters
		"""
		match input:
			"(":
				_paren_counter += 1
				_handle_grouper(input, Token.EXPRESSION)
			")":
				_paren_counter -= 1
				_handle_grouper(input, Token.NONE)
			"[":
				_square_bracket_counter += 1
				_handle_grouper(input, Token.BRACKET)
			"]":
				_square_bracket_counter -= 1
				_handle_grouper(input, Token.NONE)
			"{":
				_curly_bracket_counter += 1
				_handle_grouper(input, Token.BRACKET)
			"}":
				_curly_bracket_counter -= 1
				_handle_grouper(input, Token.NONE)
			" ", "\r\n", "\n", "\r\r", "\t":
				_build_token(_token_builder, _result)
				_last_token = Token.SPACE
			COMMENT_CHAR:
				_build_token(_token_builder, _result)
				_last_token = Token.COMMENT
			_:
				_last_token = Token.SYMBOL
				_token_builder.append(input)

	func _handle_grouper(input: String, last_token: int) -> void:
		"""
		Handles grouping characters like (), [], {}

		Directly adds the grouping character to the output
		"""
		_build_token(_token_builder, _result)
		_last_token = last_token
		_result.append(input)

	func run(input: String) -> Result:
		if input.length() < 2:
			return Result.err(Error.Code.PROGRAM_TOO_SHORT)

		for idx in input.length():
			var c: String = input[idx]
			
			# Order matters here
			# Must check for double quotes first otherwise they will be handled
			# as a regular char
			if c == DOUBLE_QUOTE_CHAR:
				_handle_double_quote(c)
			elif _last_token == Token.QUOTATION:
				_handle_open_quotation(c)
			elif _last_token == Token.COMMENT and c == COMMENT_CHAR:
				_is_comment = true
			elif _is_comment:
				# Comments stop at the end of a line
				if c == NEWLINE_CHAR:
					_is_comment = false
			else:
				_handle_char(c)
		
		if _paren_counter != 0:
			return Result.err(Error.Code.MISMATCHED_PARENS)

		if _square_bracket_counter != 0:
			return Result.err(Error.Code.MISMATCHED_SQUARE_BRACKETS)

		if _curly_bracket_counter != 0:
			return Result.err(Error.Code.MISMATCHED_CURLY_BRACKETS)

		return Result.ok(_result)

class Parser:
	class ParserStack extends Stack:
		func push(e: Exp) -> void:
			"""
			Pushes an expression onto the stack. Depending on the expression type,
			the expression is either appended to the last element or appended
			to the stack
			"""
			if e.type == Exp.Type.LIST:
				_stack.push_back(e)
			else:
				back().append(e)
		
		func pop() -> Exp:
			"""
			Pops the last expression from the stack if there are at least 2 items

			After the expression is popped, it is added to the new last expression
			"""
			if _stack.size() < 1:
				printerr("Invalid pop, nothing on stack")
				return null
	
			var e: Exp = _stack.pop_back()
			var parent: Exp = back()
			if parent:
				if not parent.append(e) == OK:
					is_invalid = true
			return e
	var _result := Exp.new(Exp.Type.LIST, [])

	var _stack := ParserStack.new()

	var _depth: int = 0
	
	#region Flags

	var _is_s_expression := false
	var _is_list := false
	var _is_dict := false
	var _is_quoted := false

	#endregion

	func _init() -> void:
		_stack.push(_result)

	func _atom(token: String) -> Exp:
		if token.begins_with("\""):
			return Exp.new(Exp.Type.STR, token.substr(1, token.length() - 2))
		elif token.is_valid_float():
			return Exp.new(Exp.Type.NUM, token.to_float())
		else:
			return Exp.new(Exp.Type.SYM, token)

	func run(tokens: Array) -> Result:
		# Always invert since we are popping from the stack
		tokens.invert()
		
		var token: String = tokens.pop_back()

		while true:
			match token:
				"(":
					_depth += 1
					_is_s_expression = true
					_stack.push(Exp.new(Exp.Type.LIST, []))
				")":
					_depth -= 1
					_is_s_expression = false
					_stack.pop()
				"[":
					_depth += 1
					_is_list = true
					_stack.push(_atom("list"))
				"]":
					_depth -= 1
					_is_list = false
					_stack.pop()
				"{":
					_depth += 1
					_is_dict = true
					_stack.push(_atom("dict"))
				"}":
					_depth -= 1
					_is_dict = false
					_stack.pop()
				"'":
					_is_quoted = not _is_quoted
				_:
					_stack.push(_atom(token))

			if tokens.size() < 1:
				break
			token = tokens.pop_back()

		if _depth != 0:
			return Result.err(Error.Code.DEPTH_NOT_ZERO)

		return Result.ok(_stack.finish())

###############################################################################
# Interpreter                                                                 #
###############################################################################

# TODO still uses recursion
class Evaluator:
	class Procedure:
		var _arg_names := []
		var _expression: Exp
		var _scope: Scope

		func _init(arg_names: Array, expression: Exp, scope: Scope) -> void:
			_arg_names.append_array(arg_names)
			_expression = expression
			_scope = scope

		func call_func(arg_values: Array):
			for i in _arg_names.size():
				_scope.add(_arg_names[i], arg_values[i])

			return _scope.find(EVALUATOR_SCOPE_NAME).run(_expression, _scope)

	const EVALUATOR_SCOPE_NAME := "__evaluator__"
	const INVALID_STATE := "Invalid state"
	var _is_valid := true

	var _scope: Scope

	func _init(scope: Scope) -> void:
		_scope = scope
		_scope.add(EVALUATOR_SCOPE_NAME, self)

	static func _print_arg_mismatch(op: String, expected: int, actual: int) -> void:
		printerr("%s statement expected %d, got %d" % [op, expected, actual])

	func _has_exact_args(list_size: int, expected_size: int) -> bool:
		if list_size != expected_size:
			return false
		return true

	func _has_enough_args(list_size: int, min_size: int) -> bool:
		if list_size < min_size:
			return false
		return true

	# TODO this is recursive
	func run(expression: Exp, scope: Scope = null):
		"""
		Completely evaluate the given Expression

		The first Expression will be guaranteed to be a list
		"""
		if not _is_valid:
			return INVALID_STATE

		if not scope:
			scope = _scope

		var value = expression.value()
		
		match expression.type:
			Exp.Type.SYM:
				var scope_value = scope.find(value)

				if scope_value == null:
					printerr("Undefined symbol %s" % str(value))
					_is_valid = false
					continue
				return scope_value
			Exp.Type.STR, Exp.Type.NUM:
				return value
			Exp.Type.LIST:
				if value.size() == 0:
					return null

				match value[0].value():
					"if": # (if (test) (then) (else))
						if not _has_exact_args(value.size(), 4):
							_print_arg_mismatch("if", 4, value.size())
							return
						
						# 1 - test
						# 2 - then
						# 3 - else
						return run(value[2] if run(value[1], scope) else value[3], scope)
					"do": # (do (...))
						if not _has_enough_args(value.size(), 2):
							_print_arg_mismatch("do", 2, value.size())
							return

						return run(value.slice(1, value.size()), Scope.new(scope))
					"while": # (while (test) (then))
						if not _has_enough_args(value.size(), 3):
							_print_arg_mismatch("while", 3, value.size())
							return

						var while_val
						while run(value[1], scope):
							for s in value.slice(2, value.size()):
								while_val = run(s, scope)

						return while_val
					"for": # (for counter [list] (then))
						pass
					"def": # (def name value) Set a new value in the current scope
						if not _has_exact_args(value.size(), 3):
							_print_arg_mismatch("def", 3, value.size())
							return

						scope.add(value[1].value(), run(value[2], scope))
					"=": # (= name value) Set a value in the current or higher scope
						if not _has_exact_args(value.size(), 3):
							_print_arg_mismatch("=", 3, value.size())
							return

						if not scope.set_existing_value(value[1], run(value[2], scope)):
							printerr("Tried to set a non-existent variable %s" % value[1])
							return
					"list": # (list (values ...))
						pass
					"dict": # (dict (k v ...))
						pass
					"lam": # (lam [args] ()...)
						pass
					"macro": # (macro [args] () ...)
						pass
					"raw": # (raw object method [params])
						pass
					"expr": # (expr code) Use advanced-expression-gd to run raw code
						pass
					"label": # (label name)
						pass
					"goto": # (godot label)
						pass
					"import": # (import path)
						pass
					_:
						var procedure = run(value[0], scope)
						if not procedure is FuncRef and not procedure is Procedure:
							return procedure
		
						var args := []
						for arg in value.slice(1, value.size() - 1, 1, true):
							args.append(run(arg, scope))
		
						if procedure is String:
							_is_valid = false
							return null
		
						return procedure.call_funcv(args)


###############################################################################
# Builtin functions                                                           #
###############################################################################

func _init() -> void:
	pass

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
