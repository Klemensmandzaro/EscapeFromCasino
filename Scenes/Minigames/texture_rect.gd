extends TextureRect

# Ta funkcja uruchamia się na samym początku, gdy wchodzi poziom
func _ready():
	# Najpierw ustawiamy tło dla obecnego poziomu (na start: 1)
	update_background(GameManager.current_level)
	
	# Teraz prosimy GameManager, żeby dał nam znać, gdy poziom się zmieni
	# Łączymy sygnał 'level_changed' z naszą funkcją 'update_background'
	GameManager.level_changed.connect(update_background)

# Ta funkcja automatycznie podmienia obrazek
func update_background(new_level: int):
	# Tworzymy ścieżkę do pliku na podstawie numeru poziomu.
	# Jeśli Twoje pliki nazywają się np. table_lv1.jpg, użyj tego:
	var image_path = "res://Graphics/table_lvl" + str(new_level) + ".jpg"
	
	# Ładujemy obrazek z dysku
	var new_texture = load(image_path)
	
	# Sprawdzamy, czy obrazek na pewno istnieje (żeby gra się nie wywaliła)
	if new_texture:
		# Ustawiamy nową teksturę dla naszego tła
		texture = new_texture
		print("Tło zmienione na poziom: ", new_level)
	else:
		printerr("BŁĄD: Nie znaleziono obrazka tła pod ścieżką: ", image_path)
