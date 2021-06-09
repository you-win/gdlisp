class_name GDLisp
extends Reference

class Result:
	var _tuple: Array

	func _init(v0, v1):
		_tuple = [v0, v1]

	func unwrap():
		# Error
#		if _tuple.g1():
		if _tuple[1]:
			AppManager.log_message("Unwrapped an error", true)
			return null
		else:
			return _tuple[0]

	func unwrap_err() -> String:
		return _tuple[1]

	func is_ok() -> bool:
		return not _tuple[1]

	func is_err() -> bool:
		return not is_ok()

	func set_value(value) -> void:
		_tuple[0] = value

	func set_error(value) -> void:
		_tuple[1] = value

var global_environment_dictionary: Dictionary = {
	# Operators
	"+": Callable(EnvUtils, "plus"),
	"-": Callable(EnvUtils, "minus"),
	"*": Callable(EnvUtils, "multiply"),
	"/": Callable(EnvUtils, "divide"),
	"==": Callable(EnvUtils, "equals"),
	"!=": Callable(EnvUtils, "not_equals"),
	"<": Callable(EnvUtils, "less_than"),
	"<=": Callable(EnvUtils, "less_than_or_equal_to"),
	">": Callable(EnvUtils, "greater_than"),
	">=": Callable(EnvUtils, "greater_than_or_equal_to"),
	
	# Primitives
	"true": true,
	"false": false,
	
	# Builtin functions
	"print": Callable(EnvUtils, "print"),
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

class Tokenizer:
	enum TokenType { None = 0, ParseExpression, ParseSpace, ParseSymbol, ParseQuotation, ParseBracket, ParseEscapeCharacter }

	var current_type = TokenType.None
	var is_escape_character: bool = false

	var token_builder: PackedStringArray = PackedStringArray()

	func _build_token(result: Array) -> void:
		if token_builder.size() != 0:
			var token_string: String = ""
			for i in token_builder:
				token_string += i
			result.append(token_string)
			token_builder = PackedStringArray()

	func tokenize(value: String):
		var result: Array = []
		var error

		var paren_counter: int = 0
		var square_bracket_counter: int = 0
		var curly_bracket_counter: int = 0
		
		# Checks for raw strings of size 1
		if value.length() <= 2:
			return [result, "Program too short"]

		for i in value.length():
			var c: String = value[i]
			if c == '"':
				if is_escape_character: # This is a double quote literal
					token_builder.append(c)
					is_escape_character = false
				elif current_type == TokenType.ParseQuotation: # Close the double quote
					token_builder.append(c)
					current_type = TokenType.None
					_build_token(result)
				else: # Open the double quote
					token_builder.append(c)
					current_type = TokenType.ParseQuotation
			elif current_type == TokenType.ParseQuotation:
				if c == "\\":
					is_escape_character = true
				else:
					token_builder.append(c)
			else:
				match c:
					"(":
						paren_counter += 1
						_build_token(result)
						current_type = TokenType.ParseExpression
						result.append(c)
					")":
						paren_counter -= 1
						_build_token(result)
						current_type = TokenType.None
						result.append(c)
					"[":
						square_bracket_counter += 1
						_build_token(result)
						current_type = TokenType.ParseBracket
						result.append(c)
					"]":
						square_bracket_counter -= 1
						_build_token(result)
						current_type = TokenType.None
						result.append(c)
					"{":
						curly_bracket_counter += 1
						_build_token(result)
						current_type = TokenType.ParseBracket
						result.append(c)
					"}":
						curly_bracket_counter -= 1
						_build_token(result)
						current_type = TokenType.None
						result.append(c)
					" ", "\r\n", "\n", "\t":
						_build_token(result)
						current_type = TokenType.ParseSpace
					# "\\":
						# if current_type == ParseQuotation:
							# is_escape_character = true
					_:
						current_type = TokenType.ParseSymbol
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

		return [result, error]

class Parser:
	var _depth: int = 0
	var _result: Result

	var _is_quoted: bool = false

	func _init(result: Result):
		_result = result
	
	func parse(tokens: Array):
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

class LabelData:
	var name: String
	var scope: Env
	var stack: Array

	func _init(label_name: String, outer_env: Env, label_stack: Array):
		name = label_name
		scope = outer_env
		stack = label_stack

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _init():
	# NOTE we don't duplicate here since it doesn't really matter + it's a global
	global_env._inner = global_environment_dictionary

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

func _tokenize(value: String):
	var tokenizer: Tokenizer = Tokenizer.new()

	return tokenizer.tokenize(value)

func _parse(tokens: Array, result: Result):
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
	
	tokens.reverse()

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
