class_name CardUtils
extends Object

static func check_truth(cards : Array, color : Card.CARD_COLOR) -> bool:
	for c in cards:
		var card = c as Card
		if card.color != color:
			return false
	return true

static func check_random(cards : Array, color : Card.CARD_COLOR) -> bool:
	var size = cards.size()
	var rand_card = randi_range(0, size - 1)
	return cards[rand_card].color == color
