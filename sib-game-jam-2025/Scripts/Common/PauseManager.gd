extends Node

signal game_paused
signal game_unpaused

func pause() -> void:
	get_tree().paused = true
	game_paused.emit()
	
func unpause() -> void:
	get_tree().paused = false
	game_unpaused.emit()

func _ready() -> void:
	#Delaysed signals from the EventBusGL
	EventBusGL.end_round_delayed.connect(delayed_end_round)
	EventBusGL.start_round_delayed.connect(delayed_start_round)
	EventBusGL.update_visualisation_delayed.connect(delayed_update_visualisation)
	
#Delaysed signals from the EventBusGL
func delayed_end_round(round_result : EventBusGL.END_ROUND_RESULT) -> void:
	if get_tree().paused:
		await game_unpaused
	EventBusGL.end_round.emit(round_result)

func delayed_start_round() -> void:
	if get_tree().paused:
		await game_unpaused
	EventBusGL.start_round.emit()
	
func delayed_update_visualisation() -> void:
	if get_tree().paused:
		await game_unpaused
	EventBusGL.update_visualisation.emit()
