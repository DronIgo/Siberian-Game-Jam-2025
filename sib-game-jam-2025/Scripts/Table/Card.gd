class_name Card3D

extends RigidBody3D

enum Type { RED, YELLOW, GREEN, BLUE, GRAY }

enum Action { NONE, SELECTION, UNSELECTION, FLIP_JUMP, FLIP_ROTATION }

@export var flip_rotation_speed: float = 500
@export var flip_jump_speed: float = 10
@export var flip_height: float = 0.05
@export var selection_speed: float = 0.5
@export var selection_height: float = 0.05

@onready var _anim_player: AnimationPlayer = $AnimationPlayer

var _front: Sprite3D
var _type: Type
var _saved_position: Vector3
var _target_flip_angle: float
var _current_flip_angle: float
var _current_action: Action

func _process(delta):
	match _current_action:
		Action.NONE:
			return
		Action.SELECTION:
			if position.y > _saved_position.y + selection_height:
				_current_action = Action.NONE
				return
			position += Vector3(0, selection_speed * delta, 0)
		Action.UNSELECTION:
			if position.y <= _saved_position.y:
				position.y = _saved_position.y
				_saved_position = position
				_current_action = Action.NONE
				return
			position -= Vector3(0, selection_speed * delta, 0)
		Action.FLIP_JUMP:
			if position.y > _saved_position.y + flip_height:
				position.y = flip_height
				_current_action = Action.FLIP_ROTATION
				return
			position += Vector3(0, flip_jump_speed * delta, 0)
		Action.FLIP_ROTATION:
			if _current_flip_angle <= _target_flip_angle:
				rotation.x = deg_to_rad(_target_flip_angle)
				#enable_physics()
				_current_action = Action.NONE
				return
			_current_flip_angle -= flip_rotation_speed * delta
			rotation.x = deg_to_rad(_current_flip_angle)
			print(_current_flip_angle)

func init(type: Type):
	_type = type
	_front = $Front
	var texture_path = str("res://Sprites/Table/card_", _type_to_low_str(type),".png")
	_front.texture = load(texture_path)

func move_x(delta_x: float):
	position += Vector3(delta_x, 0, 0)

func enable_physics():
	freeze = false
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

func disable_physics():
	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC

func flip():
	disable_physics()
	_current_flip_angle = rad_to_deg(rotation.x)
	_target_flip_angle = _current_flip_angle - 180
	#_current_action = Action.FLIP_JUMP
	_current_action = Action.FLIP_ROTATION

func select():
	if _current_action == Action.SELECTION:
		return
	_saved_position = position
	_current_action = Action.SELECTION

func unselect():
	if _current_action == Action.UNSELECTION:
		return
	_current_action = Action.UNSELECTION

func _type_to_low_str(type: Type) -> String:
	return str(Type.keys()[type]).to_lower()
