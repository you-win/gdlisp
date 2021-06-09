class_name Error
extends Exp

func _init(error_message: String, exp_type: int = Exp.Atom):
	super(exp_type, error_message)
