extends Control

# Szukamy naszego węzła z tekstem
@onready var money_label = $Button

func _ready():
	# Na starcie gry ustawiamy tekst na to, co ma GameManager (czyli 0)
	update_money_text(GameManager.current_money)
	
	# Podłączamy się do sygnału z GameManagera
	GameManager.money_changed.connect(update_money_text)

# Ta funkcja wywoła się automatycznie za każdym razem, gdy stan konta się zmieni
func update_money_text(new_amount):
	money_label.text = str(new_amount)
