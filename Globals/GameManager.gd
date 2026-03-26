extends Node

# Sygnały pozwalają informować inne sceny (np. UI), że coś się zmieniło
signal money_changed(new_amount)
signal level_changed(new_level)
signal level_max(new_max)

# --- WALUTA I SKLEP ---
var vip_points: int = 0  # <--- TA ZMIENNA MUSI TU BYĆ (bez wcięć)

# Poziomy ulepszeń
var upgrade_starting_money_level: int = 0 
var magnet_level: int = 0   
var survival_level: int = 0
var is_first_time_playing: bool = true

var total_run_levels: int = 0

var default_starting_money: int = 50
var current_money: int = 50
var current_level: int = 1
var max_level: int = 5
var peak_money_this_level: int = 0 # Najwięcej gotówki, jaką mieliśmy na obecnym poziomie
# 1 = Bogacz, 2 = Ryzykant, 3 = Szuler
var player_class: int = 1

# Ile pieniędzy gracz musi MIEĆ, aby przejść na kolejny poziom.
var level_requirements = [0, 300, 500, 800, 1000, 1500]

# --- ZMIENNE ZEGARA W GAMEMANAGERZE ---
var total_playtime: float = 0.0
var is_timer_running: bool = false

func _process(delta: float) -> void:
	if is_timer_running:
		total_playtime += delta

# ZMIANA: Ta funkcja teraz TYLKO odpala/wznawia stoper. Nie zeruje go!
func resume_timer():
	is_timer_running = true

func stop_run_timer():
	is_timer_running = false

func get_formatted_time() -> String:
	var mins = int(total_playtime) / 60
	var secs = int(total_playtime) % 60
	var ms = int((total_playtime - int(total_playtime)) * 100)
	return "%02d:%02d.%02d" % [mins, secs, ms]

# Funkcja dodająca (lub odejmująca) pieniądze
func add_money(amount: int):
	current_money += amount
	money_changed.emit(current_money)
	if current_money > peak_money_this_level:
		peak_money_this_level = current_money
	if can_progress():
		current_money=default_starting_money
		next_level()

# Funkcja sprawdzająca, czy możemy iść dalej
func can_progress() -> bool:
	if current_level > max_level:
		return false 
		
	var required_money = level_requirements[current_level]
	return current_money >= required_money

# Funkcja awansująca gracza
func next_level():
	
	current_level += 1
	total_run_levels += 1
	if current_level<=5:
		level_changed.emit(current_level)
	else:
		level_max.emit(current_level)
		return
	peak_money_this_level = current_money
	print("Udało się! Twój nowy poziom to: ", current_level)
	money_changed.emit(current_money)
	
	
# Funkcja resetująca całą grę po bankructwie
func reset_game():
	current_level = 1
	peak_money_this_level = current_money
	# Sprawdzamy, czy gracz wybrał Bogacza (klasa nr 1)
	if player_class == 1:
		default_starting_money = 100 + (100*upgrade_starting_money_level*0.1)
	else:
		default_starting_money = 50 + (50*upgrade_starting_money_level*0.1)
		
	current_money = default_starting_money
	
	level_changed.emit(current_level)
	money_changed.emit(current_money)
	
func calculate_score(target_money_for_next_level: int) -> int:
	var levels_passed = total_run_levels - 1
	var level_score = levels_passed * 1000 # 1000 punktów za każdy ukończony poziom!
	
	# Obliczamy procent postępu (od 0.0 do 1.0) na podstawie naszego rekordu
	var percentage = float(peak_money_this_level) / float(target_money_for_next_level)
	
	# Zabezpieczenie (clamp), żeby procent nie przekroczył 1.0 (czyli 100%)
	percentage = clamp(percentage, 0.0, 1.0)
	
	# Zamieniamy procent na punkty (np. 50% = 500 punktów)
	var money_score = int(percentage * 1000) 
	
	return level_score + money_score
	
	# --- TWARDY RESET (NOWA GRA) ---
func hard_reset():
	vip_points = 0
	total_run_levels = 0
	upgrade_starting_money_level = 0
	magnet_level = 0
	survival_level = 0
	is_first_time_playing = true
	# Resetujemy też poziom i kasę na startową
	current_level = 1
	player_class = 1 # Domyślnie wracamy do Bogacza
	reset_game() # Używamy Twojej wcześniejszej funkcji, żeby przeliczyła kasę
