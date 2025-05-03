class_name PlayerUIVisualiser3D
extends Node

@onready var card_manager: CardManager = $"../CardManager"
@onready var game_state_manager: GameStateManager = $"../GameStateManager"
@onready var player_actions: PlayerActions = $"../PlayerActions"

@onready var select_color: HBoxContainer = $"../CanvasLayer/SelectColor"
@onready var cards_visulaiser_3d: CardVisualiser3D = $"../CardsVisulaiser3d"

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
	cards_visulaiser_3d.set_cards_active(enable)
	place_cards_button.visible = enable
	if enable:
		EventBus.sit_back_at_table.emit()
func enable_place_cards(enable : bool) -> void:
	place_cards_button.visible = enable
func enable_declare_trust(enable : bool) -> void:
	declare_trust_button.visible = enable
func enable_call_bluff(enable : bool) -> void:
	call_bluff_button.visible = enable
func enable_add_extra_check(enable : bool) -> void:
	extra_check_button.visible = enable
func enable_pick_card_check(enable : bool) -> void:
	cards_visulaiser_3d.set_last_active(enable)
	if enable:
		EventBus.bend_over_table.emit()
	
func update_avialable_actions_UI() -> void:
	if game_state_manager.current_player == GameStateManager.PLAYER.AI:
		disable_all_UI()
		return
	disable_all_UI()
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
	player_actions.call_bluff()
	
func declare_trust() -> void:
	player_actions.declare_trust()
	
func check_card(color : Card.CARD_COLOR) -> void:
	player_actions.check_card(color)

func place_cards() -> void:
	if !card_manager.is_selected_correct():
		return
	player_actions.place_cards()
func add_extra_check() -> void:
	player_actions.add_extra_check()
