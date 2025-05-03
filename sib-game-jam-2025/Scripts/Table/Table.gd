class_name Table

extends Node3D

@onready var _player_hand = $Camera3D/PlayerHand
@onready var _enemy_hand = $EnemyHand
@onready var _player_token_spawner = $PlayerTokenSpawner
@onready var _enemy_token_spawner = $EnemyTokenSpawner
@onready var _new_cards_stack = $NewCardsStack
@onready var _dropped_cards_stack = $DroppedCardsStack
@onready var _non_checkable_cards_stack = $NonCheckableCardsStack
@onready var _checkable_cards_line = $CheckableCardsLine
@onready var _nose = $Camera3D/Nose

var _cards_hands: Array = []
var _token_spawners: Array = []

func _ready():
	_cards_hands.resize(2)
	_cards_hands[MagicNumbers.PLAYER_ID] = _player_hand
	_cards_hands[MagicNumbers.ENEMY_ID] = _enemy_hand
	_token_spawners.resize(2)
	_token_spawners[MagicNumbers.PLAYER_ID] = _player_token_spawner
	_token_spawners[MagicNumbers.ENEMY_ID] = _enemy_token_spawner
	EventBus.hand_add_card.connect(_add_card_to_hand)
	EventBus.hand_remove_card.connect(_remove_card_from_hand)
	EventBus.hand_select_card.connect(_select_card_in_hand)
	EventBus.hand_unselect_card.connect(_unselect_card_in_hand)
	EventBus.token_add.connect(_add_token)
	EventBus.token_remove.connect(_remove_token)
	EventBus.stack_add_card.connect(_add_card_to_stack)
	EventBus.stack_remove_card.connect(_remove_card_from_stack)
	EventBus.line_add_card.connect(_add_card_to_checkable_line)
	EventBus.line_remove_card.connect(_remove_card_from_checkable_line)
	EventBus.line_flip_card.connect(_flip_card_in_checkable_line)
	EventBus.nose_increase.connect(_increase_nose)

# tests
func _input(ev):
	if Input.is_key_pressed(KEY_1):
		EventBus.hand_add_card.emit(MagicNumbers.PLAYER_ID, Card3D.Type.values().pick_random())
	elif Input.is_key_pressed(KEY_2):
		EventBus.hand_remove_card.emit(MagicNumbers.PLAYER_ID, 0)
	elif Input.is_key_pressed(KEY_3):
		EventBus.hand_select_card.emit(MagicNumbers.PLAYER_ID, 0)
	elif Input.is_key_pressed(KEY_4):
		EventBus.hand_unselect_card.emit(MagicNumbers.PLAYER_ID, 0)
	elif Input.is_key_pressed(KEY_5):
		EventBus.stack_add_card.emit(CardsStack.Type.DROPPED)
	elif Input.is_key_pressed(KEY_6):
		EventBus.stack_remove_card.emit(CardsStack.Type.DROPPED)
	elif Input.is_key_pressed(KEY_7):
		EventBus.token_add.emit(MagicNumbers.PLAYER_ID)
	elif Input.is_key_pressed(KEY_8):
		EventBus.token_remove.emit(MagicNumbers.PLAYER_ID)
	elif Input.is_key_pressed(KEY_9):
		EventBus.token_add.emit(MagicNumbers.ENEMY_ID)
	elif Input.is_key_pressed(KEY_0):
		EventBus.nose_increase.emit()

func _increase_nose():
	_nose.increase()

func _add_card_to_hand(player_id: int, card_type: Card3D.Type):
	_cards_hands[player_id].add_card(card_type)

func _remove_card_from_hand(player_id: int, index: int):
	_cards_hands[player_id].remove_card(index)

func _select_card_in_hand(player_id: int, index: int):
	_cards_hands[player_id].select_card(index)

func _unselect_card_in_hand(player_id: int, index: int):
	_cards_hands[player_id].unselect_card(index)

func _add_card_to_checkable_line(card_type: Card3D.Type):
	_checkable_cards_line.add_card(card_type)

func _remove_card_from_checkable_line(index: int):
	_checkable_cards_line.remove_card(index)

func _flip_card_in_checkable_line(index: int):
	_checkable_cards_line.flip_card(index)

func _add_token(player_id: int):
	_token_spawners[player_id].add_token()

func _remove_token(player_id: int):
	_token_spawners[player_id].remove_token()

func _add_card_to_stack(stack_type: CardsStack.Type):
	match stack_type:
		CardsStack.Type.NEW:
			_new_cards_stack.add_card()
		CardsStack.Type.DROPPED:
			_dropped_cards_stack.add_card()
		CardsStack.Type.NON_CHECKABLE:
			_non_checkable_cards_stack.add_card()

func _remove_card_from_stack(stack_type: CardsStack.Type):
	match stack_type:
		CardsStack.Type.NEW:
			_new_cards_stack.remove_card()
		CardsStack.Type.DROPPED:
			_dropped_cards_stack.remove_card()
		CardsStack.Type.NON_CHECKABLE:
			_non_checkable_cards_stack.remove_card()
