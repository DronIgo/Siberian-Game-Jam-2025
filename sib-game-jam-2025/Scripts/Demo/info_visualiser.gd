class_name InfoVisualiser
extends Node

@onready var game_manager: GameManager = $"../GameManager"
@onready var game_state_manager: GameStateManager = $"../GameStateManager"
@onready var card_manager: CardManager = $"../CardManager"

@onready var last_action: Label = $"../CanvasLayer/LastAction"
@onready var cards_in_deck: Label = $"../CanvasLayer/CardsInDeck"
@onready var player_score: Label = $"../CanvasLayer/PlayerScore"
@onready var enemy_score: Label = $"../CanvasLayer/EnemyScore"
@onready var player_bonuses: Label = $"../CanvasLayer/PlayerBonuses"
@onready var enemy_bonuses: Label = $"../CanvasLayer/EnemyBonuses"
@onready var turn_label: Label = $"../CanvasLayer/TurnLabel"
@onready var stack_counter: Label = $"../CanvasLayer/SelectedMark/StackCounter"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBusAction.print_action.connect(display_last_action)
	EventBusGL.update_visualisation.connect(update_display)

func update_display() -> void:
	cards_in_deck.text = "В колоде ещё " + str(card_manager.deck.size()) + " карт"
	player_score.text = "Штрафные очки: " + str(game_manager.player_score)
	enemy_score.text = "Штрафные очки: " + str(game_manager.enemy_score)
	player_bonuses.text = "Бонусы: " + str(game_manager.player_bonus)
	enemy_bonuses.text = "Бонусы: " + str(game_manager.enemy_bonus)
	stack_counter.text = str(card_manager.stack.size() + card_manager.last_add.size())
	if game_state_manager.current_player == GameStateManager.PLAYER.MAN:
		turn_label.text = "Ваш ход!"
	else:
		turn_label.text = "Противник думает..."
func display_last_action(action: String) -> void:
	last_action.text = action
	
