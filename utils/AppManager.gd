extends Node

signal message_logged(message)

var sdu: SaveDataUtil = SaveDataUtil.new()

var current_save_data: Dictionary

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
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

func log_message(message: String, is_error: bool = false) -> void:
	if is_error:
		message = "[ERROR] %s" % message
		assert(false, message)
	print(message)
	emit_signal("message_logged", message)

func does_metadata_exist() -> bool:
	return sdu.does_metadata_exist()

func load_data(path: String = "") -> Dictionary:
	"""
	Wrapper around SaveDataUtil.load_data(...)
	
	defaults to metadata value if empty string is passed
	"""
	return sdu.load_data(path)

func save_data(file_name: String, data: Dictionary) -> void:
	"""
	Wrapper around SaveDataUtil.save_data(...)
	"""
	sdu.save_data(file_name, data)
