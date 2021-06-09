class_name Procedure
extends Reference

var stored_arg_names: Array
var stored_expressions: Exp
var stored_env: Env

func _init(arg_names: Array, expressions: Exp, env: Env):
	stored_arg_names = arg_names
	stored_expressions = expressions
	stored_env = env

func call(arg_values: Array):
	for i in stored_arg_names.size():
		stored_env.add(stored_arg_names[i], arg_values[i])
	
	var evaluator = stored_env.find("__evaluator__")
	
	return evaluator.eval(stored_expressions, stored_env)
