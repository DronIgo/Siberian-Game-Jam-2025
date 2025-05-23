class_name Menu

extends CanvasLayer

@onready var _authors_label = $Rect/AuthorsBase/AuthorsRect/AuthorsLabel
@onready var _anim_player = $Rect/AuthorsBase/AnimationPlayer

var _authors = ["Dron231", "sintaxiz", "deerboy1940", "doorvendoor", "zheltog"]
var _authors_shown = false

func _ready():
	PhaseManager.init()
	var phase = PhaseManager.current_phase()
	MusicProcessor.process(phase)

func _on_play_button_pressed():
	var phase: Phase = PhaseManager.try_next_phase()
	get_tree().change_scene_to_file(phase.scene_name)

func _on_authors_button_pressed():
	_authors_label.text = ""
	_authors.shuffle()
	for author in _authors:
		_authors_label.text += str(author, "\n")
	if not _authors_shown:
		_anim_player.play("authors_appear")
		_authors_shown = true

func _on_exit_button_pressed():
	_exit()
	
func _exit():
	get_tree().quit()
