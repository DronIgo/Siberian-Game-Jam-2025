class_name CardsStack

extends Node3D

enum Type { NEW, DROPPED }

@export var card_scene: PackedScene

var _current_cards: Array = []

func add_card():
	var card = card_scene.instantiate()
	card.rotation = Vector3(90, 0, 0)
	add_child(card)
	_current_cards.append(card)
