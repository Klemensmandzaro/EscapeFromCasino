extends Sprite2D

var card_value: String = ""
var card_suit: String = ""
var is_hidden: bool = false 

# UŻYWAMY "make_hidden", ŻEBY NIE DRAŻNIĆ GODOTA!
func setup_card(new_value: String, new_suit: String, make_hidden: bool = false):
	card_value = new_value
	card_suit = new_suit
	is_hidden = make_hidden
	update_texture()

func update_texture():
	if is_hidden:
		# SPRAWDŹ TĘ NAZWĘ! Zmień ją na taką, jaką fizycznie masz w folderze (np. cardBack_red1.png)
		texture = load("res://Graphics/Cards/cardBack_blue5.png") 
	else:
		texture = load("res://Graphics/Cards/card" + card_suit + card_value + ".png")

func reveal():
	is_hidden = false
	update_texture()
