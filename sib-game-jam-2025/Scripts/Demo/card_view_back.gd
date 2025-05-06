class_name CardViewBack
extends Button

var active : bool = false
var base_card : Card

var card_manager: CardManager
var actions: PlayerActions

const BLUE_BUTTON_THEME = preload("res://Resources/Demo/blue_button_theme.tres")
const GREEN_BUTTON_THEME = preload("res://Resources/Demo/green_button_theme.tres")
const GRAY_BUTTON_THEME = preload("res://Resources/Demo/grey_button_theme.tres")
const RED_BUTTON_THEME = preload("res://Resources/Demo/red_button_theme.tres")
const VIOLET_BUTTON_THEME = preload("res://Resources/Demo/violet_button_theme.tres")

func _ready() -> void:
	pressed.connect(_button_pressed)
	card_manager = get_node("../../../CardManager")

func set_visualiser(p_actions : PlayerActions) -> void:
	actions = p_actions

func set_base_card(base : Card) -> void:
	base_card = base

func set_active(new_active : bool) -> void:
	active = new_active

func _button_pressed():
	if (active):
		flip()
		actions.check_card(base_card.color)

func flip() -> void:
	if base_card:
		match base_card.mark:
			Card.CARD_MARK.KEY:
				theme = RED_BUTTON_THEME
			Card.CARD_MARK.PUPPET:
				theme = BLUE_BUTTON_THEME
			Card.CARD_MARK.COIN:
				theme = GREEN_BUTTON_THEME
			Card.CARD_MARK.ALPHABET:
				theme = VIOLET_BUTTON_THEME
			Card.CARD_MARK.SKULL:
				theme = GRAY_BUTTON_THEME
		text = str(base_card.value)
	
