class_name Dialog

extends CanvasLayer

@onready var _replicas_box = $ReplicasBox
@onready var _back: Sprite2D = $BackBase/Back

var _current_replica_dictionaries: Array
var _next_replica_index = 0

func _ready():
	EventBus.dialog_start.connect(start)
	if PhaseManager.is_event:
		start(PhaseManager.current_event())
	else:
		start(PhaseManager.current_phase())

func _process(delta):
	if Input.is_action_just_pressed("dialog_next"):
		next()

func start(phase: Phase):
	if phase.args.size() > 1:
		var bg = load(phase.args[1])
		_back.texture = bg
	var config: Dictionary = StorageManager.read_from(phase.args[0])
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
	EventBus.dialog_finished.emit()
	if PhaseManager.is_event:
		PhaseManager.finish_event()
		queue_free()
		return
	var next_phase = PhaseManager.try_next_phase()
	if not next_phase == null and next_phase.is_replacement:
		get_tree().change_scene_to_file(next_phase.scene_name)
	else:
		queue_free()
