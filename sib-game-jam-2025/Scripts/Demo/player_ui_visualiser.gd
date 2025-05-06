class_name PlayerUIVisualiser
extends Node

@onready var card_manager: CardManager = $"../CardManager"
@onready var game_state_manager: GameStateManager = $"../GameStateManager"
@onready var ACTIONs: PlayerActions = $"../PlayerActions"

@onready var select_color = $"../CanvasLayer/SelectColor"
@onready var card_visualiser: CardVisualiser = $"../CardVisualiser"
@onready var place_cards_button: Button = $"../CanvasLayer/PlaceCardsButton"
@onready var declare_trust_button: Button = $"../CanvasLayer/DeclareTrustButton"
@onready var call_bluff_button: Button = $"../CanvasLayer/CallBluffButton"
@onready var extra_check_button: Button = $"../CanvasLayer/ExtraCheckButton"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBusAction.progress_game.connect(update_avialable_actions_UI)
	declare_trust_button.pressed.connect(declare_trust)
	call_bluff_button.pressed.connect(call_bluff)
	place_cards_button.pressed.connect(place_cards)
	extra_check_button.pressed.connect(add_extra_check)
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
	extra_check_button.visible = enable
func enable_pick_card_check(enable : bool) -> void:
	card_visualiser.set_last_active(enable)
	
	
func update_avialable_actions_UI() -> void:
	if game_state_manager.current_player == GameStateManager.PLAYER.AI:
		disable_all_UI()
		return
	disable_all_UI()
	var avialable_actions = game_state_manager.player_avialable_actions
	for action in avialable_actions:
		match action:
			EventBusAction.ACTION.ADD_CARDS:
				enable_select_cards(true)
			EventBusAction.ACTION.SELECT_MARK:
				enable_color_select(true)
			EventBusAction.ACTION.DECLARE_TRUST:
				enable_declare_trust(true)
			EventBusAction.ACTION.CALL_BLUFF:
				enable_call_bluff(true)
			EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK:
				enable_add_extra_check(true)
			EventBusAction.ACTION.ADD_CARD_TO_CHECK:
				enable_pick_card_check(true)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func call_bluff() -> void:
	ACTIONs.call_bluff()
	
func declare_trust() -> void:
	ACTIONs.declare_trust()
	
func place_cards() -> void:
	if !card_manager.is_selected_correct():
		return
	ACTIONs.place_cards()
func add_extra_check() -> void:
	ACTIONs.add_extra_check()
