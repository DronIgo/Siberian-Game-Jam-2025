class_name EffectDialog
extends Node


func _ready() -> void:
	pass

func start(dialog_id : String) -> void:
	var dialog_phase = PhaseManager.exact(dialog_id)
	if !dialog_phase.is_replacement:
		var scene = load(dialog_phase.scene_name)
		var scene_instance = scene.instantiate()
		add_child(scene_instance)
	#EventBus.end_dialog.connect(finished)
	
func finished() -> void:
	EventBusAction.effect_end.emit()
	queue_free()
