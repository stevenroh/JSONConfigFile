class_name JSONPropertyObject
extends JSONProperty


var _properties := {}
var _required_properties := []
var _default_values := {}
var _exclusivity_relations := []
var _dependency_relations := {}


func add_property(name: String, property: JSONProperty,
		required := true, default_value = null) -> void:
	_properties[name] = property

	if required:
		_required_properties.append(name)

	property.validate(default_value)
	if not property.has_errors():
		_default_values[name] = default_value


func add_exclusivity(exclusive_properties: Array,
		one_is_required := false) -> bool:
	for property in exclusive_properties:
		if not _properties.has(property):
			return false

		for required_property in _required_properties:
			if property == required_property:
				return false

	_exclusivity_relations.append({
		"properties": exclusive_properties,
		"one_is_required": one_is_required,
	})
	return true


func add_dependency(main_property: String, dependent_property: String) -> bool:
	if not _properties.has(main_property):
		return false

	for required_property in _required_properties:
		if main_property == required_property:
			return false

	if not _properties.has(dependent_property):
		return false

	for required_property in _required_properties:
		if dependent_property == required_property:
			return false

	if _dependency_relations.has(main_property):
		_dependency_relations[main_property].append(dependent_property)
	else:
		_dependency_relations[main_property] = [dependent_property]

	return true


func _validate_type(object) -> void:
	if typeof(object) == TYPE_DICTIONARY:
		_result = {}

		for key in object.keys():
			if _properties.has(key):
				var property = _properties[key]

				property._set_dir_path(_dir_path)
				property.validate(object[key])

				_result[key] = property.get_result()

				for error in property.get_errors():
					if error.has("context"):
						error.context = key + "/" + error.context
					else:
						error.context = key

					_errors.append(error)

				if _dependency_relations.has(key):
					for dependent_property in _dependency_relations[key]:
						if not object.has(dependent_property):
							_errors.append({
								"error": Errors.OBJECT_DEPENDENCY_ERROR,
								"main_property": key,
								"dependent_property": dependent_property,
							})
			else:
				_errors.append({
					"error": Errors.OBJECT_NON_VALID_PROPERTY,
					"property": key,
				})

		for required_property in _required_properties:
			if not object.has(required_property):
				_result[required_property] = null

				_errors.append({
					"error": Errors.OBJECT_MISSING_PROPERTY,
					"property": required_property,
				})

		for exclusivity_relation in _exclusivity_relations:
			var properties = []

			for property in exclusivity_relation.properties:
				if _result.has(property):
					properties.append(property)

			if properties.size() == 0:
				if exclusivity_relation.one_is_required:
					_errors.append({
						"error": Errors.OBJECT_ONE_IS_REQUIRED,
						"properties": exclusivity_relation.properties,
					})
			elif properties.size() != 1:
				_errors.append({
					"error": Errors.OBJECT_EXCLUSIVITY_ERROR,
					"properties": properties,
				})

		for key in _default_values.keys():
			if not _result.has(key) or _result[key] == null:
				_result[key] = _default_values[key]

	else:
		_errors.append({
			"error": Errors.WRONG_TYPE,
			"expected": Types.OBJECT,
		})