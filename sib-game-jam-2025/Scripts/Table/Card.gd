class_name Card3D

extends Node3D

enum Type { KEY, COIN, PUPPET, ALPHABET, SKULL }

enum Value {
	AVIAN = 1,
	LEECHE = 2,
	SIX = 3,
	SEVEN = 4,
	EIGHT = 5,
	NINE = 6,
	TEN = 7,
	TBD = 8,
	SCULL = 9
}

@export var flip_anim_name = "card_flip"
@export var selection_anim_name = "card_selection"
@export var unselection_anim_name = "card_unselection"
@onready var body: RigidBody3D = $Body

@onready var _anim_player: AnimationPlayer = $AnimationPlayer

var _type: Type
var _value: Value
var base_card : Card
var selectable : bool = false
var flipable : bool = false

func set_raycast_layer(layer : RaycastLayers.LAYER) -> void:
	body.collision_layer = layer

func init(card : Card):
	base_card = card
	match card.color:
		Card.CARD_COLOR.RED:
			_type = Type.KEY
		Card.CARD_COLOR.BLUE:
			_type = Type.COIN
		Card.CARD_COLOR.GREEN:
			_type = Type.PUPPET
		Card.CARD_COLOR.VIOLET:
			_type = Type.ALPHABET
		Card.CARD_COLOR.GREY:
			_type = Type.SKULL
	_value = card.value
	var texture_path = CardTexturesHolder.get_texture(_type, _value)
	$Body/Front.texture = texture_path

func move_x(delta_x: float):
	position += Vector3(delta_x, 0, 0)

func enable_physics():
	$Body.freeze = false
	$Body.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

func disable_physics():
	$Body.freeze = true
	$Body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC

func flip():
	_anim_player.play(flip_anim_name)

func select():
	_anim_player.play(selection_anim_name)
	EventBus.card_select_animation_in_progress = true
	await _anim_player.animation_finished
	EventBus.card_select_animation_in_progress = false

func unselect():
	_anim_player.play_backwards(selection_anim_name)
	EventBus.card_select_animation_in_progress = true
	await _anim_player.animation_finished
	EventBus.card_select_animation_in_progress = false

func _type_to_low_str(type: Type) -> String:
	return str(Type.keys()[type]).to_lower()
