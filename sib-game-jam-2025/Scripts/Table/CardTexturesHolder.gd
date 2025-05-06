extends Node

var _textures = {}

var _type_representations = {
	Card.CARD_MARK.KEY : "key",
	Card.CARD_MARK.COIN : "coin",
	Card.CARD_MARK.PUPPET : "pu",
	Card.CARD_MARK.ALPHABET : "alpha",
	Card.CARD_MARK.SKULL : ""
}

var _value_representations = {
	Card.CARD_VALUE.AVIAN : "AVI",
	Card.CARD_VALUE.SIX : "6",
	Card.CARD_VALUE.SEVEN : "7",
	Card.CARD_VALUE.EIGHT : "8",
	Card.CARD_VALUE.LEECHE : "LE",
	Card.CARD_VALUE.NINE : "9",
	Card.CARD_VALUE.TEN : "10",
	Card.CARD_VALUE.TBD : "",
	Card.CARD_VALUE.SKULL : "skull"
}

func get_texture(type: Card.CARD_MARK, value: Card.CARD_VALUE) -> Resource:
	return _textures[key_by(type, value)]

func init():
	for type in Card.CARD_MARK.values():
		for value in Card.CARD_VALUE.values():
			var prefix = "res://Sprites/Table/Cards/"
			var postfix = "_mute_trans.png"
			var type_str = _type_representations[type]
			type_str = str("_", type_str) if type_str != "" else ""
			var value_str = _value_representations[value]
			var texture_path = str(prefix, value_str, type_str, postfix)
			_textures[key_by(type, value)] = load(texture_path)

func key_by(type: Card.CARD_MARK, value: Card.CARD_VALUE) -> String:
	return str(type, "|", value)
