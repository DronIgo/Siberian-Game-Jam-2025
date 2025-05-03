class_name RaycastLayers
extends Node

enum LAYER {
	COMMON = 0b0001,
	PLAYER_CARDS = 0b0010,
	ENEMY_CARDS = 0b0100,
	COIN = 0b1000
}

static func get_mask_names() -> Array[String]:
	return ["Player", "Enemy", "Card", "Coin", "Unknown"]
