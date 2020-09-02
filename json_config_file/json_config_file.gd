class_name JSONConfigFile


var _configuration := JSONPropertyObject.new()
var _preprocessing_errors = null


func add_property(name : String, property : JSONProperty):
	_configuration.add_property(name, property)


func has_property(name : String) -> bool:
	return _configuration.has_property(name)


func get_property(name : String) -> JSONProperty:
	return _configuration.get_property(name)


func remove_property(name : String):
	_configuration.remove_property(name)


func get_result() -> Dictionary:
	var result = _configuration.get_result()

	if result != null:
		return result
	else:
		return {}


func has_errors() -> bool:
	if _preprocessing_errors != null:
		return _preprocessing_errors.size() != 0
	return _configuration.has_errors()


func get_errors() -> Array:
	if _preprocessing_errors != null:
		return _preprocessing_errors
	return _configuration.get_errors()


func validate(file_path : String) -> void:
	_preprocessing_errors = null

	var file = File.new()
	var error = file.open(file_path, File.READ)
	if error != OK:
		_preprocessing_errors = []
		_preprocessing_errors.append({
			"error": JSONProperty.Errors.COULD_NOT_OPEN_FILE,
			"code": error,
		})
		_configuration._reset()
		return

	var text = file.get_as_text()
	if text == "":
		_preprocessing_errors = []
		_preprocessing_errors.append({
			"error": JSONProperty.Errors.EMPTY_FILE,
		})
		_configuration._reset()
		return

	var json = JSON.parse(text)
	error = json.get_error()
	if error != OK:
		_preprocessing_errors = []
		_preprocessing_errors.append({
			"error": JSONProperty.Errors.JSON_PARSING_ERROR,
			"code": error,
			"line": json.get_error_line(),
			"string": json.get_error_string(),
		})
		_configuration._reset()
		return
	
	_configuration.validate(json.get_result())
