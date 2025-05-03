class_name GameManager
extends Node

@export_category("Bonus costs")
@export var extra_check_cost : int = 5

@onready var card_manager: CardManager = $"../CardManager"
@onready var game_state_manager: GameStateManager = $"../GameStateManager"

#TO DO: move elsewhere
@onready var player_score_disp: Button = $"../CanvasLayer/PlayerScore"
@onready var enemy_score_disp: Button = $"../CanvasLayer/EnemyScore"

var player_score : int = 0
var enemy_score : int = 0
var player_bonus : int = 0
var enemy_bonus : int = 0

var inited : bool = false

func _ready() -> void:
	EventBusGL.update_visualisation.connect(update_score_disp)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !inited:
		EventBusGL.start_round.emit()
		EventBusGL.update_visualisation.emit()
		EventBusAction.progress_game.emit()
		inited = true

func player_takes_cards() -> void:
	for c in card_manager.stack:
		var card = c as Card
		player_score += card.score_mod
		player_bonus += card.bonus_mod
	card_manager.stack.clear()

func enemy_takes_cards() -> void:
	for c in card_manager.stack:
		var card = c as Card
		player_score += card.score_mod
		player_bonus += card.bonus_mod
	card_manager.stack.clear()

func cards_are_removed() -> void:
	card_manager.stack.clear()

func add_score(result : EventBusGL.END_ROUND_RESULT) -> void:
	if result == EventBusGL.END_ROUND_RESULT.PLAYER_TAKES_CARDS:
		player_takes_cards()
	if result == EventBusGL.END_ROUND_RESULT.ENEMY_TAKES_CARDS:
		enemy_takes_cards()
	if result == EventBusGL.END_ROUND_RESULT.CARDS_ARE_DISCARED:
		cards_are_removed()
	EventBusGL.update_visualisation.emit()

func update_score_disp() -> void:
	player_score_disp.text = "Player: " + str(player_score)
	enemy_score_disp.text = "Enemy: " + str(enemy_score)
