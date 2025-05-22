class_name PlayerActions

extends Node
@onready var game_state_manager: GameStateManager = $"../GameStateManager"
@onready var card_manager: CardManager = $"../CardManager"
@onready var game_manager: GameManager = $"../GameManager"
@onready var press_space_hint: Label = $"../CanvasLayer/PressSpaceHint"

@export var can_control_lie : bool = false
var can_lie_this_turn : bool = false

func _ready() -> void:
	EventBusAction.progress_game.connect(update_can_lie_this_turn)
	
func update_can_lie_this_turn():
	can_lie_this_turn = false
	if game_state_manager.current_player == GameStateManager.PLAYER.AI:
		if game_state_manager.player_avialable_actions.has(\
		EventBusAction.ACTION.CALL_BLUFF):
			can_lie_this_turn = true
func select_mark(mark : Card.CARD_MARK) -> void:
	var lied = !CardUtils.check_truth(card_manager.last_add, mark)
	if lied && !can_control_lie:
		EventBusAction.player_lied.emit()
	else:
		EventBusAction.player_told_truth.emit()
	EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.SELECT_MARK, mark)
	
func call_bluff() -> void:
	EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.CALL_BLUFF, null)
	
func declare_trust() -> void:
	EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.DECLARE_TRUST, null)
	
func check_card(mark : Card.CARD_MARK) -> void:
	var correct_mark = game_state_manager.round_mark
	var truth = mark == correct_mark
	EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.ADD_CARD_TO_CHECK, truth)

func add_extra_check() -> void:
	game_manager.player_bonus -= game_manager.extra_check_cost
	for i in game_manager.extra_check_cost:
		EventBus.token_remove.emit(MagicNumbers.PLAYER_ID)
	EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK, null)

func place_cards() -> void:
	if !card_manager.is_selected_correct():
		return
	card_manager.place_cards(true)
	
	if game_state_manager.round_mark_set:
		var lied = !CardUtils.check_truth(card_manager.last_add, \
		game_state_manager.round_mark)
		if lied && !can_control_lie:
			EventBusAction.player_lied.emit()
		else:
			EventBusAction.player_told_truth.emit()
	EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.ADD_CARDS, null)
	
func _process(delta: float) -> void:
	if !can_control_lie:
		press_space_hint.visible = false
		return
	if can_lie_this_turn:
		press_space_hint.visible = true
		if Input.is_key_pressed(KEY_SPACE):
			can_lie_this_turn = false
			EventBusAction.player_lied.emit()
	else:
		press_space_hint.visible = false
