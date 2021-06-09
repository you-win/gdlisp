class_name Evaluator
extends Reference

var _depth: int = 0
var _result: Result

# TODO store initial exp here

var _s_expression_stack: Array = []

func _init(result: Result, env: Env):
	_result = result
	env.add("__evaluator__", self)

# TODO change v to be an exp pointer
# Access actual expressions from the stored expressions
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
		_s_expression_stack.push_back(v)
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
#								eval_value = "Unbalanced key/value pairs for table"
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
					var label_name = list[1].get_raw_value()
					var label_data: LabelData = LabelData.new(label_name, env, _s_expression_stack.slice(0, _s_expression_stack.size() - 2))
					
					env.find("__labels__")[label_name] = label_data
				"goto": # Goto specified label (goto ())
					if not _has_exact_args(list.size(), 2, "goto"):
						return
					var global_label_dictionary: Dictionary = env.find("__labels__")
					var label_data: LabelData
					
					# TODO implement breadth-first search for labels
					if not global_label_dictionary.has(list[1].get_raw_value()): # label was not cached
						for i in _s_expression_stack[0].get_raw_value():
							if i.type == Exp.List:
								pass
					else:
						label_data = global_label_dictionary[list[1].get_raw_value()]

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
