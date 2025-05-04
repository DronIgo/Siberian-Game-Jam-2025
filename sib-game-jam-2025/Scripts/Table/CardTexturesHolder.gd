extends Node

var _textures = {}

var _type_representations = {
	Card3D.Type.KEY : "key",
	Card3D.Type.COIN : "coin",
	Card3D.Type.PUPPET : "pu",
	Card3D.Type.ALPHABET : "alpha",
	Card3D.Type.SKULL : ""
}

var _value_representations = {
	Card3D.Value.AVIAN : "AVI",
	Card3D.Value.BUG : "B",
	Card3D.Value.DOG : "D",
	Card3D.Value.FROG : "F",
	Card3D.Value.LEECHE : "LE",
	Card3D.Value.TURTLE : "T",
	Card3D.Value.TBD : "",
	Card3D.Value.SCULL : "scull"
}

func get_texture(type: Card3D.Type, value: Card3D.Value) -> Resource:
	return _textures[key_by(type, value)]

func init():
	for type in Card3D.Type.values():
		for value in Card3D.Value.values():
			var prefix = "res://Sprites/Table/Cards/"
			var postfix = "_mute_trans.png"
			var type_str = _type_representations[type]
			type_str = str("_", type_str) if type_str != "" else ""
			var value_str = _value_representations[value]
			var texture_path = str(prefix, value_str, type_str, postfix)
			_textures[key_by(type, value)] = load(texture_path)

func key_by(type: Card3D.Type, value: Card3D.Value) -> String:
	return str(type, "|", value)
