class_name PlayerActions

extends Node
@onready var game_state_manager: GameStateManager = $"../GameStateManager"
@onready var card_manager: CardManager = $"../CardManager"
@onready var game_manager: GameManager = $"../GameManager"


func select_color(color : Card.CARD_COLOR) -> void:
	var lied = !CardUtils.check_truth(card_manager.last_add, color)
	if lied:
		EventBusAction.player_lied.emit()
	else:
		EventBusAction.player_told_truth.emit()
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.SELECT_COLOR, color)
	
func call_bluff() -> void:
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.CALL_BLUFF, null)
	
func declare_trust() -> void:
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.DECLARE_TRUST, null)
	
func check_card(color : Card.CARD_COLOR) -> void:
	var correct_color = game_state_manager.current_correct_color
	var truth = color == correct_color
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_CARD_TO_CHECK, truth)

func add_extra_check() -> void:
	game_manager.player_bonus -= game_manager.extra_check_cost
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_EXTRA_CARD_CHECK, null)

func place_cards() -> void:
	if !card_manager.is_selected_correct():
		return
	card_manager.place_cards(true)
	
	if game_state_manager.color_selected:
		var lied = !CardUtils.check_truth(card_manager.last_add, \
		game_state_manager.current_correct_color)
		if lied:
			EventBusAction.player_lied.emit()
		else:
			EventBusAction.player_told_truth.emit()
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_CARDS, null)
			
