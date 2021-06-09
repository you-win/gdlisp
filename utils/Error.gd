class_name Error
extends Result

func _init(error_message: String, exp_type: int = Exp.ExpType.Atom):
	super(exp_type, error_message)
