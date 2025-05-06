extends HBoxContainer

@onready var game_manager: GameManager = $"../../GameManager"
@onready var player_actions: PlayerActions = $"../../PlayerActions"

@onready var button_select_KEY: TextureButton = $SelectKey
@onready var button_select_PUPPET: TextureButton = $SelectPuppet
@onready var button_select_COIN: TextureButton = $SelectCoin
@onready var button_select_ALPHABET: TextureButton = $SelectAlphabet


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_select_PUPPET.pressed.connect(select_PUPPET)
	button_select_KEY.pressed.connect(select_KEY)
	button_select_COIN.pressed.connect(select_COIN)
	button_select_ALPHABET.pressed.connect(select_ALPHABET)
	visible = false
	
func select_KEY() -> void:
	player_actions.select_mark(Card.CARD_MARK.KEY)
	selection_done()
func select_PUPPET() -> void:
	player_actions.select_mark(Card.CARD_MARK.PUPPET)
	selection_done()
func select_COIN() -> void:
	player_actions.select_mark(Card.CARD_MARK.COIN)
	selection_done()
func select_ALPHABET() -> void:
	player_actions.select_mark(Card.CARD_MARK.ALPHABET)
	selection_done()
	
func selection_done() -> void:
	visible = false
