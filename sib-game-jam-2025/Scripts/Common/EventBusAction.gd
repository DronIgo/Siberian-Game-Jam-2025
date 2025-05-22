extends Node

enum ACTION {
	ADD_CARDS,
	SELECT_MARK,
	DECLARE_TRUST,
	CALL_BLUFF,
	ADD_EXTRA_CARD_CHECK,
	ADD_CARD_TO_CHECK
}

signal send_action_delayed(action : ACTION, data)
signal progress_game_delayed
signal effect_end_delayed

signal send_action(action : ACTION, data)
signal progress_game
signal print_action(action : String)
signal effect_end

signal player_lied
signal player_told_truth
signal basilio_mistrusted
signal basilio_miscalled
signal basilio_miscalled_and_learns
