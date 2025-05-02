extends Node

# dialog
signal dialog_start(config_path: String)

# table
signal hand_add_card(player_id: int, card_type: Card.Type)
