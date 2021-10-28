class_name TestBase
extends RefCounted

###############################################################################
# Builtin functions                                                           #
###############################################################################

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

func _create_empty_result() -> GDLisp.Result:
	return GDLisp.Result.new(null, null)

func _create_atom(token: String) -> GDLisp.Atom:
	if token.begins_with('"'):
		return GDLisp.Atom.new(GDLisp.Atom.Str, token.substr(1, token.length() - 2))
	elif token.is_valid_float():
		return GDLisp.Atom.new(GDLisp.Atom.Num, token.to_float())
	else:
		return GDLisp.Atom.new(GDLisp.Atom.Sym, token)

func _create_expression_from_atom(atom: GDLisp.Atom) -> GDLisp.Exp:
	return GDLisp.Exp.new(GDLisp.Exp.Atom, atom)

###############################################################################
# Public functions                                                            #
###############################################################################

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
