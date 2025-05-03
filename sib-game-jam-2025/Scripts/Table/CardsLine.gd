class_name CardsLine

extends Node3D

@export var card_scene: PackedScene
@export var card_width: float = 40.0
@export var cards_gap: float = 4.0

var _current_cards: Array = []

func add_card(type: Card3D.Type):
	for card in _current_cards:
		card.move_x(-1 * card_width / 100 - cards_gap / 100)
	var card = card_scene.instantiate()
	card.init(type)
	card.rotation = Vector3(90, 0, 0)
	card.disable_physics()
	add_child(card)
	_current_cards.append(card)
	print("[CARDS LINE] CARD ADDED")

func remove_card(index: int):
	if _current_cards.is_empty():
		return
	var card = _current_cards[index]
	card.queue_free()
	_current_cards.erase(card)
	print("[CARDS LINE] CARD REMOVED")

func flip_card(index: int):
	var card = _current_cards[index]
	card.flip()
