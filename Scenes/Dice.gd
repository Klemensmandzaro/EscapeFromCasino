extends RigidBody2D

# Tworzymy własny sygnał, żeby kostka mogła "krzyknąć" do głównej gry: "Zatrzymałam się, to mój wynik!"
signal dice_stopped(result)

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Wyłączamy sprawdzanie zatrzymania na samym starcie
	set_process(false)

func roll_dice():
	# Włączamy animację turlania
	animated_sprite.play("default")
	
	# Nadajemy losowy impuls siły
	var random_force = Vector2(randf_range(-300, 300), randf_range(-600, -300))
	apply_central_impulse(random_force)
	apply_torque_impulse(randf_range(-200, 200))
	
	# --- NAPRAWA ---
	# Czekamy 0.5 sekundy (żeby kostka zdążyła nabrać prędkości w powietrzu)
	await get_tree().create_timer(0.5).timeout
	
	# Dopiero teraz zaczynamy co klatkę sprawdzać, czy kostka spadła i się zatrzymała
	set_process(true)

# To funkcja, która wykonuje się non-stop, gdy włączymy set_process(true)
func _process(_delta):
	# Sprawdzamy, czy prędkość ruchu i obrotu spadła prawie do zera
	if linear_velocity.length() < 2.0 and abs(angular_velocity) < 0.1:
		
		# Losujemy wynik od 1 do 6
		var final_result = randi_range(1, 6)
		
		# Zatrzymujemy animację
		animated_sprite.stop()
		
		# Ustawiamy odpowiednią klatkę. 
		# UWAGA: Klatki są liczone od 0! Więc dla wyniku 1, pokazujemy klatkę 0.
		animated_sprite.frame = final_result - 1 
		
		# Wysyłamy sygnał z wynikiem do głównej gry
		dice_stopped.emit(final_result)
		
		# Przestajemy sprawdzać ruch, bo kostka już stoi
		set_process(false)
