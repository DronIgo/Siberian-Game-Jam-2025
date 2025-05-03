class_name CardManager
extends Node

@export_category("Deck settings")
@export var cards_each_color_num : int = 7
@export var cards_grey_num : int = 4

@export_category("Hands settings")
@export var num_of_cards_in_hand : int = 7
@export var max_cards_placed_during_turn : int = 3

#const Card = preload("res://Scripts/Game Logic/Card.gd")

var deck : Array
var hand_player : Array
var hand_enemy : Array
#cards on the table, except for the ones added during last turn
var stack : Array
var selected_cards : Array
#cards added on last turn
var last_add : Array

func get_player_hand() -> Array:
	return hand_player
func get_enemy_hand() -> Array:
	return hand_enemy
func get_last_addition() -> Array:
	return last_add
func get_current_stack() -> Array:
	return stack
func select_card(card : Card) -> bool:
	if selected_cards.size() < max_cards_placed_during_turn:
		selected_cards.append(card)
		return true
	return false
func deselect_card(card : Card) -> void:
	if selected_cards.count(card) < 0:
		print("trying to deselect_card a card thats not on the selected_cards!")
		return
	selected_cards.erase(card)
func is_stack_correct() -> bool:
	return selected_cards.size() > 0

func place_cards(player_turn : bool) -> void:
	stack.append_array(last_add)
	last_add.clear()
	last_add.append_array(selected_cards)
	for c in selected_cards:
		if player_turn:
			hand_player.erase(c)
		else:
			hand_enemy.erase(c)
	selected_cards.clear()

func end_round() -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBusGL.start_round.connect(fill_hands)
	randomize()
	create_starting_deck()

func add_card_to_players(player_won_last_round : bool) -> bool:
	if deck.size() == 0:
		return false
		
	var p_count = hand_player.size()
	var e_count = hand_enemy.size()
	if p_count == 7 && e_count == 7:
		return false
		
	if p_count < e_count:
		hand_player.append(deck.pop_back())
		return true
	else:
		if e_count > p_count:
			hand_enemy.append(deck.pop_back())
			return true
		else:
			if player_won_last_round:
				hand_enemy.append(deck.pop_back())
				return true
			else:
				hand_player.append(deck.pop_back())
				return true

func fill_hands() -> void:
	var added_card : bool
	#TO DO: change the argument depending on whether player won or lost last round
	added_card = add_card_to_players(true)
	while added_card:
		added_card = add_card_to_players(true)
	debug_output()

func create_starting_deck() -> void:
	deck = []
	for c in Card.CARD_COLOR.values():
		if c as Card.CARD_COLOR == Card.CARD_COLOR.GREY:
			continue
		for i in range(cards_each_color_num):
			var new_card = Card.new()
			new_card.color = c as Card.CARD_COLOR
			new_card.value = i + 1
			new_card.bonus_mod = 1
			new_card.score_mod = 1
			deck.append(new_card)
	for i in range(cards_grey_num):
		var new_card = Card.new()
		new_card.color = Card.CARD_COLOR.GREY
		new_card.value = 9
		new_card.bonus_mod = 3
		new_card.score_mod = 3
		deck.append(new_card)
	deck.shuffle()

func debug_output() -> void:
	print("PLAYER HAND:")
	for c in hand_player:
		c.debug_print()
	print("ENEMY HAND")
	for c in hand_enemy:
		c.debug_print()
	print("DECK")
	for c in deck:
		c.debug_print()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
