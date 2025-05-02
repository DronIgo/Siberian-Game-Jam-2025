class_name GameManager
extends Node

var inited : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !inited:
		EventBusGL.start_round.emit()
		EventBusGL.update_visualisation.emit()
		inited = true
