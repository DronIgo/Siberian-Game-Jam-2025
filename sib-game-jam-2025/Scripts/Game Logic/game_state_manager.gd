class_name GameStateManager

extends Node
@onready var game_manager: GameManager = $"../GameManager"
@onready var card_manager: CardManager = $"../CardManager"

enum PLAYER {
	MAN,
	AI
}

const EFFECT_DIALOG = preload("res://Scenes/Effects/EffectDialog.tscn")

var player_avialable_actions : Array
var current_player : PLAYER = PLAYER.MAN
var current_player_round : PLAYER = PLAYER.MAN
var round_mark : Card.CARD_MARK = Card.CARD_MARK.SKULL
var round_mark_set : bool = false

var card_checks_left : int = 1
var card_checks_done : int = 0
var check_trust : bool = false
var check_succesed : bool = false

func _ready() -> void:
	EventBusAction.send_action.connect(recieve_action)
	EventBusGL.start_round.connect(card_manager.fill_hands)
	EventBusGL.start_round.connect(start_round)
	#TODO: delete
	PhaseManager.init()
	#PhaseNames.used_dialogs.clear()

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

func get_round_result() -> EventBusGL.END_ROUND_RESULT:
	if current_player == PLAYER.MAN:
		if check_succesed:
			if check_trust:
				return EventBusGL.END_ROUND_RESULT.CARDS_ARE_DISCARED
			else:
				return EventBusGL.END_ROUND_RESULT.ENEMY_TAKES_CARDS
		else:
			return EventBusGL.END_ROUND_RESULT.PLAYER_TAKES_CARDS
	else:
		if check_succesed:
			if check_trust:
				return EventBusGL.END_ROUND_RESULT.CARDS_ARE_DISCARED
			else:
				return EventBusGL.END_ROUND_RESULT.PLAYER_TAKES_CARDS
		else:
			return EventBusGL.END_ROUND_RESULT.ENEMY_TAKES_CARDS

func call_basilio_signals():
	var checked_all : bool
	checked_all = card_manager.last_add.size() == card_checks_done
	if !check_succesed:
		if check_trust:
			EventBusAction.basilio_mistrusted.emit()
		else: 
			EventBusAction.basilio_miscalled.emit()
			if checked_all:
				EventBusAction.basilio_miscalled_and_learns.emit()

var learned = false
var dialog_id : String
func check_dialog() -> bool:
	dialog_id = ""
	if current_player == PLAYER.AI:
		if check_succesed && check_trust:
			dialog_id = PhaseNames.dialog_correct_trust_1
		if check_succesed && !check_trust:
			var rand = randi_range(0, 3)
			if rand == 0:
				dialog_id = PhaseNames.dialog_id_correct_bluff_1
			if rand == 1:
				dialog_id = PhaseNames.dialog_id_correct_bluff_2
			if rand == 2:
				dialog_id = PhaseNames.dialog_id_correct_bluff_3
		if !learned:
			var checked_all : bool
			checked_all = card_manager.last_add.size() == card_checks_done
			if !check_succesed && check_trust:
				dialog_id = PhaseNames.dialog_basilio_learns_trust
			if !check_succesed && !check_trust && checked_all:
				dialog_id = PhaseNames.dialog_basilio_learns_bluff
			learned = true
	else:
		return false
	if dialog_id != "":
		return true
	return false

func end_round() -> void:
	if current_player == PLAYER.AI:
		call_basilio_signals()
	await Utils.wait(1.0)
	if check_dialog():
		var dialog_effect = EFFECT_DIALOG.instantiate()
		add_child(dialog_effect)
		dialog_effect.start(dialog_id)
		
	var result = get_round_result()
	print("ROUND ENDED")
	EventBusAction.progress_game_delayed.emit()
	EventBusGL.end_round_delayed.emit(result)
	EventBusGL.update_visualisation_delayed.emit()
	switch_player_round()
	EventBusGL.start_round_delayed.emit()
	
func start_round() -> void:
	EventBus.sit_back_at_table.emit()
	round_mark = Card.CARD_MARK.SKULL
	card_checks_done = 0
	round_mark_set = false
	check_succesed = false
	if card_manager.hand_player.size() == 0 && \
	card_manager.hand_enemy.size() == 0:
		end_game()
		return
	current_player = current_player_round
	if card_manager.hand_player.size() == 0:
		current_player = PLAYER.AI
	if card_manager.hand_enemy.size() == 0:
		current_player = PLAYER.MAN
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
	if card_manager.get_last_addition().size() <= card_checks_left:
		return false
	return true

func can_active_player_add_cards() -> bool:
	if current_player == PLAYER.MAN:
		return card_manager.get_player_hand().size() > 0
	else:
		return card_manager.get_enemy_hand().size() > 0

func update_check_success(check_truth : bool) -> void:
	if check_truth && check_trust:
		check_succesed = true
	if (!check_truth) && (!check_trust):
		check_succesed = true

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
	match action:
		EventBusAction.ACTION.ADD_CARDS:
			if round_mark_set:
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
			player_avialable_actions.append(EventBusAction.ACTION.DECLARE_TRUST)
			player_avialable_actions.append(EventBusAction.ACTION.CALL_BLUFF)
			player_avialable_actions.append(EventBusAction.ACTION.ADD_CARDS)
		EventBusAction.ACTION.CALL_BLUFF:
			card_checks_left = 1
			check_trust = false
			if can_increase_card_check():
				player_avialable_actions.append(EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK)
			player_avialable_actions.append(EventBusAction.ACTION.ADD_CARD_TO_CHECK)
		#can't increase num of checked cards, when we believe
		EventBusAction.ACTION.DECLARE_TRUST:
			card_checks_left = 1
			check_trust = true
			player_avialable_actions.append(EventBusAction.ACTION.ADD_CARD_TO_CHECK)
		EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK:
			card_checks_left += 1
			if can_increase_card_check():
				player_avialable_actions.append(EventBusAction.ACTION.ADD_EXTRA_CARD_CHECK)
			player_avialable_actions.append(EventBusAction.ACTION.ADD_CARD_TO_CHECK)
		EventBusAction.ACTION.ADD_CARD_TO_CHECK:
			card_checks_left -= 1
			card_checks_done += 1
			var truth = data as bool
			update_check_success(truth)
			if check_succesed:
				should_end_round = true
			if card_checks_left == 0:
				should_end_round = true
			if !should_end_round:
				player_avialable_actions.append(EventBusAction.ACTION.ADD_CARD_TO_CHECK)
	if should_end_round:
		end_round()
	else:
		EventBusGL.update_visualisation_delayed.emit()
		EventBusAction.progress_game_delayed.emit()

func _process(delta: float) -> void:
	pass
