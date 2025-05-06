class_name CardUtils
extends Object

static func check_truth(cards : Array, mark : Card.CARD_MARK) -> bool:
	for c in cards:
		var card = c as Card
		if card.mark != mark:
			return false
	return true

static func check_random(cards : Array, mark : Card.CARD_MARK) -> bool:
	var size = cards.size()
	var rand_card = randi_range(0, size - 1)
	return cards[rand_card].mark == mark
