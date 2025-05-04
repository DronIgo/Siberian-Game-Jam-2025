class_name PhaseManager

static var _config_path = "res://Configs/phases.json"
static var _phases: Dictionary
static var _events: Dictionary
static var _current_phase_id: String
static var _next_phase_id: String
static var _current_event_id: String

static var is_event: bool = false

static func init():
	var config: Dictionary = StorageManager.read_from(_config_path)
	var phases_array = config["phases"]
	for phase_dictionary: Dictionary in phases_array:
		var phase = Phase.new()
		phase.id = phase_dictionary["id"]
		phase.scene_name = phase_dictionary["scene_name"]
		phase.args = phase_dictionary["args"]
		phase.next_phase_id = phase_dictionary["next_phase_id"]
		phase.is_replacement = phase_dictionary["is_replacement"]
		_phases[phase.id] = phase
	var events_array = config["events"]
	for event_dictionary: Dictionary in events_array:
		var event = Phase.new()
		event.id = event_dictionary["id"]
		event.scene_name = event_dictionary["scene_name"]
		event.args = event_dictionary["args"]
		event.next_phase_id = event_dictionary["next_phase_id"]
		event.is_replacement = event_dictionary["is_replacement"]
		_events[event.id] = event
	_next_phase_id = config["init_scene_id"]

static func try_next_phase() -> Phase:
	return exact_phase(_next_phase_id)

static func current_phase() -> Phase:
	return _phases[_current_phase_id]

static func exact_phase(id: String) -> Phase:
	if id == "":
		return null
	var next_phase: Phase = _phases[id]
	_current_phase_id = next_phase.id
	_next_phase_id = next_phase.next_phase_id
	return next_phase

static func start_event(id: String) -> Phase:
	is_event = true
	_current_event_id = id
	return _events[id]

static func finish_event():
	is_event = false

static func current_event():
	return _events[_current_event_id]
