extends Node

# Definiujemy wszystkie możliwe kolory (nazwy muszą pasować do plików od Kenneya!)
var suits = ["Spades", "Hearts", "Diamonds", "Clubs"]
# Definiujemy wszystkie wartości
var values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

# Nasza wirtualna talia (pusta lista na start)
var cards_in_deck = []

func _ready():
	# Generujemy talię od razu po załadowaniu
	generate_deck()

func generate_deck():
	cards_in_deck.clear() # Czyścimy stół przed nowym rozdaniem
	
	# Pętla w pętli! Przechodzimy przez każdy kolor i każdą wartość
	for suit in suits:
		for value in values:
			# Zapisujemy kartę jako mały "Słownik" (Dictionary) w naszej liście
			var new_card = {"suit": suit, "value": value}
			cards_in_deck.append(new_card)
			
	# Najlepsza funkcja w Godocie: wbudowane, idealne tasowanie listy!
	cards_in_deck.shuffle() 
	print("Talia gotowa i potasowana! Mamy kart: ", cards_in_deck.size())

# Funkcja wyciągająca JEDNĄ kartę z góry talii
func draw_card() -> Dictionary:
	if cards_in_deck.size() > 0:
		# pop_back() bierze ostatni element z listy, ZWRACA GO, a potem USUWA z listy!
		# Idealna symulacja ciągnięcia karty ze stosu.
		return cards_in_deck.pop_back()
	else:
		print("Błąd: Talia jest pusta!")
		return {} # Zwraca pusty słownik, jeśli brakuje kart
