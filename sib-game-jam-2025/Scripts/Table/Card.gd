class_name Card3D

extends Node3D

enum Type { KEY, COIN, PUPPET, ALPHABET, SKULL }

var type_representations = {
	Type.KEY : "key",
	Type.COIN : "coin",
	Type.PUPPET : "pu",
	Type.ALPHABET : "alpha",
	Type.SKULL : ""
}

enum Value {
	AVIAN = 1,
	BUG = 2,
	DOG = 3,
	FROG = 4,
	LEECHE = 5,
	TURTLE = 6,
	TBD = 7,
	SCULL = 9
}

var value_representations = {
	Value.AVIAN : "AVI",
	Value.BUG : "B",
	Value.DOG : "D",
	Value.FROG : "F",
	Value.LEECHE : "L",
	Value.TURTLE : "T",
	Value.TBD : "",
	Value.SCULL : "scull"
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
	var texture_path = _calc_card_name()
	$Body/Front.texture = load(_calc_card_name())

func _calc_card_name() -> String:
	var prefix = "res://Sprites/Table/Cards/"
	var postfix = "_mute_trans.png"
	var type_str = type_representations[_type]
	var value_str = value_representations[_value]
	return str(prefix, value_str, "_", type_str, postfix)

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

func unselect():
	_anim_player.play(unselection_anim_name)

func _type_to_low_str(type: Type) -> String:
	return str(Type.keys()[type]).to_lower()
