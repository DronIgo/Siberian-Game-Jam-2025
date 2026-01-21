extends Object

#could also put extra methods that affect the game when the card is added
#to one of the player deck in this class
class_name Card

enum CARD_MARK { KEY, COIN, PUPPET, ALPHABET, SKULL }

enum CARD_VALUE {
	AVIAN = 1,
	LEECHE = 2,
	SIX = 3,
	SEVEN = 4,
	EIGHT = 5,
	NINE = 6,
	TEN = 7,
	TBD = 8,
	SKULL = 9
}

var mark: CARD_MARK
var value: CARD_VALUE
var bonus_mod : int
var score_mod: int
func debug_print() -> void:
	#look like ass but displays the string representation
	print("   ",mark_to_str(mark), " ", value);

static func mark_to_str(m : CARD_MARK) -> String:
	return CARD_MARK.keys()[m]
