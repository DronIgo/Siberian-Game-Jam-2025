extends Node

# dialog
signal dialog_start(config_path: String)

# table
signal hand_add_card(player_id: int, base_card: Card)
signal hand_remove_card(player_id: int, index: int)
signal hand_select_card(player_id: int, index: int)
signal hand_unselect_card(player_id: int, index: int)
signal hand_confirm_selected(indices: Array)
signal token_add(player_id: int)
signal token_remove(player_id: int)
signal stack_add_card(stack_type: CardsStack.Type)
signal stack_remove_card(stack_type: CardsStack.Type)
signal line_add_card(base_card: Card)
signal line_remove_card(index: int)
signal line_flip_card(index: int)
signal nose_increase()
signal bend_over_table()
signal sit_back_at_table()
