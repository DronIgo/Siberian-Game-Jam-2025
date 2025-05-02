class_name CardHand

extends Node3D

@export var card_scene: PackedScene
@export var card_width: float = 40.0
@export var cards_gap: float = 4.0

var _current_cards: Array = []

func add_card(type: Card.Type):
	for card in _current_cards:
		card.move(-1 * card_width / 100 - cards_gap / 100)
	var card = card_scene.instantiate()
	card.init(type)
	add_child(card)
	_current_cards.append(card)
