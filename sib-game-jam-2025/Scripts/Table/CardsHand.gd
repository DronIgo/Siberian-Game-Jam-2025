class_name CardHand

extends Node3D

@export var card_scene: PackedScene
@export var nose_gap: float = 1
@export var init_angle: float = 10
@export var max_angle: float = 30
@export var layer_step: float = 0.05
@export var horizontal_step: float = 0.15
@export var vertical_step: float = 0.05

var _cards: Array = []
var _selected_cards: Array = []
var _nose_half_gap: float
var _angle_step: float

func _ready():
	var max_cards = MagicNumbers.MAX_CARDS_IN_HAND
	_angle_step = max_angle / \
		((max_cards if max_cards % 2 == 0 else max_cards + 1) / 2)
	_nose_half_gap = nose_gap

func get_card(index : int) -> Card3D:
	return _cards[index] as Card3D

func add_card(base_card: Card):
	var card = card_scene.instantiate()
	card.init(base_card)
	card.disable_physics()
	add_child(card)
	_cards.append(card)
	_replace_cards()
	print("[CARDS HAND] CARD ADDED")

func remove_card(index: int):
	if _cards.is_empty():
		return
	var card = _cards[index]
	card.queue_free()
	_cards.erase(card)
	_replace_cards()
	print("[CARDS HAND] CARD REMOVED")

func select_card(index: int):
	var card = _cards[index]
	_selected_cards.append(index)
	card.select()

func unselect_card(index: int):
	var card = _cards[index]
	_selected_cards.erase(index)
	card.unselect()

func confirm_selected_cards():
	EventBus.hand_confirm_selected.emit(_selected_cards)

func _replace_cards():
	var max_left_index = (_cards.size() - 1) / 2
	_replace_left_half(max_left_index)
	_replace_right_half(max_left_index + 1)

func _replace_left_half(to_index: int):
	if _cards.is_empty():
		return
	for i in to_index + 1:
		var card = _cards[to_index - i]
		var pos = position
		pos.x -= _nose_half_gap + i * horizontal_step
		pos.y -= i * vertical_step
		pos.z += i * layer_step
		card.position = pos
		var angle = init_angle + i * _angle_step
		card.rotation = Vector3(0, 0, deg_to_rad(angle))

func _replace_right_half(from_index: int):
	var cards_num = _cards.size()
	if cards_num <= from_index:
		return
	var j = 0
	for i in range(from_index, cards_num):
		var card: Card3D = _cards[i]
		var pos = position
		pos.x += _nose_half_gap + j * horizontal_step
		pos.y -= j * vertical_step
		pos.z -= j * layer_step
		card.position = pos
		var angle = -1 * init_angle - j * _angle_step
		card.rotation = Vector3(0, 0, deg_to_rad(angle))
		j += 1
