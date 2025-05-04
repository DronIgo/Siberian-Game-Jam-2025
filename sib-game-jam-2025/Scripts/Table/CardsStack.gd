class_name CardsStack

extends Node3D

enum Type { NEW, DROPPED, NON_CHECKABLE, PLAYER_SCORE, ENEMY_SCORE }

@export var card_scene: PackedScene
@export var adding_gap_seconds: float = 0.1

@onready var _timer = $Timer

var _current_cards: Array = []
var _cards_to_add: Array = []

func _ready():
	_timer.wait_time = adding_gap_seconds

func add_cards(num: int):
	for i in num:
		var card = card_scene.instantiate()
		card.rotation = Vector3(90, 0, 0)
		_cards_to_add.append(card)
	if _timer.is_stopped():
		_timer.start()

func add_card():
	add_cards(1)
	print("[CARDS STACK] CARD ADDED")

func remove_card():
	if _current_cards.is_empty() and _cards_to_add.is_empty():
		return
	var target_array = _cards_to_add if not _cards_to_add.is_empty()\
		else _current_cards
	var card = target_array[target_array.size() - 1]
	card.queue_free()
	target_array.erase(card)
	print("[CARDS STACK] CARD REMOVED")

func _on_timer_timeout():
	_check_cards_to_add()

func _check_cards_to_add():
	if _cards_to_add.is_empty():
		return
	var card = _cards_to_add[0]
	_cards_to_add.erase(card)
	_current_cards.append(card)
	add_child(card)
	_timer.start()
