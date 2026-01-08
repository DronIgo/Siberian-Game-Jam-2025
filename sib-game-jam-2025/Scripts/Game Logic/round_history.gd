class_name RoundHistory
extends Node2D

var history : Array
var first_turn : GameStateManager.PLAYER

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	history = []

func clear(c_p : GameStateManager.PLAYER) -> void:
	history.clear()
	first_turn = c_p
	
func update(turn_info : TurnHistory) -> void:
	history.append(turn_info)
	
func round_mark():
	for turn in history:
		if turn.action == EventBusAction.ACTION.SELECT_MARK:
			return turn.mark
	return null

func checks_left():
	var left : int = 1
	for turn in history:
		if turn.action == EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK:
			left += 1
		if turn.action == EventBusAction.ACTION.ADD_CARD_TO_CHECK:
			left -= 1
	return left

func flip_player(player : GameStateManager.PLAYER) -> GameStateManager.PLAYER:
	if player == GameStateManager.PLAYER.MAN:
		return GameStateManager.PLAYER.AI
	return GameStateManager.PLAYER.MAN

func current_player() -> GameStateManager.PLAYER:
	if history.size() > 0:
		var last_pl = history[-1].player
		match history[-1].action:
			EventBusAction.ACTION.ADD_CARDS:
				if round_mark():
					return flip_player(last_pl)
				else:
					return last_pl
			EventBusAction.ACTION.SELECT_MARK:
				return flip_player(last_pl)
			EventBusAction.ACTION.DECLARE_TRUST:
				return last_pl
			EventBusAction.ACTION.CALL_BLUFF:
				return last_pl
			EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK:
				return last_pl
			EventBusAction.ACTION.ADD_CARD_TO_CHECK:
				return last_pl
	return first_turn

func check_succesed(card : Card) -> bool:
	var exp_mark = round_mark()
	var real_mark = card.mark
	for turn in history:
		if turn.action == EventBusAction.ACTION.DECLARE_TRUST:
			return exp_mark == real_mark
		if turn.action == EventBusAction.ACTION.CALL_BLUFF:
			return exp_mark != real_mark
	return false

func get_round_result() -> Dictionary:
	var exp_mark = round_mark()
	var last_add_cards_num : int = 0
	var cards_checked : int = 0
	var called_bluff = false
	var correct_call = false
	
	for turn in history:
		if turn.action == EventBusAction.ACTION.ADD_CARDS:
			last_add_cards_num = turn.cards.size()
		if turn.action == EventBusAction.ACTION.CALL_BLUFF:
			called_bluff = true
		if turn.action == EventBusAction.ACTION.ADD_CARD_TO_CHECK:
			cards_checked += 1
			if turn.cards[0].mark == exp_mark:
				if !called_bluff:
					correct_call = true
					break
			else:
				if called_bluff:
					correct_call = true
					break
	var checked_all = last_add_cards_num == cards_checked
	
	var result_action : EventBusGL.END_ROUND_RESULT
	if current_player() == GameStateManager.PLAYER.MAN:
		if check_succesed:
			if called_bluff:
				result_action = EventBusGL.END_ROUND_RESULT.ENEMY_TAKES_CARDS
			else:
				result_action =  EventBusGL.END_ROUND_RESULT.CARDS_ARE_DISCARED
		else:
			result_action =  EventBusGL.END_ROUND_RESULT.PLAYER_TAKES_CARDS
	else:
		if check_succesed:
			if called_bluff:
				result_action =  EventBusGL.END_ROUND_RESULT.PLAYER_TAKES_CARDS
			else:
				result_action =  EventBusGL.END_ROUND_RESULT.CARDS_ARE_DISCARED
		else:
			result_action = EventBusGL.END_ROUND_RESULT.ENEMY_TAKES_CARDS

	return {"called_bluff" : called_bluff, \
	"correct_call" : correct_call, \
	"checked_all" : checked_all, \
	"result_action" : result_action }
