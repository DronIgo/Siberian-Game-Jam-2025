class_name PlayerActions

extends Node
@onready var game_state_manager: GameStateManager = $"../GameStateManager"
@onready var card_manager: CardManager = $"../CardManager"


func select_color(color : Card.CARD_COLOR) -> void:
	var lied = !CardUtils.check_truth(card_manager.last_add, color)
	if lied:
		EventBusAction.player_lied.emit()
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.SELECT_COLOR, color)
	
func call_bluff() -> void:
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.CALL_BLUFF, null)
	
func declare_trust() -> void:
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.DECLARE_TRUST, null)
	
func check_card() -> void:
	var color = game_state_manager.current_correct_color
	var truth = CardUtils.check_random(card_manager.last_add, color)
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_CARD_TO_CHECK, truth)

func place_cards() -> void:
	if !card_manager.is_selected_correct():
		return
	card_manager.place_cards(true)
	
	if game_state_manager.color_selected:
		var lied = !CardUtils.check_truth(card_manager.last_add, \
		game_state_manager.current_correct_color)
		if lied:
			EventBusAction.player_lied.emit()
			
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_CARDS, null)
			
