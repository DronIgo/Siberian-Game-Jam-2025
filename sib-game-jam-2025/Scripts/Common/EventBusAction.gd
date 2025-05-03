extends Node

enum PLAYER_ACTION {
	ADD_CARDS,
	SELECT_COLOR,
	DECLARE_TRUST,
	CALL_BLUFF,
	ADD_EXTRA_CARD_CHECK,
	ADD_CARD_TO_CHECK
}

signal send_action(action : PLAYER_ACTION, data)
signal progress_game
signal print_action(action : String)
signal effect_end

signal player_lied
