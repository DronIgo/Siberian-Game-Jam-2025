class_name PlayerUIVisualiser3D
extends Node

@onready var card_manager: CardManager = $"../CardManager"
@onready var game_state_manager: GameStateManager = $"../GameStateManager"
@onready var player_actions: PlayerActions = $"../PlayerActions"

@onready var selected_mark: TextureButton = $"../CanvasLayer/SelectedMark"
@onready var select_mark = $"../CanvasLayer/SelectMark"
@onready var cards_visulaiser_3d: CardVisualiser3D = $"../CardsVisulaiser3d"

@onready var place_cards_button: TextureButton = $"../CanvasLayer/PlaceCardsButton"
@onready var declare_trust_button: TextureButton = $"../CanvasLayer/DeclareTrustButton"
@onready var call_bluff_button: TextureButton = $"../CanvasLayer/CallBluffButton"
@onready var extra_check_button: TextureButton = $"../CanvasLayer/ExtraCheckButton"

var can_have_place_button = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBusAction.progress_game.connect(update_avialable_actions_UI)
	declare_trust_button.pressed.connect(declare_trust)
	call_bluff_button.pressed.connect(call_bluff)
	place_cards_button.pressed.connect(place_cards)
	extra_check_button.pressed.connect(add_extra_check)
	EventBusGL.update_visualisation.connect(update_selected_mark)
	disable_all_UI()
	
func disable_all_UI() -> void:
	enable_mark_select(false)
	enable_select_cards(false)
	enable_place_cards(false)
	enable_declare_trust(false)
	enable_call_bluff(false)
	enable_add_extra_check(false)
	enable_pick_card_check()

func enable_mark_select(enable : bool) -> void:
	select_mark.visible = enable
func enable_select_cards(enable : bool) -> void:
	cards_visulaiser_3d.set_cards_active(enable)
	place_cards_button.visible = enable
	if enable:
		EventBus.sit_back_at_table.emit()
func enable_place_cards(enable : bool) -> void:
	can_have_place_button = enable
func enable_declare_trust(enable : bool) -> void:
	declare_trust_button.visible = enable
func enable_call_bluff(enable : bool) -> void:
	call_bluff_button.visible = enable
func enable_add_extra_check(enable : bool) -> void:
	extra_check_button.visible = enable
func enable_pick_card_check() -> void:
	var enable = game_state_manager.player_avialable_actions.has(\
	EventBusAction.ACTION.ADD_CARD_TO_CHECK)
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
			EventBusAction.ACTION.ADD_CARDS:
				enable_select_cards(true)
				enable_place_cards(true)
			EventBusAction.ACTION.SELECT_MARK:
				enable_mark_select(true)
			EventBusAction.ACTION.DECLARE_TRUST:
				enable_declare_trust(true)
			EventBusAction.ACTION.CALL_BLUFF:
				enable_call_bluff(true)
			EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK:
				enable_add_extra_check(true)
			EventBusAction.ACTION.ADD_CARD_TO_CHECK:
				enable_pick_card_check()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card_manager.selected_cards.size() > 0 && can_have_place_button:
		place_cards_button.visible = true
	else:
		place_cards_button.visible = false

func call_bluff() -> void:
	player_actions.call_bluff()
	
func declare_trust() -> void:
	player_actions.declare_trust()
	
func check_card(mark : Card.CARD_MARK) -> void:
	player_actions.check_card(mark)

func place_cards() -> void:
	if !card_manager.is_selected_correct():
		return
	player_actions.place_cards()
func add_extra_check() -> void:
	player_actions.add_extra_check()


func update_selected_mark() -> void:
	selected_mark.visible = game_state_manager.round_mark_set
	selected_mark.scale = Vector2(0.4, 0.4)
	if ! game_state_manager.round_mark_set:
		return
	else:
		match game_state_manager.round_mark:
			Card.CARD_MARK.KEY:
				selected_mark.texture_normal = load("res://Sprites/UI/buttons/key_button.png")
			Card.CARD_MARK.COIN:
				selected_mark.texture_normal = load("res://Sprites/UI/buttons/coin_button.png")
			Card.CARD_MARK.PUPPET:
				selected_mark.texture_normal = load("res://Sprites/UI/buttons/puppet_button.png")
			Card.CARD_MARK.ALPHABET:
				selected_mark.texture_normal = load("res://Sprites/UI/buttons/alpha_button.png")
