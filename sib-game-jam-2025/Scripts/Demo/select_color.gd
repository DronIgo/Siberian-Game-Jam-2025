extends HBoxContainer

@onready var game_manager: GameManager = $"../../GameManager"
@onready var button_select_red: Button = $SelectRed
@onready var button_select_blue: Button = $SelectBlue
@onready var button_select_green: Button = $SelectGreen
@onready var button_select_violet: Button = $SelectViolet


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_select_blue.pressed.connect(select_blue)
	button_select_red.pressed.connect(select_red)
	button_select_green.pressed.connect(select_green)
	button_select_violet.pressed.connect(select_violet)
	visible = false
	
func select_red() -> void:
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.SELECT_COLOR,\
	 Card.CARD_COLOR.RED)
	selection_done()
func select_blue() -> void:
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.SELECT_COLOR,\
	 Card.CARD_COLOR.BLUE)
	selection_done()
func select_green() -> void:
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.SELECT_COLOR,\
	 Card.CARD_COLOR.GREEN)
	selection_done()
func select_violet() -> void:
	EventBusAction.send_action.emit(EventBusAction.PLAYER_ACTION.SELECT_COLOR,\
	 Card.CARD_COLOR.VIOLET)
	selection_done()
	
func selection_done() -> void:
	visible = false
