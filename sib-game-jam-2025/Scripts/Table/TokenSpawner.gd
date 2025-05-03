class_name TokenSpawner

extends Node3D

@export var token_scene: PackedScene
@export var max_tokens_in_stack = 5
@export var max_stacks_in_row = 3
@export var stacks_offset = 0.33

var _current_tokens: Array = []

func add_token():
	var token = token_scene.instantiate()
	var tokens_num = _current_tokens.size()
	var current_stack = tokens_num / max_tokens_in_stack
	var current_row = current_stack / max_stacks_in_row
	token.position.x += (current_stack - current_row * max_stacks_in_row) * stacks_offset
	token.position.z += current_row * stacks_offset
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
