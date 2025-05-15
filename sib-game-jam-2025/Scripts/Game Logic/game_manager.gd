class_name GameManager
extends Node

@export_category("Bonus costs")
@export var extra_check_cost : int = 5

@onready var card_manager: CardManager = $"../CardManager"
@onready var game_state_manager: GameStateManager = $"../GameStateManager"

const EFFECT_NOSE_GROW = preload("res://Scenes/Effects/EffectNoseGrow.tscn")

var player_score : int = 0
var enemy_score : int = 0
var player_bonus : int = 5
var enemy_bonus : int = 5

var inited : bool = false

func _ready() -> void:
	EventBusGL.end_round.connect(process_end_round)
	EventBusAction.player_lied.connect(grow_nose)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !inited:
		EventBusGL.start_round.emit()
		EventBusGL.update_visualisation.emit()
		EventBusAction.progress_game.emit()
		inited = true

func process_end_round(result : EventBusGL.END_ROUND_RESULT) -> void:
	card_manager.pre_finish_round()
	match result:
		EventBusGL.END_ROUND_RESULT.PLAYER_TAKES_CARDS:
			player_takes_cards()
			return
		EventBusGL.END_ROUND_RESULT.ENEMY_TAKES_CARDS:
			enemy_takes_cards()
			return
		EventBusGL.END_ROUND_RESULT.CARDS_ARE_DISCARED:
			cards_are_removed()
			return

func player_takes_cards() -> void:
	print("Player takes cards!")
	EventBusAction.print_action.emit("Player takes cards!")
	for c in card_manager.stack:
		var card = c as Card
		player_score += card.score_mod
		player_bonus += card.bonus_mod
		EventBus.token_add_several.emit(MagicNumbers.PLAYER_ID, card.bonus_mod)
	card_manager.stack.clear()

func enemy_takes_cards() -> void:
	print("Enemy takes cards!")
	EventBusAction.print_action.emit("Enemy takes cards!")
	for c in card_manager.stack:
		var card = c as Card
		enemy_score += card.score_mod
		enemy_bonus += card.bonus_mod
		EventBus.token_add_several.emit(MagicNumbers.ENEMY_ID, card.bonus_mod)
		
	card_manager.stack.clear()

func cards_are_removed() -> void:
	print("Cards are removed")
	EventBusAction.print_action.emit("Cards are removed")
	card_manager.stack.clear()

func add_score(result : EventBusGL.END_ROUND_RESULT) -> void:
	if result == EventBusGL.END_ROUND_RESULT.PLAYER_TAKES_CARDS:
		player_takes_cards()
	if result == EventBusGL.END_ROUND_RESULT.ENEMY_TAKES_CARDS:
		enemy_takes_cards()
	if result == EventBusGL.END_ROUND_RESULT.CARDS_ARE_DISCARED:
		cards_are_removed()
	EventBusGL.update_visualisation_delayed.emit()

func grow_nose() -> void:
	var nose_effect = EFFECT_NOSE_GROW.instantiate()
	add_child(nose_effect)
