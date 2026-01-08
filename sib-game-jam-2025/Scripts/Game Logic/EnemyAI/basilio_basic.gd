class_name BasilioBasic
extends Node

var _card_manager : CardManager
var _game_manager : GameManager
var _game_state_manager : GameStateManager
var _enemy_ai : EnemyAI
var _player_lied_last_turn : bool = false

@export var knows_buratino_cant_lie : bool = true
@export var big_enough_stack : int = 6
@export_range(1, 5, 1) var risk_koef : float = 2.0
@export var start_risk_mod : float = -1.5
@export var risk_step : float = 1.0
@export var trust_treshold : int = 10
@export var trust_step : int = 2

func incr_trust():
	trust_treshold += trust_step
func decr_trust():
	trust_treshold -= trust_step
func learn():
	knows_buratino_cant_lie = false

var selected_mark : Card.CARD_MARK = Card.CARD_MARK.KEY
var num_cards_by_mark : Dictionary = {}
var generated_card_turns : bool = false

func init(cm : CardManager, gm : GameManager, gsm : GameStateManager, eai : EnemyAI) -> void:
	_card_manager = cm
	_game_manager = gm
	_game_state_manager = gsm
	_enemy_ai = eai

func take_turn() -> void:
	#здесь быть не должно, но без этого не работает :D
	if _game_state_manager.current_player != GameStateManager.PLAYER.AI:
		return
	var actions = _game_state_manager.player_avialable_actions
	var first_turn = !_game_state_manager.round_mark_set
	
	if !generated_card_turns:
		if first_turn:
			select_mark()
		else:
			selected_mark = _game_state_manager.round_mark
		setup_turns(selected_mark)
		
	var can_select_mark = actions.has(EventBusAction.ACTION.SELECT_MARK)
	var can_add_cards_to_check = \
	actions.has(EventBusAction.ACTION.ADD_CARD_TO_CHECK)
	#already picking card checks
	if can_add_cards_to_check:
		if try_add_extra_checks():
			return
		else:
			_enemy_ai.pick_random_check_card()
			return
	
	#picked the hand in a privious turn and now declare the mark
	if can_select_mark:
		_enemy_ai.send_mark(selected_mark)
		return

	var can_add = actions.has(EventBusAction.ACTION.ADD_CARDS)
	var can_check = actions.has(EventBusAction.ACTION.DECLARE_TRUST)
	
	#runned out of cards, need to check opponent
	if can_check && !can_add:
		if knows_buratino_cant_lie:
			if !_player_lied_last_turn:
				_enemy_ai.check_cards(true)
				return
			else:
				_enemy_ai.check_cards(false)
				return
		else:
			if calc_trust():
				_enemy_ai.check_cards(true)
				return
			else:
				_enemy_ai.check_cards(false)
				return
			
	if can_add:
		#should check
		if cards_for_turns.is_empty():
			if knows_buratino_cant_lie:
				if !_player_lied_last_turn:
					_enemy_ai.check_cards(true)
					return
				else:
					_enemy_ai.check_cards(false)
					return
			else:
				if calc_trust():
					_enemy_ai.check_cards(true)
					return
				else:
					_enemy_ai.check_cards(false)
					return
		else:
			if can_lose_this_turn():
				select_cards(cards_for_turns.pop_front())
				cards_for_risky_turns.pop_front()
			else:
				var num : float
				num = get_cards_in_stack_num()
				if pure_risk_turns.size() > 0 && roll_risk(num / 5.0 + 1.5):
					select_cards(pure_risk_turns.pop_front())
				elif roll_risk(num / 4.0):
					cards_for_turns.pop_front()
					select_cards(cards_for_risky_turns.pop_front())
				else:
					select_cards(cards_for_turns.pop_front())
					cards_for_risky_turns.pop_front()
			_enemy_ai.place_cards()
			return

func get_cards_in_stack_num() -> int:
	return _card_manager.stack.size() + _card_manager.last_add.size()
	
func can_lose_this_turn() -> bool:
	var lose_threshold = _card_manager.deck_total_score / 2
	if (get_cards_in_stack_num() +\
	_game_manager.enemy_score) > lose_threshold:
		return true
	return false
	
