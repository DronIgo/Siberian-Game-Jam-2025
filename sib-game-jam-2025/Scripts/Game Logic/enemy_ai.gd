class_name EnemyAI
extends Node

const BASILIO_BASIC_AI = preload("res://Scenes/Game Logic/EnemyAI/BasilioBasicAI.tscn")

@onready var checkable_cards_line: CardsLine = $"../CheckableCardsLine"

@onready var card_manager: CardManager = $"../CardManager"
@onready var game_state_manager: GameStateManager = $"../GameStateManager"
@onready var game_manager: GameManager = $"../GameManager"

const EFFECT_TIMER = preload("res://Scenes/Effects/EffectTimer.tscn")

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
	currentAI.player_lied_last_turn = true
func detect_truth() -> void:
	currentAI.player_lied_last_turn = false
	
func start_turn() -> void:
	if game_state_manager.current_player == GameStateManager.PLAYER.AI &&\
	game_state_manager.player_avialable_actions.size() > 0:
		var timer = EFFECT_TIMER.instantiate()
		add_child(timer)
		timer.start(next_think_time)
		await EventBusAction.effect_end
		currentAI.take_turn()

func send_color(color : Card.CARD_COLOR) -> void:
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.SELECT_COLOR, color)

func place_cards() -> void:
	card_manager.place_cards(false)
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_CARDS, null)

func check_cards(trust : bool) -> void:
	EventBus.bend_over_table.emit()
	if trust:
		EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.DECLARE_TRUST, null)
	else:
		EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.CALL_BLUFF, null)

func add_extra_check() -> void:
	game_manager.enemy_bonus -= game_manager.extra_check_cost
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_EXTRA_CARD_CHECK, null)

var checked_cards_idx : Array

func pick_random_check_card() -> void:
	if !checkable_cards_line:
		var truth = CardUtils.check_random(card_manager.get_last_addition(), \
		game_state_manager.current_correct_color)
		EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_CARD_TO_CHECK, truth)
		return 

	var rand_card : Card3D
	var num_cards = checkable_cards_line._current_cards.size()
	var rand_idx = randi_range(0, num_cards - 1)
	while checked_cards_idx.count(rand_idx) > 0:
		rand_idx = randi_range(0, num_cards - 1)
	rand_card = checkable_cards_line._current_cards[rand_idx]
	checked_cards_idx.append(rand_idx)
	rand_card.flip()
	var timer = EFFECT_TIMER.instantiate()
	add_child(timer)
	timer.start(2.0)
	await EventBusAction.effect_end
	var truth = rand_card.base_card.color == game_state_manager.current_correct_color
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_CARD_TO_CHECK, truth)
