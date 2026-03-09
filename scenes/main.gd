extends Node2D
## 主场景 - 办公室世界入口

var current_floor: int = 2
var agents: Dictionary = {}

@onready var camera: Camera2D = $Camera2D
@onready var offices_parent: Node2D = $Offices

func _ready() -> void:
	# 确保系统单例存在
	_ensure_singletons()
	
	# 生成各楼层
	_generate_offices()
	
	# 生成 Agents
	_spawn_agents()
	
	# 初始视角到2楼
	_go_to_floor(2)
	
	print("\n=== OpenClaw Pixel Office 已启动 ===")
	print("操作指南：")
	print("  1-5   切换楼层")
	print("  空格  时间加速")
	print("  ~     调试控制台")
	print("==============================\n")

func _ensure_singletons() -> void:
	"""确保核心系统单例已添加到场景树"""
	var root = get_tree().root
	
	# GameSettings
	if not root.has_node("GameSettings"):
		var gs = load("res://scripts/systems/game_settings.gd").new()
		gs.name = "GameSettings"
		root.add_child(gs)
	
	# TimeSystem
	if not root.has_node("TimeSystem"):
		var ts = load("res://scripts/systems/time_system.gd").new()
		ts.name = "TimeSystem"
		root.add_child(ts)
	
	# TaskBoard
	if not root.has_node("TaskBoard"):
		var tb = load("res://scripts/systems/task_board.gd").new()
		tb.name = "TaskBoard"
		root.add_child(tb)
	
	# SyncManager
	if not root.has_node("SyncManager"):
		var sm = load("res://scripts/systems/sync_manager.gd").new()
		sm.name = "SyncManager"
		root.add_child(sm)

func _generate_offices() -> void:
	"""生成5个楼层场景"""
	for floor in range(1, 6):
		var office = Node2D.new()
		office.name = "Office_%d" % floor
		office.floor_number = floor
		office.visible = (floor == current_floor)
		
		# 地板背景色（每层略不同）
		var floor_rect = ColorRect.new()
		floor_rect.rect_size = Vector2(1200, 800)
		var gray = 0.92 - (floor * 0.04)
		floor_rect.color = Color(gray, gray, gray, 1.0)
		office.add_child(floor_rect)
		
		# 窗户（5层没有）
		if floor < 5:
			var window = ColorRect.new()
			window.rect_position = Vector2(800, 30)
			window.rect_size = Vector2(300, 150)
			window.color = Color(0.55, 0.75, 1.0, 0.6)
			office.add_child(window)
		
		# 茶水间（左侧）
		var kitchen = _create_kitchen(50, 50)
		office.add_child(kitchen)
		
		# 办公桌（数量递增）
		var desk_count = 1 + floor
		for i in range(desk_count):
			var x = 150 + i * 220
			var desk = _create_desk(x, 350)
			office.add_child(desk)
		
		# 会议室（4F+）
		if floor >= 4:
			var meeting = _create_meeting_room(850, 180)
			office.add_child(meeting)
		
		offices_parent.add_child(office)

func _create_desk(x: int, y: int) -> Node2D:
	"""创建办公桌（桌子+显示器+键盘）"""
	var desk = Node2D.new()
	desk.position = Vector2(x, y)
	
	var table = ColorRect.new()
	table.rect_size = Vector2(100, 60)
	table.color = Color(0.5, 0.35, 0.2, 1.0)
	desk.add_child(table)
	
	var monitor = ColorRect.new()
	monitor.rect_position = Vector2(15, -30)
	monitor.rect_size = Vector2(30, 22)
	monitor.color = Color(0.15, 0.15, 0.15, 1.0)
	desk.add_child(monitor)
	
	var keyboard = ColorRect.new()
	keyboard.rect_position = Vector2(20, 5)
	keyboard.rect_size = Vector2(25, 8)
	keyboard.color = Color(0.1, 0.1, 0.1, 1.0)
	desk.add_child(keyboard)
	
	return desk

func _create_kitchen(x: int, y: int) -> Node2D:
	"""创建茶水间"""
	var kitchen = Node2D.new()
	kitchen.position = Vector2(x, y)
	
	var counter = ColorRect.new()
	counter.rect_size = Vector2(80, 50)
	counter.color = Color(0.7, 0.7, 0.7, 1.0)
	kitchen.add_child(counter)
	
	var label = Label.new()
	label.text = "☕"
	label.position = Vector2(25, 5)
	kitchen.add_child(label)
	
	return kitchen

