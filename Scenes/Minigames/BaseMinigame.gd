extends Node
class_name BaseMinigame

# Funkcja wywoływana na końcu rundy, wspólna dla wszystkich gier
func end_round(payout: int):
	# Komunikujemy się z naszym Autoloadem, żeby dodał (lub odjął) pieniądze
	GameManager.add_money(payout)
