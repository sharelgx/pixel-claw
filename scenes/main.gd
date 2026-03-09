extends Node2D
## 主场景 - 办公室世界入口 (使用 Sprite2D 实现纯色块)

var current_floor: int = 2
var agents: Dictionary = {}

@onready var camera: Camera2D = $Camera2D
@onready var offices_parent: Node2D = $Offices

func _ready() -> void:
	_ensure_singletons()
	_generate_offices()
	_spawn_agents()
	_go_to_floor(2)
	
	print("\n=== Pixel-Claw 已启动 ===")
	print("按键: 1-5切换楼层, 空格加速, F12调试")
	print("========================\n")

func _ensure_singletons() -> void:
	var root = get_tree().root
	if not root.has_node("GameSettings"):
		root.add_child(load("res://scripts/systems/game_settings.gd").new())
	if not root.has_node("TimeSystem"):
		root.add_child(load("res://scripts/systems/time_system.gd").new())
	if not root.has_node("TaskBoard"):
		root.add_child(load("res://scripts/systems/task_board.gd").new())
	if not root.has_node("SyncManager"):
		root.add_child(load("res://scripts/systems/sync_manager.gd").new())

func _generate_offices() -> void:
	for floor in range(1, 6):
		var office = Node2D.new()
		office.name = "Office_%d" % floor
		office.set_meta("floor", floor)
		office.visible = (floor == current_floor)
		
		# 地板 - 使用 Sprite2D + 纯色图片
		var floor_bg = _create_color_sprite(Vector2(1200, 800), Color(0.92 - floor*0.04, 0.92 - floor*0.04, 0.92 - floor*0.04, 1.0))
		office.add_child(floor_bg)
		
		# 窗户 (5楼无)
		if floor < 5:
			var win = _create_color_sprite(Vector2(300, 150), Color(0.55, 0.75, 1.0, 0.6))
			win.position = Vector2(800, 30)
			office.add_child(win)
		
		# 茶水间
		var kitchen = _create_kitchen()
		kitchen.position = Vector2(50, 50)
		office.add_child(kitchen)
		
		# 办公桌
		var desk_count = 1 + floor
		for i in range(desk_count):
			var desk = _create_desk()
			desk.position = Vector2(150 + i * 220, 350)
			office.add_child(desk)
		
		# 会议室 (4F+)
		if floor >= 4:
			var meeting = _create_meeting()
			meeting.position = Vector2(850, 180)
			office.add_child(meeting)
		
		offices_parent.add_child(office)

func _create_color_sprite(size: Vector2, color: Color) -> Sprite2D:
	"""创建一个纯色 Sprite2D（使用 ImageTexture）"""
	var img = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	img.fill(color)
	var tex = ImageTexture.create_from_image(img)
	
	var sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.centered = false
	return sprite

func _create_desk() -> Node2D:
	var desk = Node2D.new()
	
	# 桌面
	var table = _create_color_sprite(Vector2(100, 60), Color(0.5, 0.35, 0.2, 1.0))
	desk.add_child(table)
	
	# 显示器
	var monitor = _create_color_sprite(Vector2(30, 22), Color(0.15, 0.15, 0.15, 1.0))
	monitor.position = Vector2(15, -30)
	desk.add_child(monitor)
	
	# 键盘
	var keyboard = _create_color_sprite(Vector2(25, 8), Color(0.1, 0.1, 0.1, 1.0))
	keyboard.position = Vector2(20, 5)
	desk.add_child(keyboard)
	
	return desk

func _create_kitchen() -> Node2D:
	var kitchen = Node2D.new()
	
	var counter = _create_color_sprite(Vector2(80, 50), Color(0.7, 0.7, 0.7, 1.0))
	kitchen.add_child(counter)
	
	var label = Label.new()
	label.text = "☕"
	label.position = Vector2(25, 5)
	kitchen.add_child(label)
	
	return kitchen

func _create_meeting() -> Node2D:
	var room = Node2D.new()
	
	var table = _create_color_sprite(Vector2(180, 100), Color(0.7, 0.7, 0.7, 1.0))
	room.add_child(table)
	
	var label = Label.new()
	label.text = "Meet"
	label.position = Vector2(60, 40)
	label.modulate = Color(0.4, 0.4, 0.4, 1.0)
	room.add_child(label)
	
	return room

