# collision_layers.gd
extends Node

enum Layer {
	PLAYER = 0b0001,
	ENEMY = 0b0010,
	CARD = 0b0100,
	COIN = 0b1000,
	UNKNOWN = 0b10000
}

static func get_mask_names() -> Array[String]:
	return ["Player", "Enemy", "Card", "Coin", "Unknown"]
