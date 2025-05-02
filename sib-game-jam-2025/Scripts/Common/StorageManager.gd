class_name StorageManager

static func read_from(file_name: String) -> Dictionary:
	var file = FileAccess.open(file_name, FileAccess.READ)
	if file == null:
		return {}
	var json_string = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}
	var dictionary = json.get_data()
	return dictionary

static func read_from_as_string(file_name: String) -> String:
	var file = FileAccess.open(file_name, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()

static func write_to(file_name: String, data: Dictionary):
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	file.store_line(json_string)
