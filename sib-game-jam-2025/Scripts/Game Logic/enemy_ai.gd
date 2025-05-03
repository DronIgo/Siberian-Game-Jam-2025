class_name EnemyAI
extends Node

const BasilioBasic = preload("res://Scenes/Game Logic/EnemyAI/basilio_basic.gd")

@onready var checkable_cards_line: CardsLine = $"../CheckableCardsLine"

@onready var card_manager: CardManager = $"../CardManager"
@onready var game_state_manager: GameStateManager = $"../GameStateManager"
const EFFECT_TIMER = preload("res://Scenes/Effects/EffectTimer.tscn")

@export_category("Displayed params")
@export var think_time : float = 3.0
@export var think_time_quick : float = 1.0

var next_think_time : float
var currentAI

var selected_color : Card.CARD_COLOR = Card.CARD_COLOR.RED
var num_colors : Dictionary

func _ready() -> void:
	EventBusAction.progress_game.connect(start_turn)
	next_think_time = think_time
	currentAI = BasilioBasic.new()

func update_color_nums(hand : Array) -> void:
	num_colors.clear()
	for c in hand:
		var card = c as Card
		if !num_colors.has(card.color):
			num_colors.get_or_add(card.color, 1)
		else:
			num_colors[card.color] += 1

func take_turn() -> void:
	#здесь быть не должно, но без этого не работает :D
	if game_state_manager.current_player != GameStateManager.PLAYER.AI:
		return
	var actions = game_state_manager.player_avialable_actions
	
	var first_turn = !game_state_manager.color_selected
	
	var can_add_cards_to_check = \
	actions.count(EventBusAction.PLAYER_ACTION.ADD_CARD_TO_CHECK) > 0
	
	if can_add_cards_to_check:
		pick_check_card()
		next_think_time = think_time
		return
	var can_add = actions.count(EventBusAction.PLAYER_ACTION.ADD_CARDS) > 0
	var can_trust = actions.count(EventBusAction.PLAYER_ACTION.DECLARE_TRUST) > 0
	var can_call_bluff = actions.count(EventBusAction.PLAYER_ACTION.CALL_BLUFF) > 0
	var can_select_color = actions.count(EventBusAction.PLAYER_ACTION.SELECT_COLOR) > 0
	if can_select_color:
		send_color()
		next_think_time = think_time
		return
	if first_turn && can_add:
		place_first_cards(card_manager.get_enemy_hand())
		next_think_time = think_time_quick
		return
	if can_add:
		if select_extra_cards(card_manager.get_enemy_hand(), \
		game_state_manager.current_correct_color):
			place_cards()
			next_think_time = think_time
			return
	if can_call_bluff:
		check_cards(false)
		next_think_time = think_time_quick
		return
	if can_trust:
		check_cards(true)
		next_think_time = think_time_quick
		return
			
	
func start_turn() -> void:
	if game_state_manager.current_player == GameStateManager.PLAYER.AI:
		var timer = EFFECT_TIMER.instantiate()
		add_child(timer)
		timer.start(next_think_time)
		await EventBusAction.effect_end
		take_turn()

func select_extra_cards(hand : Array, color : Card.CARD_COLOR) -> bool:
	for c in hand:
		var card = c as Card
		if card.color == color:
			card_manager.select_card(card)
	return card_manager.is_selected_correct()

func select_first_cards(hand : Array, color : Card.CARD_COLOR) -> void:
	for c in hand:
		var card = c as Card
		if card.color == color:
			card_manager.select_card(card)
	if !card_manager.is_selected_correct():
		card_manager.select_card(hand[0])

func select_color() -> void:
	update_color_nums(card_manager.get_enemy_hand())
	selected_color = Card.CARD_COLOR.RED
	var max = 0
	for color in num_colors.keys():
		if num_colors[color] > max:
			max = num_colors[color]
			selected_color = color

func send_color() -> void:
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.SELECT_COLOR, selected_color)

func place_cards() -> void:
	card_manager.place_cards(false)
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_CARDS, null)

func place_first_cards(hand : Array) -> void:
	select_color()
	select_first_cards(card_manager.get_enemy_hand(), selected_color)
	place_cards()

func check_cards(trust : bool) -> void:
	EventBus.bend_over_table.emit()
	if trust:
		EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.DECLARE_TRUST, null)
	else:
		EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.CALL_BLUFF, null)

func pick_check_card() -> void:
	if !checkable_cards_line:
		var truth = CardUtils.check_random(card_manager.get_last_addition(), \
		game_state_manager.current_correct_color)
		EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_CARD_TO_CHECK, truth)
	var rand_card : Card3D
	var num_cards = checkable_cards_line._current_cards.size()
	rand_card = checkable_cards_line._current_cards[randi_range(0, num_cards - 1)]
	rand_card.flip()
	var timer = EFFECT_TIMER.instantiate()
	add_child(timer)
	timer.start(2.0)
	await EventBusAction.effect_end
	var truth = rand_card.base_card.color == game_state_manager.current_correct_color
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.ADD_CARD_TO_CHECK, truth)
