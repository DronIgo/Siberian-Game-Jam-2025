class_name PlayerUIVisualiser
extends Node

@onready var card_manager: CardManager = $"../CardManager"
@onready var game_state_manager: GameStateManager = $"../GameStateManager"

@onready var select_color: HBoxContainer = $"../CanvasLayer/SelectColor"
@onready var card_visualiser: CardVisualiser = $"../CardVisualiser"
@onready var place_cards_button: Button = $"../CanvasLayer/PlaceCardsButton"
@onready var declare_trust_button: Button = $"../CanvasLayer/DeclareTrustButton"
@onready var call_bluff_button: Button = $"../CanvasLayer/CallBluffButton"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBusAction.progress_game.connect(update_avialable_actions_UI)
	declare_trust_button.pressed.connect(declare_trust)
	call_bluff_button.pressed.connect(call_bluff)
	place_cards_button.pressed.connect(place_cards)
	disable_all_UI()
	
func disable_all_UI() -> void:
	enable_color_select(false)
	enable_select_cards(false)
	enable_place_cards(false)
	enable_declare_trust(false)
	enable_call_bluff(false)
	enable_add_extra_check(false)
	enable_pick_card_check(false)

func enable_color_select(enable : bool) -> void:
	select_color.visible = enable
func enable_select_cards(enable : bool) -> void:
	card_visualiser.set_cards_active(enable)
	place_cards_button.visible = enable
func enable_place_cards(enable : bool) -> void:
	place_cards_button.visible = enable
func enable_declare_trust(enable : bool) -> void:
	declare_trust_button.visible = enable
func enable_call_bluff(enable : bool) -> void:
	call_bluff_button.visible = enable
func enable_add_extra_check(enable : bool) -> void:
	pass
func enable_pick_card_check(enable : bool) -> void:
	card_visualiser.set_enemy_cards_selectable(enable)
	
func update_avialable_actions_UI() -> void:
	if game_state_manager.current_player == GameStateManager.PLAYER.AI:
		disable_all_UI()
		return
	var avialable_actions = game_state_manager.player_avialable_actions
	for action in avialable_actions:
		match action:
			EventBusAction.PLAYER_ACTION.ADD_CARDS:
				enable_select_cards(true)
			EventBusAction.PLAYER_ACTION.SELECT_COLOR:
				enable_color_select(true)
			EventBusAction.PLAYER_ACTION.DECLARE_TRUST:
				enable_declare_trust(true)
			EventBusAction.PLAYER_ACTION.CALL_BLUFF:
				enable_call_bluff(true)
			EventBusAction.PLAYER_ACTION.ADD_EXTRA_CARD_CHECK:
				enable_add_extra_check(true)
			EventBusAction.PLAYER_ACTION.ADD_CARD_TO_CHECK:
				enable_pick_card_check(true)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func call_bluff() -> void:
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.CALL_BLUFF, null)
	check_card()
	
func declare_trust() -> void:
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.DECLARE_TRUST, null)
	check_card()
	
func check_card() -> void:
	var color = game_state_manager.current_correct_color
	var truth = CardUtils.check_random(card_manager.last_add, color)
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_CARD_TO_CHECK, truth)

func place_cards() -> void:
	if !card_manager.is_stack_correct():
		return
	card_manager.place_cards(true)
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_CARDS, null)
			
