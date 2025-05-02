class_name TokenSpawner

extends Node3D

@export var token_scene: PackedScene

var _current_tokens: Array = []

func add_token():
	var token = token_scene.instantiate()
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