func _create_meeting_room(x: int, y: int) -> Node2D:
	"""创建会议室"""
	var room = Node2D.new()
	room.position = Vector2(x, y)
	
	var table = ColorRect.new()
	table.rect_size = Vector2(180, 100)
	table.color = Color(0.7, 0.7, 0.7, 1.0)
	room.add_child(table)
	
	var label = Label.new()
	label.text = "Meeting"
	label.position = Vector2(60, 40)
	label.modulate = Color(0.4, 0.4, 0.4, 1.0)
	room.add_child(label)
	
	return room

func _spawn_agents() -> void:
	"""生成所有 Agent 并放置到对应楼层"""
	var agent_classes = {
		"jarvis-feishu": preload("res://scripts/agents/jarvis.gd"),
		"corali-feishu": preload("res://scripts/agents/corali.gd"),
		"xiaoyuan-explore": preload("res://scripts/agents/xiaoyuan.gd"),
	}
	
	for agent_id in agent_classes:
		var script = agent_classes[agent_id]
		var agent = script.new()
		agent.agent_id = agent_id
		agent.name = agent_id
		
		# 根据 home_floor 放置到对应楼层
		var office_name = "Office_%d" % agent.home_floor
		var office = offices_parent.get_node(office_name)
		if office:
			office.add_child(agent)
			agents[agent_id] = agent
		else:
			# 如果楼层不存在，放到主场景
			add_child(agent)
			agents[agent_id] = agent
			print("[Main] 警告: %s 的楼层 %d 不存在，放到主场景" % [agent_id, agent.home_floor])
	
	print("[Main] 已生成 %d 个 Agent" % agents.size())
	
	# 延迟 0.5 秒后强制刷新一次任务状态（确保 TaskBoard 已加载）
	await get_tree().create_timer(0.5).timeout
	_force_assign_tasks()

func _force_assign_tasks() -> void:
	"""强制为已存在的 agent 分配当前任务"""
	var task_board = get_node("/root/TaskBoard") as TaskBoard
	if not task_board:
		return
	
	for agent_id in agents:
		var agent = agents[agent_id]
		var tasks = task_board.get_tasks_by_owner(agent_id)
		if tasks.size() > 0:
			agent.set_task(tasks[0])
			print("[Main] 已为 %s 分配任务: %s" % [agent_id, tasks[0].get("title", "无标题")])
		else:
			print("[Main] %s 当前无任务" % agent_id)

func _go_to_floor(floor: int) -> void:
	"""切换到指定楼层"""
	if floor < 1 or floor > 5:
		return
	
	current_floor = floor
	
	# 切换楼层可见性
	for office in offices_parent.get_children():
		office.visible = (office.floor_number == floor)
	
	# 相机移动到该楼层中心
	var target_office = offices_parent.get_node("Office_%d" % floor)
	if target_office:
		camera.global_position = target_office.global_position + Vector2(400, 300)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1, KEY_KP_1:
				_go_to_floor(1)
			KEY_2, KEY_KP_2:
				_go_to_floor(2)
			KEY_3, KEY_KP_3:
				_go_to_floor(3)
			KEY_4, KEY_KP_4:
				_go_to_floor(4)
			KEY_5, KEY_KP_5:
				_go_to_floor(5)
			KEY_SPACE:
				_toggle_time_acceleration()
			KEY_TILDE:
				_open_debug_console()

func _toggle_time_acceleration() -> void:
	"""空格键切换时间流速"""
	var ts = get_node("/root/TimeSystem") as TimeSystem
	if ts:
		var speeds = [1.0, 2.0, 5.0, 0.0]
		var idx = speeds.find(ts.time_speed)
		var next = speeds[(idx + 1) % speeds.size()]
		ts.accelerate(next)
		print("[Main] 时间流速: %.1fx" % next)

func _open_debug_console() -> void:
	"""打开调试控制台（打印命令列表）"""
	print("\n=== 调试控制台 ===")
	print("命令列表：")
	print("  task list [status]      - 列出所有任务")
	print("  agent <id> status       - 查看 Agent 状态")
	print("  time <speed>            - 设置时间流速 (0.5, 1, 2, 5)")
	print("  floor <n>               - 跳转到楼层 (1-5)")
	print("  agents                  - 显示所有 Agents")
	print("=======================\n")
