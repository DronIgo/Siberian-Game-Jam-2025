class_name CardVisualiser

extends Node

@onready var player_hand: HBoxContainer = $"../CanvasLayer/Player_Hand"
@onready var enemy_hand: HBoxContainer = $"../CanvasLayer/Enemy_Hand"
@onready var last_add_disp: HBoxContainer = $"../CanvasLayer/LastAdd"
@onready var stack_disp: VBoxContainer = $"../CanvasLayer/Stack"

@onready var card: Button = $"../CanvasLayer/Player_Hand/Card"
@onready var card_manager: CardManager = $"../CardManager"
const card_view = preload("res://Scenes/Demo/card_view.tscn")
const card_view_back = preload("res://Scenes/Demo/card_view_back.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBusGL.update_visualisation.connect(display_player_cards)
	EventBusGL.update_visualisation.connect(display_enemy_cards)
	EventBusGL.update_visualisation.connect(display_last_add)
	EventBusGL.update_visualisation.connect(display_stack)

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

func set_enemy_cards_selectable(active : bool) -> void:
	pass

func display_enemy_cards() -> void:
	var hand_enemy = card_manager.get_enemy_hand()
	for child in enemy_hand.get_children():
		child.free()
	for c in hand_enemy:
		var card = card_view_back.instantiate()
		enemy_hand.add_child(card)

func display_last_add() -> void:
	var last = card_manager.get_last_addition()
	for child in last_add_disp.get_children():
		child.free()
	for c in last:
		var card = card_view_back.instantiate()
		last_add_disp.add_child(card)

func display_stack() -> void:
	var stack = card_manager.get_current_stack()
	for child in stack_disp.get_children():
		child.free()
	for c in stack:
		var card = card_view_back.instantiate()
		stack_disp.add_child(card)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
