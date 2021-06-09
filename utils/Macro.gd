class_name Macro
extends Reference

var stored_arg_names: Array
var stored_expression: Array
var stored_env: Env

func _init(arg_names: Array, expression: Array, env: Env):
	stored_arg_names = arg_names
	stored_expression = expression
	stored_env = env

func expand(expressions: Array) -> Exp:
	var result_expression := Exp.new(Exp.List, [])
	
#	for i in stored_arg_names.size():
#		var raw_value = expressions[i].get_raw_value()
#		stored_env.add(stored_arg_names[i], GDLArray.new(raw_value))
#
#	var evaluator: Evaluator = stored_env.find("__evaluator__")
#	var is_quoted: bool = false
#	for se in stored_expression:
#		var raw_value = se.get_raw_value()
#		if (raw_value is String and raw_value == "'"):
#			is_quoted = true
#		elif is_quoted:
#			is_quoted = false
#			result_expression.append(se)
#		else:
#			result_expression.append(evaluator.eval(se, stored_env))
	
	return result_expression