func try_add_extra_checks() -> bool:
	var actions = _game_state_manager.player_avialable_actions
	var can_add_extra_checks = \
	actions.has(EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK)
	if !can_add_extra_checks:
		return false
	if can_lose_this_turn():
		_enemy_ai.add_extra_check()
		return true
	if _card_manager.stack.size() + _card_manager.last_add.size() > big_enough_stack:
		_enemy_ai.add_extra_check()
		return true
	return false

func update_mark_nums(hand : Array) -> void:
	num_cards_by_mark.clear()
	for c in hand:
		var card = c as Card
		if !num_cards_by_mark.has(card.mark):
			num_cards_by_mark[card.mark] = 1
		else:
			num_cards_by_mark[card.mark] += 1

func roll_risk(mod : float) -> bool:
	var rand = randf_range(0.0, 6.0)
	return (risk_koef > rand + mod)

var cards_for_turns : Array = []
var cards_for_risky_turns : Array = []
var pure_risk_turns : Array = []

#sets up 2-3 turns where mainly the selected mark is used
func setup_turns(mark : Card.CARD_MARK) -> void:
	generated_card_turns = true
	cards_for_turns.clear()
	cards_for_risky_turns.clear()
	pure_risk_turns.clear()
	var safe_cards = []
	var risky_cards = []
	if mark == Card.CARD_MARK.SKULL:
		print("SKULL as main mark!")
	for card in _card_manager.get_enemy_hand():
		if card.mark == mark:
			safe_cards.append(card)
		else:
			risky_cards.append(card)
	split_into_turns(safe_cards)
	var risk_mod : float = start_risk_mod
	for cards in cards_for_turns:
		var turn = []
		turn.append_array(cards)
		cards_for_risky_turns.append(turn)
		if cards.size() == 3:
			risk_mod += risk_step
		else:
			for i in range(0, 2 - cards.size()):
				if roll_risk(risk_mod) && risky_cards.size() > 0:
					cards_for_risky_turns.back().append(risky_cards.pop_back())
					risk_mod += risk_step
			risk_mod += risk_step
	while risky_cards.size() > 0:
		var amount = randi_range(1, min(risky_cards.size(), 3))
		var turn = []
		for i in range(0, amount):
			turn.append(risky_cards.pop_back())
		pure_risk_turns.append(turn)
	print(Card.CARD_MARK.keys()[mark])
	for c in cards_for_turns:
		print("Safe turn")
		for card in c:
			(card as Card).debug_print()
	for c in cards_for_risky_turns:
		print("Risky turn")
		for card in c:
			(card as Card).debug_print()
	for c in pure_risk_turns:
		print("Extra risky turn")
		for card in c:
			(card as Card).debug_print()

func split_into_turns(all_used_cards : Array) -> void:
	var all_size = all_used_cards.size()
	print("All_size ", all_size)
	if all_size == 0:
		return
	if all_size == 1:
		cards_for_turns.append(all_used_cards)
		return
	if all_size < 4:
		var end_first = randi_range(1, all_size - 1)
		cards_for_turns.append(all_used_cards.slice(0, end_first))
		cards_for_turns.append(all_used_cards.slice(end_first, all_size))
		return
	var start_prev = 0
	var end_prev = randi_range(1, min(all_size - 3, 2))
	while end_prev < all_size - 2:
		cards_for_turns.append(all_used_cards.slice(start_prev, end_prev))
		start_prev = end_prev
		end_prev = randi_range(start_prev + 1, min(all_size - 2, start_prev + 3))
	cards_for_turns.append(all_used_cards.slice(end_prev, all_size))

func calc_trust() -> bool:
	var trust_level : int = 10
	if _game_state_manager.current_player_round == GameStateManager.PLAYER.MAN:
		trust_level += 5
	trust_level -= get_cards_in_stack_num()
	trust_level -= randi_range(0, 3)
	return trust_level > trust_treshold

func select_mark() -> void:
	update_mark_nums(_card_manager.get_enemy_hand())
	selected_mark = Card.CARD_MARK.KEY
	var max = 0
	for mark in num_cards_by_mark.keys():
		if num_cards_by_mark[mark] > max && mark != Card.CARD_MARK.SKULL:
			max = num_cards_by_mark[mark]
			selected_mark = mark

func select_cards(cards : Array) -> void:
	if cards.size() > 3:
		for card in cards.slice(0, 3):
			_card_manager.select_card(card)
		return
	for card in cards:
		_card_manager.select_card(card)
