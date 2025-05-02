class_name Table

extends Node3D

@onready var _player_hand = $PlayerHand
@onready var _enemy_hand = $EnemyHand

var _hands: Array

func _ready():
	_hands = [_player_hand, _enemy_hand]
	EventBus.hand_add_card.connect(_add_card_to_hand)
	EventBus.hand_add_card.emit(0, Card.Type.RED)
	EventBus.hand_add_card.emit(0, Card.Type.YELLOW)
	EventBus.hand_add_card.emit(0, Card.Type.GREEN)
	EventBus.hand_add_card.emit(0, Card.Type.GRAY)
	EventBus.hand_add_card.emit(1, Card.Type.BLUE)
	EventBus.hand_add_card.emit(1, Card.Type.GRAY)

func _add_card_to_hand(player_id: int, card_type: Card.Type):
	_hands[player_id].add_card(card_type)
