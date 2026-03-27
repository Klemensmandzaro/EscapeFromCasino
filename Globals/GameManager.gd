extends Node


signal money_changed(new_amount)
signal level_changed(new_level)
signal level_max(new_max)

var music_player: AudioStreamPlayer
var playlist: Array = [
	preload("res://Audio/Music/denis-pavlov-music-jazz-podcast-night-relaxing-vibes-242886.mp3"),
	preload("res://Audio/Music/denis-pavlov-music-podcast-jazz-easy-listening-music-219314.mp3"),
	preload("res://Audio/Music/denis-pavlov-music-podcast-jazz-music-168726.mp3"),
	preload("res://Audio/Music/surprising_media-cool-jazz-with-sax-1-481596.mp3"),
	preload("res://Audio/Music/surprising_media-cool-jazz-with-sax-2-482959.mp3"),
	preload("res://Audio/Music/surprising_media-smoked-glass-keys-piano-dark-jazz-504005.mp3")
]


var vip_points: int = 0  


var upgrade_starting_money_level: int = 0 
var magnet_level: int = 0   
var survival_level: int = 0
var is_first_time_playing: bool = true

var total_run_levels: int = 0

var default_starting_money: int = 50
var current_money: int = 50
var current_level: int = 1
var max_level: int = 5
var peak_money_this_level: int = 0 
var player_class: int = 1


var level_requirements = [0, 300, 500, 800, 1000, 1500]


var total_playtime: float = 0.0
var is_timer_running: bool = false

func _process(delta: float) -> void:
	if is_timer_running:
		total_playtime += delta
		
func _ready():

	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -15.0 
	
	add_child(music_player)
	music_player.finished.connect(play_next_song)
	play_next_song()

func play_next_song():
	if playlist.is_empty():
		return
		
	var random_index = randi() % playlist.size()
	music_player.stream = playlist[random_index]
	music_player.play()

func resume_timer():
	is_timer_running = true

func stop_run_timer():
	is_timer_running = false

func get_formatted_time() -> String:
	var mins = int(total_playtime) / 60
	var secs = int(total_playtime) % 60
	var ms = int((total_playtime - int(total_playtime)) * 100)
	return "%02d:%02d.%02d" % [mins, secs, ms]

func add_money(amount: int):
	current_money += amount
	money_changed.emit(current_money)
	if current_money > peak_money_this_level:
		peak_money_this_level = current_money
	if can_progress():
		current_money=default_starting_money
		next_level()

func can_progress() -> bool:
	if current_level > max_level:
		return false 
		
	var required_money = level_requirements[current_level]
	return current_money >= required_money

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
	
func reset_game():
	current_level = 1
	peak_money_this_level = current_money
	if player_class == 1:
		default_starting_money = 100 + (100*upgrade_starting_money_level*0.1)
	else:
		default_starting_money = 50 + (50*upgrade_starting_money_level*0.1)
		
	current_money = default_starting_money
	
	level_changed.emit(current_level)
	money_changed.emit(current_money)
	
func calculate_score(target_money_for_next_level: int) -> int:
	var levels_passed = total_run_levels
	if levels_passed == 0:
		return -500
	var level_score = levels_passed * 1000 
	var percentage = float(peak_money_this_level) / float(target_money_for_next_level)
	print(percentage)
	
	
	percentage = clamp(percentage, 0.0, 1.0)
	
	
	var money_score = int(percentage * 1000) 
	print(level_score + money_score)
	return level_score + money_score
	

func hard_reset():
	vip_points = 0
	total_run_levels = 0
	upgrade_starting_money_level = 0
	magnet_level = 0
	survival_level = 0
	is_first_time_playing = true
	
	current_level = 1
	player_class = 1
	reset_game()
