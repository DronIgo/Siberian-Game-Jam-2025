extends Node

enum END_ROUND_RESULT {
	PLAYER_TAKES_CARDS,
	ENEMY_TAKES_CARDS,
	CARDS_ARE_DISCARED
}

signal start_round_delayed
signal end_round_delayed(round_result : END_ROUND_RESULT)
signal update_visualisation_delayed

signal start_round
signal end_round(round_result : END_ROUND_RESULT)
signal update_visualisation
