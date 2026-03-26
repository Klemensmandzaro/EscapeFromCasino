extends RigidBody3D

var is_rolling = false
var min_speed = 0.1 
var roll_timer = 0.0 # NASZ NOWY BEZPIECZNIK CZASOWY

func _physics_process(delta):
	if is_rolling:
		# Zwiększamy czas od momentu rzutu
		roll_timer += delta
		
		# Zaczynamy sprawdzać prędkość DOPIERO po 0.5 sekundy lotu!
		if roll_timer > 0.5:
			if linear_velocity.length() < min_speed and angular_velocity.length() < min_speed:
				is_rolling = false

func roll():
	is_rolling = true
	roll_timer = 0.0
	# Resetujemy pęd
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	contact_monitor = true
	max_contacts_reported = 1
	
	# Rzucamy do góry i w bok
	apply_central_impulse(Vector3(randf_range(-2, 2), randf_range(3, 5), randf_range(-2, 2)))
	# Kręcimy we wszystkich osiach
	apply_torque_impulse(Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-10, 10)))

# TA FUNKCJA ZWRACA WYNIK (1-6)
func get_top_face_value() -> int:
	# Definiujemy, które LOKALNE osie kostki odpowiadają KTÓRYM wartościom (1-6).
	# Pamiętaj, że Fusion 360 eksportuje w Z-up, a Godot jest w Y-up,
	# więc model może być obrócony w nieoczekiwany sposób.
	# Musisz skalibrować te cyfry poniżej raz, na podstawie testów!
	var faces = [
		{"dir": global_transform.basis.y, "val": 1},  # Lokalna góra kostki (+Y)
		{"dir": -global_transform.basis.y, "val": 6}, # Lokalny dół kostki (-Y)
		{"dir": global_transform.basis.x, "val": 5},  # Lokalna prawa strona (+X)
		{"dir": -global_transform.basis.x, "val": 2}, # Lokalna lewa strona (-X)
		{"dir": global_transform.basis.z, "val": 3},  # Lokalny przód (+Z)
		{"dir": -global_transform.basis.z, "val": 4}  # Lokalny tył (-Z)
	]
	
	var best_face = faces[0]
	var max_dot = -1.0 # Wartość od -1 (przeciwnie) do 1 (identycznie)
	
	# Szukamy ścianki, która "patrzy" najbardziej pionowo w górę
	for face in faces:
		# Iloczyn skalarny (Dot Product) porównuje wektor ścianki z globalnym Vector3.UP
		var dot_product = face.dir.dot(Vector3.UP)
		if dot_product > max_dot:
			max_dot = dot_product
			best_face = face
			
	return best_face.val


func _on_body_entered(body: Node) -> void:
	# Sprawdzamy, czy uderzenie jest wystarczająco mocne (prędkość powyżej 1.5)
	# Zapobiega to brzęczeniu dźwięku, gdy kość już tylko leży i drży na stole
	if linear_velocity.length() > 1.5:
		
		
		# MAGIA PRO-GAMEDEVU: Za każdym uderzeniem delikatnie zmieniamy ton (Pitch)!
		# Dzięki temu jedno "stuknięcie" brzmi jak 100 różnych dźwięków i nie nudzi ucha.
		$HitSound.pitch_scale = randf_range(0.8, 1.2)
		
		# Odtwarzamy stukot!
		$HitSound.play()
