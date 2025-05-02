class_name Speaker

extends Control

@onready var name_label = $NameFrame/NameLabel
@onready var avatar = $Avatar

func initialize(data: SpeakerData):
	name_label.text = data.name
	avatar.texture = load(data.texture_path)
