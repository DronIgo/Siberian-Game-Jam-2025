class_name EnemyAI
extends Node

const BASILIO_BASIC_AI = preload("res://Scenes/Game Logic/EnemyAI/BasilioBasicAI.tscn")

@onready var checkable_cards_line: CardsLine = $"../CheckableCardsLine"

@onready var card_manager: CardManager = $"../CardManager"
@onready var game_state_manager: GameStateManager = $"../GameStateManager"
@onready var game_manager: GameManager = $"../GameManager"

const EFFECT_VOICE = preload("res://Scenes/Effects/EffectVoice.tscn")

@export_category("Displayed params")
@export var think_time : float = 3.0
@export var think_time_quick : float = 1.0

var next_think_time : float
var currentAI

func _ready() -> void:
	EventBusAction.progress_game.connect(start_turn)
	next_think_time = think_time
	currentAI = BASILIO_BASIC_AI.instantiate()
	add_child(currentAI)
	currentAI.init(card_manager, game_manager, game_state_manager, self as EnemyAI)
	EventBusGL.end_round.connect(end_round)
	EventBusAction.player_lied.connect(detect_lie)
	EventBusAction.player_told_truth.connect(detect_truth)
	
	EventBusAction.basilio_miscalled.connect(miscalled)
	EventBusAction.basilio_miscalled.connect(mistrusted)
	EventBusAction.basilio_miscalled.connect(learned)
	
func end_round(res : EventBusGL.END_ROUND_RESULT) -> void:
	checked_cards_idx.clear()
	currentAI.generated_card_turns = false

func miscalled() -> void:
	currentAI.incr_trust()
	print("miscalled")
func mistrusted() -> void:
	currentAI.decr_trust()
	currentAI.learn()
	print("mistrust")
func learned() -> void:
	print("learn")
	currentAI.learn()
func detect_lie() -> void:
	currentAI._player_lied_last_turn = true
func detect_truth() -> void:
	currentAI._player_lied_last_turn = false
	
func start_turn() -> void:
	if game_state_manager.current_player == GameStateManager.PLAYER.AI &&\
	game_state_manager.player_avialable_actions.size() > 0:
		await Utils.wait(next_think_time)
		currentAI.take_turn()

func send_mark(mark : Card.CARD_MARK) -> void:
	EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.SELECT_MARK, mark)

func place_cards() -> void:
	card_manager.place_cards(false)
	var voice = EFFECT_VOICE.instantiate()
	add_child(voice)
	voice.start("Add")
	EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.ADD_CARDS, null)

func check_cards(trust : bool) -> void:
	EventBus.bend_over_table.emit()
	if trust:
		var voice = EFFECT_VOICE.instantiate()
		add_child(voice)
		voice.start("Trust")
		EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.DECLARE_TRUST, null)
	else:
		var voice = EFFECT_VOICE.instantiate()
		add_child(voice)
		voice.start("Call_Bluff")
		EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.CALL_BLUFF, null)

func add_extra_check() -> void:
	var voice = EFFECT_VOICE.instantiate()
	add_child(voice)
	voice.start("Buy")
	game_manager.enemy_bonus -= game_manager.extra_check_cost
	for i in game_manager.extra_check_cost:
		EventBus.token_remove.emit(MagicNumbers.ENEMY_ID)
	EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK, null)

var checked_cards_idx : Array

func pick_random_check_card() -> void:
	#only here to support the demo scene
	if !checkable_cards_line:
		var truth = CardUtils.check_random(card_manager.get_last_addition(), \
		game_state_manager.round_mark)
		EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.ADD_CARD_TO_CHECK, truth)
		return 

	var rand_card : Card3D
	var num_cards = checkable_cards_line._current_cards.size()
	var rand_idx = randi_range(0, num_cards - 1)
	while checked_cards_idx.count(rand_idx) > 0:
		rand_idx = randi_range(0, num_cards - 1)
	rand_card = checkable_cards_line._current_cards[rand_idx]
	checked_cards_idx.append(rand_idx)
	rand_card.flip()
	await Utils.wait(2.0)
	var truth = rand_card.base_card.mark == game_state_manager.round_mark
	EventBusAction.send_action_delayed.emit(EventBusAction.ACTION.ADD_CARD_TO_CHECK, truth)
