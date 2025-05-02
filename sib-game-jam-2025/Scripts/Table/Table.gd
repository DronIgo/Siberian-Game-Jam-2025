class_name Table

extends Node3D

@onready var _player_hand = $PlayerHand
@onready var _enemy_hand = $EnemyHand
@onready var _player_token_spawner = $PlayerTokenSpawner
@onready var _enemy_token_spawner = $EnemyTokenSpawner

var _hands: Array
var _token_spawners: Array

func _ready():
	_hands = [_player_hand, _enemy_hand]
	_token_spawners = [_player_token_spawner, _enemy_token_spawner]
	EventBus.hand_add_card.connect(_add_card_to_hand)
	EventBus.token_add.connect(_add_token)
	#EventBus.hand_add_card.emit(0, Card3D.Type.RED)
	#EventBus.hand_add_card.emit(0, Card3D.Type.YELLOW)
	#EventBus.hand_add_card.emit(0, Card3D.Type.GREEN)
	#EventBus.hand_add_card.emit(0, Card3D.Type.GRAY)
	#EventBus.hand_add_card.emit(1, Card3D.Type.BLUE)
	#EventBus.hand_add_card.emit(1, Card3D.Type.GRAY)
	_test_token_spawner()

func _add_card_to_hand(player_id: int, card_type: Card3D.Type):
	_hands[player_id].add_card(card_type)

func _add_token(player_id: int):
	_token_spawners[player_id].spawn_token()

func _test_token_spawner():
	get_tree().create_timer(1).timeout.connect(func(): _do_test_token_spawner())

func _do_test_token_spawner():
	EventBus.token_add.emit(0)
	_test_token_spawner()
