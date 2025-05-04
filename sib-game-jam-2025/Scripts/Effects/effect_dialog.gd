class_name EffectDialog
extends Node


func _ready() -> void:
	pass

func start(dialog_id : String) -> void:
	var dialog_phase = PhaseManager.start_event(dialog_id)
	var scene = load(dialog_phase.scene_name)
	var scene_instance = scene.instantiate()
	add_child(scene_instance)
	EventBus.dialog_finished.connect(finished, CONNECT_ONE_SHOT)
	
func finished() -> void:
	EventBusAction.effect_end.emit()
	queue_free()
