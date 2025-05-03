class_name CardsStack

extends Node3D

enum Type { NEW, DROPPED, NON_CHECKABLE, PLAYER_SCORE, ENEMY_SCORE }

@export var card_scene: PackedScene

var _current_cards: Array = []

func add_card():
	var card = card_scene.instantiate()
	card.rotation = Vector3(90, 0, 0)
	add_child(card)
	_current_cards.append(card)
	print("[CARDS STACK] CARD ADDED")

func remove_card():
	if _current_cards.is_empty():
		return
	var card = _current_cards[_current_cards.size() - 1]
	card.queue_free()
	_current_cards.erase(card)
	print("[CARDS STACK] CARD REMOVED")
