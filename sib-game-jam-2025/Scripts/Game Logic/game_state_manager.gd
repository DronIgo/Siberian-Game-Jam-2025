class_name GameStateManager

extends Node
@onready var game_manager: GameManager = $"../GameManager"
@onready var card_manager: CardManager = $"../CardManager"

enum PLAYER {
	MAN,
	AI
}

const EFFECT_DIALOG = preload("res://Scenes/Effects/EffectDialog.tscn")
const ROUND_HISTORY = preload("res://Scenes/Game Logic/RoundHistory.tscn")

var player_avialable_actions : Array
var current_player : PLAYER = PLAYER.MAN
var current_player_round : PLAYER = PLAYER.MAN
var round_mark : Card.CARD_MARK = Card.CARD_MARK.SKULL
var round_mark_set : bool = false

var round_history : RoundHistory

func _ready() -> void:
	EventBusAction.send_action.connect(recieve_action)
	EventBusGL.start_round.connect(card_manager.fill_hands)
	EventBusGL.start_round.connect(start_round)
	#TODO: delete
	PhaseManager.init()
	#PhaseNames.used_dialogs.clear()

	round_history = ROUND_HISTORY.instantiate()
	add_child(round_history)
	round_history.clear(current_player)
	
func switch_player_round() -> void:
	if current_player_round == PLAYER.MAN:
		current_player_round = PLAYER.AI
	else:
		current_player_round = PLAYER.MAN

func switch_player_turn() -> void:
	if current_player == PLAYER.MAN:
		current_player = PLAYER.AI
	else:
		current_player = PLAYER.MAN

func call_basilio_signals(round_result : Dictionary):
	var correct_call = round_result["correct_call"]
	var called_bluff = round_result["called_bluff"]
	var checked_all = round_result["checked_all"]
	if !correct_call:
		if !called_bluff:
			EventBusAction.basilio_mistrusted.emit()
		else: 
			EventBusAction.basilio_miscalled.emit()
			if checked_all:
				EventBusAction.basilio_miscalled_and_learns.emit()

var learned = false
var dialog_id : String
func check_dialog(round_result : Dictionary) -> bool:
	dialog_id = ""
	var correct_call = round_result["correct_call"]
	var called_bluff = round_result["called_bluff"]
	var checked_all = round_result["checked_all"]
	if round_history.current_player() == PLAYER.AI:
		if correct_call && !called_bluff:
			dialog_id = PhaseNames.dialog_correct_trust_1
		if correct_call && called_bluff:
			var rand = randi_range(0, 3)
			if rand == 0:
				dialog_id = PhaseNames.dialog_id_correct_bluff_1
			if rand == 1:
				dialog_id = PhaseNames.dialog_id_correct_bluff_2
			if rand == 2:
				dialog_id = PhaseNames.dialog_id_correct_bluff_3
		if !learned:
			if !correct_call && !called_bluff:
				dialog_id = PhaseNames.dialog_basilio_learns_trust
			if !correct_call && called_bluff && checked_all:
				dialog_id = PhaseNames.dialog_basilio_learns_bluff
			learned = true
	else:
		return false
	if dialog_id != "":
		return true
	return false

func end_round() -> void:
	var result = round_history.get_round_result()
	
	if round_history.current_player() == PLAYER.AI:
		call_basilio_signals(result)
		
	await Utils.wait(1.0)
	if check_dialog(result):
		var dialog_effect = EFFECT_DIALOG.instantiate()
		add_child(dialog_effect)
		dialog_effect.start(dialog_id)
	print("ROUND ENDED")
	EventBusAction.progress_game_delayed.emit()
	EventBusGL.end_round_delayed.emit(result["result_action"])
	EventBusGL.update_visualisation_delayed.emit()
	switch_player_round()
	EventBusGL.start_round_delayed.emit()
	
func start_round() -> void:
	EventBus.sit_back_at_table.emit()
	round_mark = Card.CARD_MARK.SKULL
	round_mark_set = false
	if card_manager.hand_player.size() == 0 && \
	card_manager.hand_enemy.size() == 0:
		end_game()
		return
	if card_manager.hand_player.size() == 0:
		current_player_round = PLAYER.AI
	if card_manager.hand_enemy.size() == 0:
		current_player_round = PLAYER.MAN
	round_history.clear(current_player_round)
	current_player = current_player_round
	player_avialable_actions.clear()
	player_avialable_actions.append(EventBusAction.ACTION.ADD_CARDS)
	EventBusAction.progress_game_delayed.emit()
	EventBusGL.update_visualisation_delayed.emit()

