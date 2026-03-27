extends TextureRect


func _ready():
	update_background(GameManager.current_level)
	GameManager.level_changed.connect(update_background)


func update_background(new_level: int):
	var image_path = "res://Graphics/table_lvl" + str(new_level) + ".jpg"
	var new_texture = load(image_path)
	
	if new_texture:
		texture = new_texture
		print("Tło zmienione na poziom: ", new_level)
	else:
		printerr("BŁĄD: Nie znaleziono obrazka tła pod ścieżką: ", image_path)
