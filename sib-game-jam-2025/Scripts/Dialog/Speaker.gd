class_name Speaker

extends Control

@onready var name_label = $NameFrame/NameLabel
@onready var avatar = $Avatar

func initialize(data: SpeakerData):
	name_label.text = data.name
	var texture_path = data.texture_path
	if texture_path != null and texture_path != "":
		avatar.texture = load(texture_path)