func end_game() -> void:
	#самый быстрый способ это сделать
	var first_game = PhaseManager.current_phase().id == "game_1"
	var player_won = game_manager.player_score < game_manager.enemy_score
	if first_game || player_won:
		var next_phase = PhaseManager.try_next_phase()
		if next_phase != null:
			get_tree().change_scene_to_file(next_phase.scene_name)
	else:
		var dialog = PhaseManager.start_event("game_2_failure")
		var scene = load(dialog.scene_name)
		var scene_instance = scene.instantiate()
		add_child(scene_instance)
		await EventBus.dialog_finished
		get_tree().reload_current_scene()

func can_increase_card_check() -> bool:
	var num_bonus : int
	if current_player == PLAYER.MAN:
		num_bonus = game_manager.player_bonus
	else:
		num_bonus = game_manager.enemy_bonus
	if num_bonus < game_manager.extra_check_cost:
		return false
	if card_manager.get_last_addition().size() <= round_history.checks_left():
		return false
	return true

func can_active_player_add_cards() -> bool:
	if current_player == PLAYER.MAN:
		return card_manager.get_player_hand().size() > 0
	else:
		return card_manager.get_enemy_hand().size() > 0

func recieve_action(action : EventBusAction.ACTION, data) -> void:
	player_avialable_actions.clear()
	var should_end_round = false
	#lmao
	print(PLAYER.keys()[current_player],\
	" does ",\
	EventBusAction.ACTION.keys()[action])
	EventBusAction.print_action.emit(PLAYER.keys()[current_player] + \
	" does " + \
	EventBusAction.ACTION.keys()[action])
	var turn_info : TurnHistory = TurnHistory.new()
	turn_info.action = action
	turn_info.player = round_history.current_player()
	match action:
		EventBusAction.ACTION.ADD_CARDS:
			turn_info.cards = data
			round_history.update(turn_info)
			if round_history.round_mark() is Card.CARD_MARK:
				switch_player_turn()
				player_avialable_actions.append(EventBusAction.ACTION.DECLARE_TRUST)
				player_avialable_actions.append(EventBusAction.ACTION.CALL_BLUFF)
				if can_active_player_add_cards():
					player_avialable_actions.append(EventBusAction.ACTION.ADD_CARDS)
			else:
				player_avialable_actions.append(EventBusAction.ACTION.SELECT_MARK)
		EventBusAction.ACTION.SELECT_MARK:
			round_mark = data as Card.CARD_MARK
			round_mark_set = true
			switch_player_turn()
			if round_mark == Card.CARD_MARK.SKULL:
				print("GameStateManager: set skull as main mark!")
				round_mark = Card.CARD_MARK.ALPHABET
			turn_info.mark = round_mark
			round_history.update(turn_info)
			player_avialable_actions.append(EventBusAction.ACTION.DECLARE_TRUST)
			player_avialable_actions.append(EventBusAction.ACTION.CALL_BLUFF)
			player_avialable_actions.append(EventBusAction.ACTION.ADD_CARDS)
		EventBusAction.ACTION.CALL_BLUFF:
			round_history.update(turn_info)
			if can_increase_card_check():
				player_avialable_actions.append(EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK)
			player_avialable_actions.append(EventBusAction.ACTION.ADD_CARD_TO_CHECK)
		#can't increase num of checked cards, when we believe
		EventBusAction.ACTION.DECLARE_TRUST:
			round_history.update(turn_info)
			player_avialable_actions.append(EventBusAction.ACTION.ADD_CARD_TO_CHECK)
		EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK:
			round_history.update(turn_info)
			if can_increase_card_check():
				player_avialable_actions.append(EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK)
			player_avialable_actions.append(EventBusAction.ACTION.ADD_CARD_TO_CHECK)
		EventBusAction.ACTION.ADD_CARD_TO_CHECK:
			turn_info.cards = [data as Card]
			round_history.update(turn_info)
			if round_history.check_succesed(data as Card):
				should_end_round = true
			if round_history.checks_left() == 0:
				should_end_round = true
			if !should_end_round:
				player_avialable_actions.append(EventBusAction.ACTION.ADD_CARD_TO_CHECK)
	if should_end_round:
		end_round()
	else:
		EventBusGL.update_visualisation_delayed.emit()
		EventBusAction.progress_game_delayed.emit()
