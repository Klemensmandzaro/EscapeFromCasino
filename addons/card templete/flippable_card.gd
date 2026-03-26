class_name FlippableCard
extends Node2D

signal animation_finished(is_up: bool)

@export_category("State")
@export var is_up: bool = false:
	set(value):
		is_up = value
		queue_redraw()
@export var transition: bool = false
@export var can_flip_up: bool = true
@export var can_flip_down: bool = true

@export_category("Instant Mode")
@export var front_texture: Texture2D
@export var back_texture: Texture2D

@export_category("Transition Settings")
@export var transition_sheet: Texture2D
@export var frame_width: int = 64
@export var frame_height: int = 64
@export var sheet_rows: int = 1
@export var sheet_columns: int = 1
@export var sheet_frames: int = 1
@export var fps: float = 12.0
@export var speed_scale: float = 1.0

@export_category("Debug")
@export var debug_mode: bool = false

var _current_frame: int = 0
var _animating: bool = false
var _tween: Tween
var _last_frame_time: float = 0.0
var _anim_start_time: float = 0.0

func _draw() -> void:
	var tex: Texture2D
	var region: Rect2
	
	if _animating:
		tex = transition_sheet
		if tex:
			var column = _current_frame % sheet_columns
			var row = _current_frame / sheet_columns
			region = Rect2(column * frame_width, row * frame_height, frame_width, frame_height)
			
			if debug_mode:
				var current_time = Time.get_ticks_msec() / 1000.0
				var time_since_last = current_time - _last_frame_time
				var time_since_start = current_time - _anim_start_time
				print("Animation DEBUG | Frame: ", _current_frame, " | Col: ", column, " Row: ", row, 
					  " | Rect: ", region, " | Time since last frame: ", "%.3f" % time_since_last, 
					  "s | Total time: ", "%.3f" % time_since_start, "s")
				_last_frame_time = current_time
	else:
		tex = front_texture if is_up else back_texture
		if tex:
			region = Rect2(0, 0, tex.get_width(), tex.get_height())
	
	if tex:
		var draw_rect = Rect2(-region.size / 2, region.size)
		draw_texture_rect_region(tex, draw_rect, region, Color.WHITE)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var size = Vector2(frame_width, frame_height)
		var rect = Rect2(-size / 2, size)
		if rect.has_point(to_local(event.position)):
			if _animating: return
			get_viewport().set_input_as_handled()
			
			if is_up and can_flip_down:
				trigger_can_flip_down()
			elif not is_up and can_flip_up:
				trigger_can_flip_up()

func trigger_can_flip_up() -> void:
	if is_up: return
	if transition and transition_sheet:
		_run_transition(true)
	else:
		is_up = true

func trigger_can_flip_down() -> void:
	if not is_up: return
	if transition and transition_sheet:
		_run_transition(false)
	else:
		is_up = false

func _run_transition(target_up: bool) -> void:
	_animating = true
	if _tween: _tween.kill()
	_tween = create_tween()
	
	var frame_time = 1.0 / (fps * speed_scale)
	var start = 0
	var end = sheet_frames - 1
	
	if not target_up:
		start = sheet_frames - 1
		end = 0
	
	_current_frame = start
	_anim_start_time = Time.get_ticks_msec() / 1000.0
	_last_frame_time = _anim_start_time
	queue_redraw()
	
	if debug_mode:
		print("========== ANIMATION START ==========")
		print("Target state: ", "is_up" if target_up else "DOWN")
		print("Frame time: ", "%.3f" % frame_time, "s")
		print("Total frames: ", sheet_frames)
		print("Frames: ", start, " -> ", end)
	
	var direction = 1 if target_up else -1
	for i in range(1, sheet_frames):
		_tween.tween_interval(frame_time)
		_tween.tween_callback(func():
			_current_frame += direction
			queue_redraw()
		)
	
	_tween.tween_interval(frame_time)
	_tween.finished.connect(func(): _finish_anim(target_up))

func _finish_anim(target_up: bool) -> void:
	_animating = false
	is_up = target_up
	
	if debug_mode:
		var total_time = Time.get_ticks_msec() / 1000.0 - _anim_start_time
		print("========== ANIMATION END ==========")
		print("Final state: ", "is_up" if is_up else "DOWN")
		print("Total animation time: ", "%.3f" % total_time, "s")
	
	animation_finished.emit(is_up)
	queue_redraw()
