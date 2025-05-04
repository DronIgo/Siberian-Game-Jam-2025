class_name BasilioBasic
extends Node

var card_manager : CardManager
var game_manager : GameManager
var game_state_manager : GameStateManager
var enemy_ai : EnemyAI
var player_lied_last_turn : bool = false

@export var knows_buratino_cant_lie : int = true
@export var big_enough_stack : int = 6
@export_range(1, 5, 1) var risk_koef : float = 2.0
@export var start_risk_mod : float = -1.5
@export var risk_step : float = 1.0

var selected_color : Card.CARD_COLOR = Card.CARD_COLOR.RED
var num_colors : Dictionary
var generated_card_turns : bool = false

func init(cm : CardManager, gm : GameManager, gsm : GameStateManager, eai : EnemyAI) -> void:
	card_manager = cm
	game_manager = gm
	game_state_manager = gsm
	enemy_ai = eai

func take_turn() -> void:
	#здесь быть не должно, но без этого не работает :D
	if game_state_manager.current_player != GameStateManager.PLAYER.AI:
		return
	var actions = game_state_manager.player_avialable_actions
	var first_turn = !game_state_manager.color_selected
	
	if !generated_card_turns:
		if first_turn:	
			select_color()
		else:
			selected_color = game_state_manager.current_correct_color
		setup_turns()
		
	var can_select_color = actions.has(EventBusAction.PLAYER_ACTION.SELECT_COLOR)
	var can_add_cards_to_check = \
	actions.has(EventBusAction.PLAYER_ACTION.ADD_CARD_TO_CHECK)
	#already picking card checks
	if can_add_cards_to_check:
		if try_add_extra_checks():
			return
		else:
			enemy_ai.pick_random_check_card()
			return
	
	#picked the hand in a privious turn and now declare the color
	if can_select_color:
		enemy_ai.send_color(selected_color)
		return

	var can_add = actions.has(EventBusAction.PLAYER_ACTION.ADD_CARDS)
	var can_check = actions.has(EventBusAction.PLAYER_ACTION.DECLARE_TRUST)
	
	#runned out of cards, need to check opponent
	if can_check && !can_add:
		if !player_lied_last_turn:
			enemy_ai.check_cards(true)
			return
		else:
			enemy_ai.check_cards(false)
			return

	if can_add:
		#should check
		if cards_for_turns.is_empty():
			if !player_lied_last_turn:
				enemy_ai.check_cards(true)
				return
			else:
				enemy_ai.check_cards(false)
				return
		else:
			select_cards(cards_for_turns.pop_front())
			enemy_ai.place_cards()
			return

	
func can_lose_this_turn() -> bool:
	var lose_threshold = card_manager.deck_total_score / 2
	if (card_manager.stack.size() + card_manager.last_add.size() +\
	game_manager.enemy_score) > lose_threshold:
		return true
	return false
	
func try_add_extra_checks() -> bool:
	var actions = game_state_manager.player_avialable_actions
	var can_add_extra_checks = \
	actions.has(EventBusAction.PLAYER_ACTION.ADD_EXTRA_CARD_CHECK)
	if !can_add_extra_checks:
		return false
	if can_lose_this_turn():
		enemy_ai.add_extra_check()
		return true
	if card_manager.stack.size() + card_manager.last_add.size() > big_enough_stack:
		enemy_ai.add_extra_check()
		return true
	return false

func update_color_nums(hand : Array) -> void:
	num_colors.clear()
	for c in hand:
		var card = c as Card
		if !num_colors.has(card.color):
			num_colors.get_or_add(card.color, 1)
		else:
			num_colors[card.color] += 1

func roll_risk(mod : float) -> bool:
	var rand = randf_range(0.0, 6.0)
	return (risk_koef > rand + mod)

var cards_for_turns : Array = []

#sets up 2-3 turns where mainly the selected color is used
func setup_turns() -> void:
	generated_card_turns = true
	cards_for_turns.clear()
	var all_used_cards = []
	var risk_mod : float = start_risk_mod
	for card in card_manager.get_enemy_hand():
		if card.color == selected_color:
			all_used_cards.append(card)
		elif card.color == Card.CARD_COLOR.GREY:
			if roll_risk(risk_mod):
				risk_mod += risk_step
				all_used_cards.append(card)
		else:
			if roll_risk(risk_mod + 2.0):
				risk_mod += risk_step
				all_used_cards.append(card)
	var all_size = all_used_cards.size()
	if all_size <= 2:
		cards_for_turns.append(all_used_cards)
		return
	if all_size <= 4:
		var end_first = randi_range(0, all_size - 2)
		cards_for_turns.append(all_used_cards.slice(0, end_first))
		cards_for_turns.append(all_used_cards.slice(end_first, all_size))
		return
	var end_first = randi_range(0, 2)
	var end_second = randi_range(end_first + 1, all_size - 2)
	cards_for_turns.append(all_used_cards.slice(0, end_first))
	cards_for_turns.append(all_used_cards.slice(end_first, end_second))
	cards_for_turns.append(all_used_cards.slice(end_second, all_size))
	
func select_color() -> void:
	update_color_nums(card_manager.get_enemy_hand())
	selected_color = Card.CARD_COLOR.RED
	var max = 0
	for color in num_colors.keys():
		if num_colors[color] > max:
			max = num_colors[color]
			selected_color = color

func select_cards(cards : Array) -> void:
	if cards.size() > 3:
		for card in cards.slice(0, 3):
			card_manager.select_card(card)
		return
	for card in cards:
		card_manager.select_card(card)
