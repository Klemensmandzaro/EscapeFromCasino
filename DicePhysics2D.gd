extends Node2D

# Ścieżki do Twoich 6 tekstur kości (PNG) z Leonardo AI
var dice_textures = [
	preload("res://Graphics/kostka-1.png"),
	preload("res://Graphics/kostka-2.png"),
	preload("res://Graphics/kostka-3.png"),
	preload("res://Graphics/kostka-4.png"),
	preload("res://Graphics/kostka-5.png"),
	preload("res://Graphics/kostka-6.png")
]

# Zmienne trzymające węzły fizyczne i sprite'y
@onready var die1_rigid = $Die1_Rigid
@onready var die1_sprite = $Die1_Rigid/Sprite2D

@onready var die2_rigid = $Die2_Rigid
@onready var die2_sprite = $Die2_Rigid/Sprite2D

# Zmienne logiczne
var is_rolling = false
var min_speed_to_stop = 10.0 # Prędkość, poniżej której uznajemy kostkę za zatrzymaną

# Sygnał wysyłany po zakończeniu rzutu
signal roll_finished(result1, result2)

func _ready():
	# Ukrywamy kości na początku
	visible = false

func _process(_delta):
	if is_rolling:
		# Pobieramy prędkość kości
		var speed1 = die1_rigid.linear_velocity.length()
		var speed2 = die2_rigid.linear_velocity.length()
		
		# Jeśli pędzą szybko, szybko zmieniamy tekstury (visual flip)
		if speed1 > min_speed_to_stop * 5:
			die1_sprite.texture = dice_textures[randi() % 6]
		if speed2 > min_speed_to_stop * 5:
			die2_sprite.texture = dice_textures[randi() % 6]
			
		# Sprawdzamy, czy obie kości PRAWIE się zatrzymały
		if speed1 < min_speed_to_stop and speed2 < min_speed_to_stop:
			finish_roll()

# Funkcja uruchamiająca rzut
func roll():
	if is_rolling: return
	
	is_rolling = true
	visible = true
	
	# (Tutaj w przyszłości dodamy dźwięk "turrrrlik" 🔊)
	
	# Randomizujemy pozycję startową (np. tam gdzie ręka szulera)
	position = Vector2(randf_range(100, 300), randf_range(200, 400))
	
	# Dajemy kościom losowego "kopniaka" (Impulse)
	# Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(800, 1500)
	die1_rigid.apply_central_impulse(Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(1000, 2000))
	die2_rigid.apply_central_impulse(Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(1000, 2000))
	
	# Nadajemy im losową rotację początkową (Spinn)
	die1_rigid.apply_torque_impulse(randf_range(-5000, 5000))
	die2_rigid.apply_torque_impulse(randf_range(-5000, 5000))

# Funkcja kończąca rzut
func finish_roll():
	is_rolling = false
	
	# Losujemy ostateczny, logiczny wynik (1-6)
	var result1 = randi_range(1, 6)
	var result2 = randi_range(1, 6)
	
	# Ustawiamy tekstury finalnych, wylosowanych wyników (Ważne!)
	die1_sprite.texture = dice_textures[result1 - 1]
	die2_sprite.texture = dice_textures[result2 - 1]
	
	# Emitujemy sygnał z wynikami do gry
	emit_signal("roll_finished", result1, result2)
