class_name GDLisp
extends Reference

var environment: Dictionary = {
	# Operators
	"+": funcref(EnvUtils, "plus"),
	"-": funcref(EnvUtils, "minus"),
	"*": funcref(EnvUtils, "multiply"),
	"/": funcref(EnvUtils, "divide"),
	
	# Primitives
	"true": true,
	"false": false,
	
	# Builtin functions
	"print": funcref(EnvUtils, "print")
}

class EnvUtils:
	static func plus(x, y):
		return x + y
	
	static func minus(x, y):
		return x - y
	
	static func multiply(x, y):
		return x * y
	
	static func divide(x, y):
		return x / y
	
	static func print(x):
		print(x)
		return str(x)

class Atom:
	enum { Symbol = 0, Number }
	var type: int
	var value
	
	func _init(atom_type: int, atom_value) -> void:
		type = atom_type
		value = atom_value
	
	func _to_string() -> String:
		if type == Number:
			return str(value)
		return value
	
	func get_value():
		return value

class Exp:
	enum { Atom = 0, List, Error }
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
			Error:
				return value.get_value()

###############################################################################
# Builtin functions                                                           #
###############################################################################

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

func _tokenize(value: String) -> PoolStringArray:
	return value.replace("(", " ( ").replace(")", " ) ").strip_edges().split(" ", false)

func _atom(token: String) -> Atom:
	if token.is_valid_float():
		return Atom.new(Atom.Number, token.to_float())
	else:
		return Atom.new(Atom.Symbol, token)

func _read_from_tokens(tokens: Array) -> Exp:
	var result: Exp = Exp.new(Exp.List, [])
	
	if tokens.size() == 0:
		return Exp.new(Exp.Error, _atom("Unexpected EOF"))
	
	var token: String = tokens.pop_back()
	
	if tokens.size() == 0:
		return Exp.new(Exp.Error, _atom("Unexpected EOF"))
	
	match token:
		"(":
			while tokens[tokens.size() - 1] != ")":
				result.append(_read_from_tokens(tokens))
			tokens.pop_back() # Remove last ')'
		")":
			return Exp.new(Exp.Error, _atom("Unexpected token"))
		_:
			return Exp.new(Exp.Atom, _atom(token))
	
	return result

func _check_converted_tokens_for_errors(converted_tokens: Exp) -> Array:
	var result: Array = []
	match converted_tokens.type:
		Exp.Atom:
			# Do nothing
			pass
		Exp.List:
			for i in converted_tokens.get_value():
				var inner_errors: Array = _check_converted_tokens_for_errors(i)
				if inner_errors.size() > 0:
					result.append_array(inner_errors)
		Exp.Error:
			result.append(converted_tokens.get_raw_value())
	
	return result

func _eval(v: Exp, env: Dictionary = environment):
	if v.type == Exp.Atom:
		match v.get_value().type:
			Atom.Symbol:
				var raw_value = v.get_raw_value()
				
				# Check for string
				if (raw_value.begins_with('"') and raw_value.ends_with('"')):
					return raw_value
				
				if not env.has(raw_value):
					AppManager.log_message(raw_value)
					return "Undefined symbol"
				
				return env[v.get_raw_value()]
			Atom.Number:
				return v.get_raw_value()
	elif v.type == Exp.List:
		var list: Array = v.get_value()
		if list.size() == 0:
			return "Empty S-expression"
		match list[0].get_raw_value():
			"if":
				var test = list[1]
				var consequence = list[2]
				var alt = list[3]
				var expression
				if (_eval(test, env)):
					expression = consequence
				else:
					expression = alt
				return _eval(expression, env)
			"def":
				var symbol = list[1]
				var expression = list[2]
				env[symbol.get_raw_value()] = _eval(expression, env)
			_:
				var procedure: FuncRef = _eval(list[0], env)
				var args: Array = []
				for arg in list.slice(1, list.size() - 1, 1, true):
					args.append(_eval(arg, env))
				return procedure.call_funcv(args)

###############################################################################
# Public functions                                                            #
###############################################################################

func parse_string(value: String) -> String:
	var result: String = ""
	
	# String
	var tokens := Array(_tokenize(value))
	if tokens.size() == 0:
		return "Empty input"
	
	tokens.invert()
	
	var converted_tokens: Exp = _read_from_tokens(tokens)
	var error = _check_converted_tokens_for_errors(converted_tokens)
	if error:
		return error
	
	return _eval(converted_tokens)
