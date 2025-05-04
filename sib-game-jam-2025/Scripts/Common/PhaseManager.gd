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
		var phase = _parse_phase(phase_dictionary)
		_phases[phase.id] = phase
	var events_array = config["events"]
	for event_dictionary: Dictionary in events_array:
		var event = _parse_phase(event_dictionary)
		_events[event.id] = event
	_current_phase_id = config["init_scene_id"]
	_next_phase_id = _phases[_current_phase_id].next_phase_id

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
	if _events.has(id):
		return _events[id]
	return null

static func finish_event():
	is_event = false

static func current_event():
	return _events[_current_event_id]

static func _parse_phase(source: Dictionary) -> Phase:
	var phase = Phase.new()
	phase.id = source["id"]
	phase.scene_name = source["scene_name"]
	phase.args = source["args"]
	phase.music = source["music"] if source.has("music") else SoundConstants.NO_MUSIC
	phase.next_phase_id = source["next_phase_id"]
	phase.is_replacement = source["is_replacement"]
	return phase
