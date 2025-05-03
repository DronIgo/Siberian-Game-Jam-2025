class_name Dialog

extends CanvasLayer

@onready var _replicas_box = $ReplicasBox

var _current_replica_dictionaries: Array
var _next_replica_index = 0

func _ready():
	EventBus.dialog_start.connect(start)
	var current_phase = PhaseManager.current()
	start(current_phase.args[0])

func _process(delta):
	if Input.is_action_just_pressed("dialog_next"):
		next()

func start(config_path: String):
	var config: Dictionary = StorageManager.read_from(config_path)
	_current_replica_dictionaries = config["data"]
	next()

func next():
	if _next_replica_index == _current_replica_dictionaries.size():
		finish()
		return
	var replica = ReplicaData.new(_current_replica_dictionaries[_next_replica_index])
	_replicas_box.new_replica(replica)
	_next_replica_index += 1

func finish():
	#_next_replica_index = 0
	var next_phase = PhaseManager.next()
	get_tree().change_scene_to_file(next_phase.scene_name)
