class_name BasilioBasic
extends Node

var card_manager : CardManager
var game_manager : GameManager
var game_state_manager : GameStateManager
var enemy_ai : EnemyAI

@export var knows_buratino_cant_lie = true

var selected_color : Card.CARD_COLOR = Card.CARD_COLOR.RED
var num_colors : Dictionary

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
	
	var can_add_cards_to_check = \
	actions.count(EventBusAction.PLAYER_ACTION.ADD_CARD_TO_CHECK) > 0
	
	if can_add_cards_to_check:
		enemy_ai.pick_check_card()
		enemy_ai.next_think_time = enemy_ai.think_time
		return
	var can_add = actions.count(EventBusAction.PLAYER_ACTION.ADD_CARDS) > 0
	var can_trust = actions.count(EventBusAction.PLAYER_ACTION.DECLARE_TRUST) > 0
	var can_call_bluff = actions.count(EventBusAction.PLAYER_ACTION.CALL_BLUFF) > 0
	var can_select_color = actions.count(EventBusAction.PLAYER_ACTION.SELECT_COLOR) > 0
	if can_select_color:
		enemy_ai.send_color(selected_color)
		enemy_ai.next_think_time = enemy_ai.think_time
		return
	if first_turn && can_add:
		place_first_cards(card_manager.get_enemy_hand())
		enemy_ai.next_think_time = enemy_ai.think_time_quick
		return
	if can_add:
		if select_extra_cards(card_manager.get_enemy_hand(), \
		game_state_manager.current_correct_color):
			enemy_ai.place_cards()
			enemy_ai.next_think_time = enemy_ai.think_time
			return
	if can_call_bluff:
		enemy_ai.check_cards(false)
		enemy_ai.next_think_time = enemy_ai.think_time_quick
		return
	if can_trust:
		enemy_ai.check_cards(true)
		enemy_ai.next_think_time = enemy_ai.think_time_quick
		return
	

func update_color_nums(hand : Array) -> void:
	num_colors.clear()
	for c in hand:
		var card = c as Card
		if !num_colors.has(card.color):
			num_colors.get_or_add(card.color, 1)
		else:
			num_colors[card.color] += 1


func select_color() -> void:
	update_color_nums(card_manager.get_enemy_hand())
	selected_color = Card.CARD_COLOR.RED
	var max = 0
	for color in num_colors.keys():
		if num_colors[color] > max:
			max = num_colors[color]
			selected_color = color


func place_first_cards(hand : Array) -> void:
	select_color()
	select_first_cards(card_manager.get_enemy_hand(), selected_color)
	enemy_ai.place_cards()

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
