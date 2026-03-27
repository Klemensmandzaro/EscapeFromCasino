extends RigidBody3D

var is_rolling = false
var min_speed = 0.1 
var roll_timer = 0.0 

func _physics_process(delta):
	if is_rolling:
		
		roll_timer += delta
		
		if roll_timer > 0.5:
			if linear_velocity.length() < min_speed and angular_velocity.length() < min_speed:
				is_rolling = false

func roll():
	is_rolling = true
	roll_timer = 0.0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	contact_monitor = true
	max_contacts_reported = 1
	
	
	apply_central_impulse(Vector3(randf_range(-2, 2), randf_range(3, 5), randf_range(-2, 2)))
	apply_torque_impulse(Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-10, 10)))

func get_top_face_value() -> int:
	var faces = [
		{"dir": global_transform.basis.y, "val": 1},  # Lokalna góra kostki (+Y)
		{"dir": -global_transform.basis.y, "val": 6}, # Lokalny dół kostki (-Y)
		{"dir": global_transform.basis.x, "val": 5},  # Lokalna prawa strona (+X)
		{"dir": -global_transform.basis.x, "val": 2}, # Lokalna lewa strona (-X)
		{"dir": global_transform.basis.z, "val": 3},  # Lokalny przód (+Z)
		{"dir": -global_transform.basis.z, "val": 4}  # Lokalny tył (-Z)
	]
	
	var best_face = faces[0]
	var max_dot = -1.0 
	
	
	for face in faces:
		var dot_product = face.dir.dot(Vector3.UP)
		if dot_product > max_dot:
			max_dot = dot_product
			best_face = face
			
	return best_face.val


func _on_body_entered(body: Node) -> void:
	if linear_velocity.length() > 1.5:
		
		$HitSound.pitch_scale = randf_range(0.8, 1.2)
		$HitSound.play()
