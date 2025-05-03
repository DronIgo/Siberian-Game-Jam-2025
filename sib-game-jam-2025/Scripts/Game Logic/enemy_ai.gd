class_name EnemyAI
extends Node

@onready var card_manager: CardManager = $"../CardManager"
@onready var game_manager: GameManager = $"../GameManager"

func start_turn() -> void:
	if game_manager.color_selected:
		place_extra_cards(card_manager.get_enemy_hand(), game_manager.current_correct_color)
		if card_manager.is_stack_correct():
			end_turn()
		else:
			check_player_cards(false)

func check_player_cards(believe : bool) -> void:
	var truth = CardUtils.check_random(card_manager.last_add, game_manager.current_correct_color)
	if truth:
		if believe:
			game_manager.cards_are_removed()
		else:
			game_manager.enemy_takes_cards()
	else:
		if believe:
			game_manager.enemy_takes_cards()
		else:
			game_manager.player_takes_cards()
		
func place_extra_cards(hand : Array, color : Card.CARD_COLOR) -> void:
	for c in hand:
		var card = c as Card
		if card.color == color:
			card_manager.select_card(card)
	
func place_first_cards(hand : Array) -> void:
	pass


func end_turn() -> void:
	card_manager.end_turn(false)
	EventBusGL.update_visualisation.emit()
	game_manager.player_turn = true
