class_name CardVisualiser3D

extends Node
@onready var game_state_manager: GameStateManager = $"../GameStateManager"
@onready var ray_casting_manager: Node = $"../RayCastingManager"

@onready var selected_color: Button = $"../CanvasLayer/SelectedColor"
@onready var player_actions: PlayerActions = $"../PlayerActions"
@onready var player_hand: CardHand = $"../Camera3D/PlayerHand"
@onready var enemy_hand: CardHand = $"../EnemyFakeCamera/EnemyHand"
@onready var checkable_cards_line: CardsLine = $"../CheckableCardsLine"
@onready var non_checkable_cards_stack: CardsStack = $"../NonCheckableCardsStack"

const BLUE_BUTTON_THEME = preload("res://Resources/Demo/blue_button_theme.tres")
const GREEN_BUTTON_THEME = preload("res://Resources/Demo/green_button_theme.tres")
const RED_BUTTON_THEME = preload("res://Resources/Demo/red_button_theme.tres")
const VIOLET_BUTTON_THEME = preload("res://Resources/Demo/violet_button_theme.tres")
const GREY_BUTTON_THEME = preload("res://Resources/Demo/grey_button_theme.tres")

@onready var card_manager: CardManager = $"../CardManager"

var last_add_active : bool = false
var player_cards_active : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBusGL.update_visualisation.connect(display_player_cards)
	EventBusGL.update_visualisation.connect(display_enemy_cards)
	EventBusGL.update_visualisation.connect(display_last_add)
	EventBusGL.update_visualisation.connect(display_stack)
	EventBusGL.update_visualisation.connect(update_selected_color)

#есть отличия от display_enemy_hand, потому что UI 
func display_player_cards() -> void:
	var hand_player = card_manager.get_player_hand()
	var present = []
	for child in player_hand.get_children():
		var child_card = (child as Card3D).base_card
		if hand_player.count(child_card) == 0:
			child.free()
		else:
			present.append(child_card)
	for c in hand_player:
		if present.count(c) > 0:
			continue
		var base_card = c as Card
		EventBus.hand_add_card.emit(MagicNumbers.PLAYER_ID, base_card)
	for card3d in player_hand._cards:
		card3d.set_raycast_layer(RaycastLayers.LAYER.COMMON |\
		RaycastLayers.LAYER.PLAYER_CARDS)
		card3d.selectable = player_cards_active

func set_cards_active(active : bool) -> void:
	player_cards_active = active
	for card3d in player_hand._cards:
		card3d.selectable = player_cards_active

func set_last_active(active : bool) -> void:
	last_add_active = active
	for card3d in checkable_cards_line._current_cards:
		card3d.flipable = active
		card3d.set_raycast_mask(RaycastLayers.LAYER.COMMON |\
		RaycastLayers.LAYER.ENEMY_CARDS)

func display_enemy_cards() -> void:
	var hand_enemy = card_manager.get_enemy_hand()
	var present = []
	for child in enemy_hand.get_children():
		var child_card = (child as Card3D).base_card
		if hand_enemy.count(child_card) == 0:
			child.free()
		else:
			present.append(child_card)
	for c in hand_enemy:
		if present.count(c) > 0:
			continue
		var base_card = c as Card
		EventBus.hand_add_card.emit(MagicNumbers.ENEMY_ID, base_card)

func display_last_add() -> void:
	if last_add_active:
		return
	var last = card_manager.get_last_addition()
	for child in checkable_cards_line.get_children():
		child.free()
	for c in last:
		EventBus.line_add_card.emit(c as Card)
		#card.set_visualiser(player_actions)

func display_stack() -> void:
	var stack = card_manager.get_current_stack()
	while non_checkable_cards_stack.get_children().size() < stack.size():
		EventBus.stack_add_card.emit(CardsStack.Type.NON_CHECKABLE)

func update_selected_color() -> void:
	selected_color.visible = game_state_manager.color_selected
	if ! game_state_manager.color_selected:
		return
	else:
		match game_state_manager.current_correct_color:
			Card.CARD_COLOR.RED:
				selected_color.theme = RED_BUTTON_THEME
			Card.CARD_COLOR.BLUE:
				selected_color.theme = BLUE_BUTTON_THEME
			Card.CARD_COLOR.GREEN:
				selected_color.theme = GREEN_BUTTON_THEME
			Card.CARD_COLOR.VIOLET:
				selected_color.theme = VIOLET_BUTTON_THEME

func _physics_process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var card = ray_casting_manager.find_raycast_player_card()
		if card:
			print("Cool")
