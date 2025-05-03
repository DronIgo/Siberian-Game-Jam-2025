class_name Card3D

extends Node3D

enum Type { RED, YELLOW, GREEN, BLUE, GRAY }

@export var flip_anim_name = "card_flip"
@export var selection_anim_name = "card_selection"
@export var unselection_anim_name = "card_unselection"

@onready var _anim_player: AnimationPlayer = $AnimationPlayer

var _type: Type

func init(type: Type):
	_type = type
	var texture_path = str("res://Sprites/Table/card_", _type_to_low_str(type),".png")
	$Body/Front.texture = load(texture_path)

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
