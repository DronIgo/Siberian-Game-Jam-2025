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
	#Delayed signals from the EventBusGL
	EventBusGL.end_round_delayed.connect(delayed_end_round)
	EventBusGL.start_round_delayed.connect(delayed_start_round)
	EventBusGL.update_visualisation_delayed.connect(delayed_update_visualisation)
	
	#Delayed signals from the EventBusAction
	EventBusAction.progress_game_delayed.connect(delayed_progress_game)
	EventBusAction.send_action_delayed.connect(delayed_send_action)
	EventBusAction.effect_end_delayed.connect(delayed_effect_end)
	
#Delayed signals from the EventBusGL
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

#Delayed signals from the EventBusAction
func delayed_progress_game() -> void:
	if get_tree().paused:
		await game_unpaused
	EventBusAction.progress_game.emit()
	
func delayed_send_action(action : EventBusAction.ACTION, data) -> void:
	if get_tree().paused:
		await game_unpaused
	EventBusAction.send_action.emit(action, data)
	
func delayed_effect_end() -> void:
	if get_tree().paused:
		await game_unpaused
	EventBusAction.effect_end.emit()
