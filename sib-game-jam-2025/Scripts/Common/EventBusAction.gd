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
signal update_visualisation
signal progress_game
