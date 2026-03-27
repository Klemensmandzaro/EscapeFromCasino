extends Node


var suits = ["Spades", "Hearts", "Diamonds", "Clubs"]

var values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

var cards_in_deck = []

func _ready():
	
	generate_deck()

func generate_deck():
	cards_in_deck.clear()
	for suit in suits:
		for value in values:
			var new_card = {"suit": suit, "value": value}
			cards_in_deck.append(new_card)
			
	cards_in_deck.shuffle() 
	print("Talia gotowa i potasowana! Mamy kart: ", cards_in_deck.size())


func draw_card() -> Dictionary:
	if cards_in_deck.size() > 0:
		return cards_in_deck.pop_back()
	else:
		print("Błąd: Talia jest pusta!")
		return {}
