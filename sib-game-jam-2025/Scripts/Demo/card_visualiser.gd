class_name CardVisualiser

extends Node

@onready var player_hand: HBoxContainer = $"../CanvasLayer/Player_Hand"
@onready var card: Button = $"../CanvasLayer/Player_Hand/Card"
@onready var card_manager: CardManager = $"../CardManager"
const card_view = preload("res://Scenes/Demo/card_view.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBusGL.update_visualisation.connect(display_player_cards)

func display_player_cards() -> void:
	var hand_player = card_manager.get_player_hand()
	for child in player_hand.get_children():
		child.free()
	for c in hand_player:
		var card = card_view.instantiate()
		player_hand.add_child(card)
		card.set_active(true)
		card.set_base_card(c)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
