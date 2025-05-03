class_name CardView
extends Button

var active : bool = false
var selected : bool = false
var base_card : Card

var card_manager: CardManager
var selected_mark: ColorRect

const BLUE_BUTTON_THEME = preload("res://Resources/Demo/blue_button_theme.tres")
const GREEN_BUTTON_THEME = preload("res://Resources/Demo/green_button_theme.tres")
const GREY_BUTTON_THEME = preload("res://Resources/Demo/grey_button_theme.tres")
const RED_BUTTON_THEME = preload("res://Resources/Demo/red_button_theme.tres")
const VIOLET_BUTTON_THEME = preload("res://Resources/Demo/violet_button_theme.tres")

func _ready() -> void:
	pressed.connect(_button_pressed)
	selected_mark = get_node("Selected")
	card_manager = get_tree().get_root().get_node("/root/Node2D/CardManager")
	EventBusGL.update_visualisation.connect(update_view)

func set_base_card(base : Card) -> void:
	base_card = base
	update_view()

func set_active(new_active : bool) -> void:
	active = new_active

func set_selected(new_selected : bool) -> void:
	selected = new_selected
	update_view()

func _button_pressed():
	if (active):
		if !selected:
			if card_manager.select_card(base_card):
				selected = !selected
		else:
			card_manager.deselect_card(base_card)
			selected = !selected
		EventBusGL.update_visualisation.emit()

func update_view() -> void:
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
	selected_mark.visible = selected
	
