class_name TokenSpawner

extends Node3D

@export var token_scene: PackedScene
@export var max_tokens_in_stack = 5
@export var max_stacks_in_row = 3
@export var stacks_offset = 0.33
@export var adding_gap_seconds: float = 0.2

@onready var _timer = $Timer

var _current_tokens: Array = []
var _tokens_to_add: Array = []

func _ready():
	_timer.wait_time = adding_gap_seconds

func add_tokens(num: int):
	for i in num:
		_tokens_to_add.append(token_scene.instantiate())
	_check_tokens_to_add()

func add_token():
	var token = token_scene.instantiate()
	_fix_token_position(token)
	add_child(token)
	_current_tokens.append(token)
	print("[TOKENS SPAWNER] TOKEN ADDED")

func remove_token():
	if _current_tokens.is_empty():
		return
	var token = _current_tokens[_current_tokens.size() - 1]
	token.queue_free()
	_current_tokens.erase(token)
	print("[TOKENS SPAWNER] TOKEN REMOVED")

func _on_timer_timeout():
	_check_tokens_to_add()

func _check_tokens_to_add():
	if _tokens_to_add.is_empty():
		return
	var token = _tokens_to_add[0]
	_fix_token_position(token)
	_tokens_to_add.erase(token)
	_current_tokens.append(token)
	add_child(token)
	_timer.start()

func _fix_token_position(token):
	var tokens_num = _current_tokens.size()
	var current_stack = tokens_num / max_tokens_in_stack
	var current_row = current_stack / max_stacks_in_row
	token.position.x += (current_stack - current_row * max_stacks_in_row) * stacks_offset
	token.position.z += current_row * stacks_offset
