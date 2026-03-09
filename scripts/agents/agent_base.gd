extends Node2D
## Agent 基类 - 所有 NPC 的父类（纯代码生成，无需外部资源）

class_name Agent

enum AgentState { IDLE, WORKING, DRINKING, MEETING, ERROR, WALKING }

@export var agent_id: String = ""
@export var agent_name: String = "Agent"
@export var display_name: String = ""
@export var agent_color: Color = Color.WHITE
@export var home_floor: int = 2
@export var home_position: Vector2 = Vector2.ZERO

var current_state: AgentState = AgentState.IDLE
var current_task: Dictionary = {}
var target_position: Vector2 = Vector2.ZERO
var movement_speed: float = 32.0  # 像素/秒
var work_animation_timer: float = 0.0

# 视觉元素（运行时创建）
var sprite: ColorRect
var name_label: Label
var thought_bubble: Label

func _ready() -> void:
	add_to_group("agents")
	_create_visuals()
	position = home_position
	target_position = home_position
	
	# 连接任务板信号
	var task_board = get_node("/root/TaskBoard") as TaskBoard
	if task_board:
		task_board.task_updated.connect(_on_task_updated)
	
	# 启动随机行为定时器
	var idle_timer = Timer.new()
	idle_timer.wait_time = 3.0
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	idle_timer.name = "IdleTimer"
	add_child(idle_timer)
	idle_timer.start()
	
	print("[Agent:%s] %s 已就位，位置: %s" % [agent_id, display_name, home_position])

func _create_visuals() -> void:
	# Agent 主体（像素人方块）
	sprite = ColorRect.new()
	sprite.rect_size = Vector2(20, 28)
	sprite.color = agent_color
	sprite.position = Vector2(-10, -28)  # 中心对齐
	add_child(sprite)
	
	# 名字标签
	name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = display_name if display_name != "" else agent_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(-25, -35)
	name_label.add_theme_font_size_override("font_size", 8)
	add_child(name_label)
	
	# 思想气泡（任务/状态提示）
	thought_bubble = Label.new()
	thought_bubble.name = "ThoughtBubble"
	thought_bubble.text = ""
	thought_bubble.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thought_bubble.add_theme_font_size_override("font_size", 7)
	thought_bubble.visible = false
	thought_bubble.position = Vector2(-15, -48)
	add_child(thought_bubble)

func _process(delta: float) -> void:
	# 移动处理
	if current_state == AgentState.WALKING:
		_move_toward_target(delta)
	
	# 工作动画（打字抖动） - 更快更流畅
	if current_state == AgentState.WORKING:
		work_animation_timer += delta
		var offset = sin(work_animation_timer * 20) * 1.2
		sprite.position.y = -28.0 + offset
		thought_bubble.visible = true
	elif current_state == AgentState.DRINKING:
		sprite.position.y = -28.0
		thought_bubble.visible = true
	else:
		sprite.position.y = -28.0
		thought_bubble.visible = (current_state != AgentState.IDLE)

func _move_toward_target(delta: float) -> void:
	var direction = (target_position - position).normalized()
	if direction.length() > 0:
		position += direction * movement_speed * delta
	
	if position.distance_to(target_position) < 4.0:
		position = target_position
		current_state = AgentState.IDLE

func _on_idle_timer_timeout() -> void:
	if current_state == AgentState.IDLE:
		_trigger_random_idle_action()

func _trigger_random_idle_action() -> void:
	# 空闲时小概率触发随机行为（摸鱼、走动）
	if randf() < 0.3:
		_go_drink_coffee()
	elif randf() < 0.5:
		_go_random_walk()

func _go_drink_coffee() -> void:
	current_state = AgentState.DRINKING
	_update_thought_bubble()
	await get_tree().create_timer(2.0 + randf() * 2.0).timeout
	current_state = AgentState.IDLE

func _go_random_walk() -> void:
	# 在办公室区域内随机游走（子类可重写此函数来自定义范围）
	var bounds = Rect2(100, 100, 800, 500)
	target_position = Vector2(
		randi_range(bounds.position.x, bounds.position.x + bounds.size.x),
		randi_range(bounds.position.y, bounds.position.y + bounds.size.y)
	)
	current_state = AgentState.WALKING

func set_task(task: Dictionary) -> void:
	current_task = task
	if task.has("status"):
		match task["status"]:
			"TODO", "PENDING":
				current_state = AgentState.IDLE
			"IN_PROGRESS":
				current_state = AgentState.WORKING
			"DONE":
				current_state = AgentState.IDLE
			"BLOCKED":
				current_state = AgentState.ERROR
	_update_thought_bubble()

func _update_thought_bubble() -> void:
	var text = ""
	match current_state:
		AgentState.WORKING:
			if current_task.has("title"):
				# 直接显示任务标题，不超过 12 字（确保可读）
				text = "💼 %s" % current_task["title"].substr(0, 12)
			else:
				text = "💼 工作中"
		AgentState.DRINKING:
			text = "☕"
		AgentState.ERROR:
			# 显示阻塞原因（如果有）
			if current_task.has("notes") and current_task["notes"] != "":
				text = "❌ %s" % current_task["notes"].substr(0, 8)
			else:
				text = "❌ 阻塞"
		AgentState.MEETING:
			text = "🤝 会议"
		AgentState.WALKING:
			text = "🚶"
		AgentState.IDLE:
			# 空闲时偶尔显示 thought bubble 提示
			if randf() < 0.3:
				text = ["😊", "💭", "🎵"][randi() % 3]
			else:
				text = ""
	
	thought_bubble.text = text
	thought_bubble.visible = (text != "")

func _on_task_updated(task_id: String, task_data: Dictionary) -> void:
	if task_data["owner"] == agent_id:
		set_task(task_data)
		print("[Agent:%s] 任务更新: %s → %s" % [agent_id, task_id, task_data["status"]])

func receive_activity(action: String, details: String = "") -> void:
	# 由 SyncManager 转发真实活动
	match action:
		"message_received":
			current_state = AgentState.WORKING
			_update_thought_bubble()
		"task_assigned":
			set_task({"title": details, "status": "IN_PROGRESS"})
		"error_occurred":
			current_state = AgentState.ERROR
			_update_thought_bubble()
