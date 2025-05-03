class_name CardVisualiser

extends Node
@onready var game_state_manager: GameStateManager = $"../GameStateManager"

@onready var player_hand: HBoxContainer = $"../CanvasLayer/Player_Hand"
@onready var enemy_hand: HBoxContainer = $"../CanvasLayer/Enemy_Hand"
@onready var last_add_disp: HBoxContainer = $"../CanvasLayer/LastAdd"
@onready var stack_disp: VBoxContainer = $"../CanvasLayer/Stack"
@onready var selected_color: Button = $"../CanvasLayer/SelectedColor"
@onready var player_actions: PlayerActions = $"../PlayerActions"

const BLUE_BUTTON_THEME = preload("res://Resources/Demo/blue_button_theme.tres")
const GREEN_BUTTON_THEME = preload("res://Resources/Demo/green_button_theme.tres")
const RED_BUTTON_THEME = preload("res://Resources/Demo/red_button_theme.tres")
const VIOLET_BUTTON_THEME = preload("res://Resources/Demo/violet_button_theme.tres")
const GREY_BUTTON_THEME = preload("res://Resources/Demo/grey_button_theme.tres")

@onready var card: Button = $"../CanvasLayer/Player_Hand/Card"
@onready var card_manager: CardManager = $"../CardManager"
const card_view = preload("res://Scenes/Demo/card_view.tscn")
const card_view_back = preload("res://Scenes/Demo/card_view_back.tscn")

var last_add_active : bool = false
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
		var child_card = (child as CardView).base_card
		if hand_player.count(child_card) == 0:
			child.free()
		else:
			present.append(child_card)
	for c in hand_player:
		if present.count(c) > 0:
			continue
		var card = card_view.instantiate()
		player_hand.add_child(card)
		card.set_base_card(c)

func set_cards_active(active : bool) -> void:
	for child in player_hand.get_children():
		var card_view = child as CardView
		card_view.active = active
		if !active:
			card_view.set_selected(false)

func set_last_active(active : bool) -> void:
	last_add_active = active
	for child in last_add_disp.get_children():
		var card_view = child as CardViewBack
		card_view.active = active

func display_enemy_cards() -> void:
	var hand_enemy = card_manager.get_enemy_hand()
	for child in enemy_hand.get_children():
		child.free()
	for c in hand_enemy:
		var card = card_view_back.instantiate()
		card.visible = true
		enemy_hand.add_child(card)

func display_last_add() -> void:
	if last_add_active:
		return
	var last = card_manager.get_last_addition()
	for child in last_add_disp.get_children():
		child.free()
	for c in last:
		var card = card_view_back.instantiate()
		card.set_base_card(c as Card)
		card.set_visualiser(player_actions)
		card.visible = true
		last_add_disp.add_child(card)

func display_stack() -> void:
	var stack = card_manager.get_current_stack()
	for child in stack_disp.get_children():
		child.free()
	for c in stack:
		var card = card_view_back.instantiate()
		card.visible = true
		stack_disp.add_child(card)

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
