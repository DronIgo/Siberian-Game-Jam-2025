extends Object

#could also put extra methods that affect the game when the card is added
#to one of the player deck in this class
class_name Card

enum CARD_COLOR {
	RED = 0,
	GREEN = 1,
	BLUE = 2,
	VIOLET = 3,
	GREY = 4
}

var color: CARD_COLOR
var value: int
var bonus_mod : int
var score_mod: int
func debug_print() -> void:
	#look like ass but displays the string representation
	print("   ",CARD_COLOR.keys()[color], " ", value);