func _spawn_agents() -> void:
	"""生成所有 Agent 并放置到对应楼层"""
	var agent_info = {
		"jarvis-feishu": { "color": Color(0.2, 0.6, 1.0), "floor": 2, "pos": Vector2(300, 200), "label": "J" },
		"corali-feishu": { "color": Color(1.0, 0.4, 0.8), "floor": 2, "pos": Vector2(500, 200), "label": "C" },
		"xiaoyuan-explore": { "color": Color(0.8, 0.2, 0.2), "floor": 3, "pos": Vector2(400, 250), "label": "X" },
	}
	
	for agent_id in agent_info:
		var info = agent_info[agent_id]
		
		# 创建 Agent 节点
		var agent = Node2D.new()
		agent.name = agent_id
		agent.position = info.pos
		agent.set_meta("agent_id", agent_id)
		agent.set_meta("state", "idle")
		agent.set_meta("target", info.pos)
		agent.set_meta("speed", 40.0)
		
		# 视觉：像素块 (使用 Sprite2D)
		var body = _create_color_sprite(Vector2(24, 32), info.color)
		body.position = Vector2(-12, -32)
		agent.add_child(body)
		
		# 名字标签
		var name_label = Label.new()
		name_label.text = info.label
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.position = Vector2(-12, -40)
		name_label.add_theme_font_size_override("font_size", 8)
		agent.add_child(name_label)
		
		# 放置到对应楼层
		var office = offices_parent.get_node("Office_%d" % info.floor)
		if office:
			office.add_child(agent)
			agents[agent_id] = agent
		else:
			add_child(agent)
			agents[agent_id] = agent
			print("[Main] 警告: %s 的楼层 %d 不存在" % [agent_id, info.floor])
	
	print("[Main] 已生成 %d 个 Agent" % agents.size())

func _go_to_floor(floor: int) -> void:
	if floor < 1 or floor > 5:
		return
	
	current_floor = floor
	
	# 切换可见性
	for office in offices_parent.get_children():
		var office_floor = office.get_meta("floor")
		office.visible = (office_floor == floor)
	
	# 相机
	var target = offices_parent.get_node("Office_%d" % floor)
	if target:
		camera.global_position = target.global_position + Vector2(400, 300)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _go_to_floor(1)
			KEY_2: _go_to_floor(2)
			KEY_3: _go_to_floor(3)
			KEY_4: _go_to_floor(4)
			KEY_5: _go_to_floor(5)
			KEY_SPACE: _toggle_time()
			KEY_F12: _open_debug_console()

func _toggle_time() -> void:
	var ts = get_node("/root/TimeSystem") as TimeSystem
	if ts:
		var speeds = [1.0, 2.0, 5.0, 0.0]
		var idx = speeds.find(ts.time_speed)
		ts.accelerate(speeds[(idx + 1) % speeds.size()])

func _open_debug_console() -> void:
	print("\n=== 调试控制台 ===")
	print("命令: task list, agent <id>, time <speed>, floor <n>, agents")
	print("=======================\n")

func _process(delta: float) -> void:
	# 让所有 Agent 移动起来
	for agent_id in agents:
		var a = agents[agent_id]
		var state = a.get_meta("state")
		if state == "walking":
			var target = a.get_meta("target")
			var speed = a.get_meta("speed")
			var dir = (target - a.position).normalized()
			if dir.length() > 0:
				a.position += dir * speed * delta
			if a.position.distance_to(target) < 5.0:
				a.position = target
				a.set_meta("state", "idle")
		elif state == "idle":
			# 随机走动
			if randf() < 0.005:
				var bounds = Rect2(150, 100, 800, 500)
				var new_target = Vector2(
					randi_range(bounds.position.x, bounds.position.x + bounds.size.x),
					randi_range(bounds.position.y, bounds.position.y + bounds.size.y)
				)
				a.set_meta("target", new_target)
				a.set_meta("state", "walking")
