class_name SaveDataUtil
extends RefCounted

const SAVE_FILE_EXTENSION: String = "fpwb"

const METADATA_FILE_NAME: String = "fpwb.fpwb"
const LAST_SAVE_FILE_KEY: String = "last_save_file"
const METADATA_TEMPLATE: Dictionary = {
	LAST_SAVE_FILE_KEY: ""
}

var save_directory_path: String

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _init():
	if not OS.is_debug_build():
		save_directory_path = OS.get_executable_path().get_base_dir()
	else:
		save_directory_path = "res://export/"

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

func _load_metadata() -> Dictionary:
	var result: Dictionary = {}
	
	var metadata_exists: bool = false
	
	var dir: Directory = Directory.new()
	if dir.open(save_directory_path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.get_file() == METADATA_FILE_NAME:
				metadata_exists = true
				break
			file_name = dir.get_next()
	
	if metadata_exists:
		var metadata: Dictionary = load_data(METADATA_FILE_NAME)
		if not metadata.is_empty():
			
			pass
	
	return result

func _save_metadata(last_save_file: String) -> void:
	var data: Dictionary = METADATA_TEMPLATE.duplicate()
	data[LAST_SAVE_FILE_KEY] = last_save_file
	
	var file_path: String = "%s/%s.%s" % [self.save_directory_path, self.METADATA_FILE_NAME, self.SAVE_FILE_EXTENSION]
	var save_file: File = File.new()
	save_file.open(file_path, File.WRITE)
	
	var json: JSON = JSON.new()
	save_file.store_string(json.stringify(data))
	
	save_file.close()

###############################################################################
# Public functions                                                            #
###############################################################################

func does_metadata_exist() -> bool:
	var result: bool = false
	
	var dir: Directory = Directory.new()
	if dir.open(save_directory_path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.get_file() == METADATA_FILE_NAME:
				result = true
				break
			file_name = dir.get_next()
	
	return result

func load_data(file_name: String = "") -> Dictionary:
	var result: Dictionary = {}
	
	if file_name.is_empty():
		var metadata: Dictionary = _load_metadata()
		
		if metadata.is_empty():
			return result
		
		file_name = metadata[LAST_SAVE_FILE_KEY]
	
	var file_path: String = "%s/%s" % [self.save_directory_path, file_name]
	
	var save_file: File = File.new()
	save_file.open(file_path, File.READ)
	
	var json: JSON = JSON.new()
	if json.parse(save_file.get_as_text()) == OK:
		result = json.get_data()
#	if (data.error == OK and typeof(data.result) == TYPE_DICTIONARY):
#		result = data.result
	
	save_file.close()
	
	return result

func save_data(file_name: String, data: Dictionary) -> void:
	var file_path: String = "%s/%s.%s" % [self.save_directory_path, file_name, self.SAVE_FILE_EXTENSION]
	var data_to_save: Dictionary = data["data"]
	
	var save_file: File = File.new()
	save_file.open(file_path, File.WRITE)
	
	var json: JSON = JSON.new()
	save_file.store_string(json.stringify(data_to_save))
	
	save_file.close()
	
	_save_metadata(file_name)
