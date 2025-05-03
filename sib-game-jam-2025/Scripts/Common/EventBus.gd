extends Node

# dialog
signal dialog_start(config_path: String)

# table
signal hand_add_card(player_id: int, card_type: Card3D.Type)
signal hand_remove_card(player_id: int, index: int)
signal token_add(player_id: int)
signal token_remove(player_id: int)
signal stack_add_card(stack_type: CardsStack.Type)
signal stack_remove_card(stack_type: CardsStack.Type)
signal line_add_card(card_type: Card3D.Type)
signal line_remove_card(index: int)
