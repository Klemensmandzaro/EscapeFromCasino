extends Resource
class_name ClassData # To rejestruje naszą klasę w silniku Godot!

# Słowo @export sprawia, że te zmienne będą widoczne w oknie Inspektora
@export var character_name: String = "Nieznajomy"
@export var description: String = "Opis klasy"
@export var starting_money: int = 100
# Tutaj w przyszłości możemy dodać np. specjalne umiejętności
