class_name CardViewBack
extends Button

var active : bool = false
var base_card : Card

var card_manager: CardManager
var player_actions: PlayerActions

const BLUE_BUTTON_THEME = preload("res://Resources/Demo/blue_button_theme.tres")
const GREEN_BUTTON_THEME = preload("res://Resources/Demo/green_button_theme.tres")
const GREY_BUTTON_THEME = preload("res://Resources/Demo/grey_button_theme.tres")
const RED_BUTTON_THEME = preload("res://Resources/Demo/red_button_theme.tres")
const VIOLET_BUTTON_THEME = preload("res://Resources/Demo/violet_button_theme.tres")

func _ready() -> void:
	pressed.connect(_button_pressed)
	card_manager = get_node("../../../CardManager")

func set_visualiser(actions : PlayerActions) -> void:
	player_actions = actions

func set_base_card(base : Card) -> void:
	base_card = base

func set_active(new_active : bool) -> void:
	active = new_active

func _button_pressed():
	if (active):
		flip()
		player_actions.check_card(base_card.color)

func flip() -> void:
	if base_card:
		match base_card.color:
			Card.CARD_COLOR.RED:
				theme = RED_BUTTON_THEME
			Card.CARD_COLOR.BLUE:
				theme = BLUE_BUTTON_THEME
			Card.CARD_COLOR.GREEN:
				theme = GREEN_BUTTON_THEME
			Card.CARD_COLOR.VIOLET:
				theme = VIOLET_BUTTON_THEME
			Card.CARD_COLOR.GREY:
				theme = GREY_BUTTON_THEME
		text = str(base_card.value)
	
