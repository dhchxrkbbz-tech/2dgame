## TimedChallengePuzzle - Időlimit alatti kihívások
## Switch nyomás / csapdák közötti futás / enemy megölés idő alatt
class_name TimedChallengePuzzle
extends PuzzleBase

enum ChallengeType { SWITCH_RUSH, TRAP_RUN, KILL_CHALLENGE }

var challenge_type: ChallengeType = ChallengeType.SWITCH_RUSH
var time_limit: float = 20.0
var time_remaining: float = 0.0
var is_timer_running: bool = false
var challenge_switches: Array[Dictionary] = []
var switches_activated: int = 0
var total_switches: int = 4

## UI
var timer_label: Label = null


func _build_puzzle() -> void:
	puzzle_type = "timed"
	
	if not room:
		return
	
	# Challenge típus random
	challenge_type = ChallengeType.values()[randi() % ChallengeType.size()]
	
	match challenge_type:
		ChallengeType.SWITCH_RUSH:
			time_limit = 15.0
			_build_switch_rush()
		ChallengeType.TRAP_RUN:
			time_limit = 20.0
			_build_trap_run()
		ChallengeType.KILL_CHALLENGE:
			time_limit = 30.0
			_build_kill_challenge()
	
	# Start switch a szoba közepén
	_create_start_switch()
	
	# Timer label
	timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.text = "%.1f" % time_limit
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.position = Vector2(-20, -40)
	timer_label.add_theme_font_size_override("font_size", 14)
	timer_label.add_theme_color_override("font_color", Color.YELLOW)
	timer_label.add_theme_color_override("font_outline_color", Color.BLACK)
	timer_label.add_theme_constant_override("outline_size", 2)
	timer_label.visible = false
	add_child(timer_label)


func _process(delta: float) -> void:
	if not is_timer_running:
		return
	
	time_remaining -= delta
	
	if timer_label:
		timer_label.text = "%.1f" % maxf(0, time_remaining)
		if time_remaining < 5.0:
			timer_label.add_theme_color_override("font_color", Color.RED)
	
	if time_remaining <= 0:
		is_timer_running = false
		_on_time_expired()


func _create_start_switch() -> void:
	var center := room.get_center()
	var world_pos := Vector2(center.x * Constants.TILE_SIZE, center.y * Constants.TILE_SIZE)
	
	var start_area := Area2D.new()
	start_area.name = "StartSwitch"
	start_area.global_position = world_pos
	start_area.collision_layer = 0
	start_area.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
	
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16
	shape.shape = circle
	start_area.add_child(shape)
	
	var sprite := Sprite2D.new()
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.8, 0.8, 0.0, 0.6))
	sprite.texture = ImageTexture.create_from_image(img)
	start_area.add_child(sprite)
	
	var label := Label.new()
	label.text = "START"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-16, -20)
	label.add_theme_font_size_override("font_size", 8)
	start_area.add_child(label)
	
	start_area.body_entered.connect(
		func(body):
			if body.is_in_group("player") and not is_timer_running and not is_solved:
				_start_challenge()
				start_area.queue_free()
	)
	
	add_child(start_area)


func _start_challenge() -> void:
	time_remaining = time_limit
	is_timer_running = true
	is_active = true
	
	if timer_label:
		timer_label.visible = true
	
	EventBus.show_notification.emit("Challenge Started!", Enums.NotificationType.WARNING)


func _build_switch_rush() -> void:
	total_switches = randi_range(4, 6)
	switches_activated = 0
	challenge_switches.clear()
	
	var tiles := room.get_tiles()
	var used: Array[Vector2i] = []
	
	for i in total_switches:
		var pos: Vector2i
		var attempts := 0
		while attempts < 20:
			pos = tiles[randi() % tiles.size()]
			if pos not in used:
				used.append(pos)
				break
			attempts += 1
		
		var world_pos := Vector2(pos.x * Constants.TILE_SIZE, pos.y * Constants.TILE_SIZE)
		
		var switch_area := Area2D.new()
		switch_area.name = "TimedSwitch_%d" % i
		switch_area.global_position = world_pos
		switch_area.collision_layer = 0
		switch_area.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
		
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(24, 24)
		shape.shape = rect
		switch_area.add_child(shape)
		
		var sprite := Sprite2D.new()
		var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.8, 0.3, 0.3, 0.7))
		sprite.texture = ImageTexture.create_from_image(img)
		switch_area.add_child(sprite)
		
		switch_area.visible = false  # Csak a challenge indulásakor látszik
		
		switch_area.body_entered.connect(
			func(body):
				if body.is_in_group("player") and is_timer_running:
					switches_activated += 1
					switch_area.queue_free()
					if switches_activated >= total_switches:
						solve()
		)
		
		add_child(switch_area)
		challenge_switches.append({"node": switch_area, "pos": pos})


func _build_trap_run() -> void:
	# A trap run egyszerűen a szoba végéig futás
	# A szoba trap-jei a TrapSystem-ből jönnek - itt csak jelöljük
	pass


func _build_kill_challenge() -> void:
	# Kill challenge: a wave spawner kezeli
	# Itt csak a time limit-et állítjuk
	pass


func _on_time_expired() -> void:
	if not is_solved:
		fail()
		EventBus.show_notification.emit("Time's Up!", Enums.NotificationType.WARNING)
		
		if timer_label:
			timer_label.add_theme_color_override("font_color", Color.DARK_RED)


func _on_solved() -> void:
	is_timer_running = false
	
	if timer_label:
		timer_label.add_theme_color_override("font_color", Color.GREEN)
		timer_label.text = "DONE!"
	
	EventBus.show_notification.emit("Challenge Complete! Bonus Loot!", Enums.NotificationType.LOOT)
	
	if room:
		spawn_reward_chest(room.get_world_center())


func _on_reset() -> void:
	is_timer_running = false
	time_remaining = 0
	switches_activated = 0
	
	if timer_label:
		timer_label.visible = false
	
	# Show switches again
	for sw in challenge_switches:
		if is_instance_valid(sw["node"]):
			sw["node"].visible = false
