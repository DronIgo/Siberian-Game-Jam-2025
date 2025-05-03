class_name PhaseManager

static var _config_path = "res://Configs/phases.json"
static var _phases: Dictionary
static var _current_phase_id: String
static var _next_phase_id: String

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
	_next_phase_id = config["init_scene_id"]

static func next() -> Phase:
	var next_phase: Phase = _phases[_next_phase_id]
	_current_phase_id = next_phase.id
	_next_phase_id = next_phase.next_phase_id
	return next_phase

static func current() -> Phase:
	return _phases[_current_phase_id]
