class_name Table

extends Node3D

@export var bend_over_anim_name = "bend_over"
@export var sit_back_anim_name = "sit_back"
@export var enemy_hand_up_anim_name = "hand_up"
@export var enemy_hand_down_anim_name = "hand_down"

@onready var _player_hand = $PlayerFakeCamera/PlayerHand
@onready var _enemy_hand: CardHand = $Enemy/Shoulder/EnemyFakeCamera/EnemyHand
@onready var _player_token_spawner = $PlayerTokenSpawner
@onready var _enemy_token_spawner = $EnemyTokenSpawner
@onready var _new_cards_stack = $NewCardsStack
@onready var _dropped_cards_stack = $DroppedCardsStack
@onready var _non_checkable_cards_stack = $NonCheckableCardsStack
@onready var _player_score_cards_stack = $PlayerScoreCardsStack
@onready var _enemy_score_cards_stack = $EnemyScoreCardsStack
@onready var _checkable_cards_line = $CheckableCardsLine
@onready var _nose = $Camera3D/Nose
@onready var _anim_player = $AnimationPlayer
@onready var _animation_player_cards = $AnimationPlayerCards
@onready var _enemy_hand_anim_player = $Enemy/Shoulder/AnimationPlayer

var _cards_hands: Array = []
var _token_spawners: Array = []
var _enemy_hand_raised: bool = true

func _ready():
	CardTexturesHolder.init()
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
	EventBus.token_add_several.connect(_add_several_tokens)
	EventBus.token_remove.connect(_remove_token)
	EventBus.stack_add_card.connect(_add_card_to_stack)
	EventBus.stack_add_several_cards.connect(_add_several_cards_to_stack)
	EventBus.stack_remove_card.connect(_remove_card_from_stack)
	EventBus.line_add_card.connect(_add_card_to_checkable_line)
	EventBus.line_remove_card.connect(_remove_card_from_checkable_line)
	EventBus.line_flip_card.connect(_flip_card_in_checkable_line)
	EventBus.nose_increase.connect(_increase_nose)
	EventBus.bend_over_table.connect(_bend_over)
	EventBus.sit_back_at_table.connect(_sit_back)
	EventBus.show_cards.connect(_show_cards)
	EventBus.hide_cards.connect(_hide_cards)
	EventBus.enemy_hand_up.connect(_enemy_hand_up)
	EventBus.enemy_hand_down.connect(_enemy_hand_down)
	#var phase = PhaseManager.current_phase()
	#MusicProcessor.process(phase)
	EventBus.token_add_several.emit(MagicNumbers.ENEMY_ID, 5)
	EventBus.token_add_several.emit(MagicNumbers.PLAYER_ID, 5)

var sit : bool = true
var card_choosing = false

func _next_game_event(id: String):
	var event = PhaseManager.start_event(id)
	var scene = load(event.scene_name)
	var scene_instance = scene.instantiate()
	add_child(scene_instance)

func _next_game_phase():
	var next_phase: Phase = PhaseManager.try_next_phase()
	if next_phase.is_replacement:
		get_tree().change_scene_to_file(next_phase.scene_name)
	else:
		var scene = load(next_phase.scene_name)
		var scene_instance = scene.instantiate()
		add_child(scene_instance)

# tests
func _new_card() -> Card:
	var new_card = Card.new()
	new_card.color = Card.CARD_COLOR.values().pick_random()
	new_card.value = Card3D.Value.values().pick_random()
	if new_card.color == Card.CARD_COLOR.GREY:
		new_card.value = 9
	new_card.bonus_mod = 1
	new_card.score_mod = 1
	return new_card

func _bend_over():
	if sit:
		_anim_player.play(bend_over_anim_name)
		sit = false

func _sit_back():
	if !sit:
		_anim_player.play(sit_back_anim_name)
		sit = true

func _show_cards():
	print("_show_cards")
	if EventBus.card_select_animation_in_progress:
		return
	if !card_choosing:
		print("play cards_up")
		EventBus.cards_move_animation_in_progress = true
		_animation_player_cards.play("cards_up")
		await _animation_player_cards.animation_finished
		EventBus.cards_move_animation_in_progress = false
		card_choosing = true

func _hide_cards():
	print("_hide_cards")
	if EventBus.card_select_animation_in_progress:
		return
	if card_choosing:
		print("play cards_down")
		EventBus.cards_move_animation_in_progress = true
		_animation_player_cards.play_backwards("cards_up")
		await _animation_player_cards.animation_finished
		EventBus.cards_move_animation_in_progress = false
		card_choosing = false

#func _on_AnimationPlayer_animation_finished(anim_name):
	#if anim_name == "_show_cards":
	#if anim_name == "_hide_cards":
		#card_choosing = false
	#
func _increase_nose():
	_nose.increase()

func _add_card_to_hand(player_id: int, base_card: Card):
	_cards_hands[player_id].add_card(base_card)

func _remove_card_from_hand(player_id: int, index: int):
	_cards_hands[player_id].remove_card(index)

func _select_card_in_hand(player_id: int, index: int):
	_cards_hands[player_id].select_card(index)

func _unselect_card_in_hand(player_id: int, index: int):
	_cards_hands[player_id].unselect_card(index)

func _add_card_to_checkable_line(base_card: Card):
	_checkable_cards_line.add_card(base_card)

func _remove_card_from_checkable_line(index: int):
	_checkable_cards_line.remove_card(index)

func _flip_card_in_checkable_line(index: int):
	_checkable_cards_line.flip_card(index)

func _add_token(player_id: int):
	_token_spawners[player_id].add_token()

func _add_several_tokens(player_id: int, num: int):
	_token_spawners[player_id].add_tokens(num)

func _remove_token(player_id: int):
	_token_spawners[player_id].remove_token()

func _add_card_to_stack(stack_type: CardsStack.Type):
	_get_stack(stack_type).add_card()

func _add_several_cards_to_stack(stack_type: CardsStack.Type, num: int):
	_get_stack(stack_type).add_cards(num)

func _remove_card_from_stack(stack_type: CardsStack.Type):
	_get_stack(stack_type).remove_card()

func _enemy_hand_up():
	if not _enemy_hand_raised:
		_enemy_hand_raised = true
		_enemy_hand_anim_player.play(enemy_hand_up_anim_name)

func _enemy_hand_down():
	if _enemy_hand_raised:
		_enemy_hand_raised = false
		_enemy_hand_anim_player.play(enemy_hand_down_anim_name)

func _get_stack(type: CardsStack.Type) -> CardsStack:
	match type:
		CardsStack.Type.NEW:
			return _new_cards_stack
		CardsStack.Type.DROPPED:
			return _dropped_cards_stack
		CardsStack.Type.NON_CHECKABLE:
			return _non_checkable_cards_stack
		CardsStack.Type.PLAYER_SCORE:
			return _player_score_cards_stack
		CardsStack.Type.ENEMY_SCORE:
			return _enemy_score_cards_stack
	return null
