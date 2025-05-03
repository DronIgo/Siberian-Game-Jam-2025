extends Node

enum END_ROUND_RESULT {
	PLAYER_TAKES_CARDS,
	ENEMY_TAKES_CARDS,
	CARDS_ARE_DISCARED
}

signal start_round
signal end_round(player_won : END_ROUND_RESULT)
signal update_visualisation
