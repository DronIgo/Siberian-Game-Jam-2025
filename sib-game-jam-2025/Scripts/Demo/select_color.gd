extends HBoxContainer

@onready var game_manager: GameManager = $"../../GameManager"
@onready var player_actions: PlayerActions = $"../../PlayerActions"

@onready var button_select_red: TextureButton = $SelectRed
@onready var button_select_blue: TextureButton = $SelectBlue
@onready var button_select_green: TextureButton = $SelectGreen
@onready var button_select_violet: TextureButton = $SelectViolet


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_select_blue.pressed.connect(select_blue)
	button_select_red.pressed.connect(select_red)
	button_select_green.pressed.connect(select_green)
	button_select_violet.pressed.connect(select_violet)
	visible = false
	
func select_red() -> void:
	player_actions.select_color(Card.CARD_COLOR.RED)
	selection_done()
func select_blue() -> void:
	player_actions.select_color(Card.CARD_COLOR.BLUE)
	selection_done()
func select_green() -> void:
	player_actions.select_color(Card.CARD_COLOR.GREEN)
	selection_done()
func select_violet() -> void:
	player_actions.select_color(Card.CARD_COLOR.VIOLET)
	selection_done()
	
func selection_done() -> void:
	visible = false
