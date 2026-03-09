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

# 视觉元素
var sprite: ColorRect
var name_label: Label
var thought_bubble: Label

func _ready() -> void:
	add_to_group("agents")
	_create_visuals()
	position = home_position
	target_position = home_position
	
	# 连接任务板
	var task_board = get_node("/root/TaskBoard") as TaskBoard
	if task_board:
		task_board.task_updated.connect(_on_task_updated)
	
	print("[Agent:%s] %s 已就位" % [agent_id, display_name])

func _create_visuals() -> void:
	# 主体颜色块（像素人）
	sprite = ColorRect.new()
	sprite.rect_size = Vector2(20, 28)
	sprite.color = agent_color
	sprite.position = Vector2(-10, -28)
	add_child(sprite)
	
	# 名字标签
	name_label = Label.new()
	name_label.text = display_name if display_name != "" else agent_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(-25, -35)
	name_label.add_theme_font_size_override("font_size", 8)
	add_child(name_label)
	
	# 思想气泡
	thought_bubble = Label.new()
	thought_bubble.text = ""
	thought_bubble.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thought_bubble.add_theme_font_size_override("font_size", 7)
	thought_bubble.visible = false
	thought_bubble.position = Vector2(-15, -48)
	add_child(thought_bubble)

func _process(delta: float) -> void:
	match current_state:
		AgentState.WORKING:
			work_animation_timer += delta
			var offset = sin(work_animation_timer * 12) * 1.5
			sprite.position.y = -28.0 + offset
		AgentState.WALKING:
			_move_toward_target(delta)
		AgentState.ERROR:
			# 闪烁
			sprite.modulate.a = 0.6 + 0.4 * sin(Time.get_ticks_msec() * 0.015)
		AgentState.IDLE:
			# 空闲时微妙的呼吸效果
			var breathe = sin(Time.get_ticks_msec() * 0.003) * 0.5 + 0.5
			sprite.modulate.a = 0.8 + 0.2 * breathe
			# 小概率触发随机行为
			if randf() < 0.005:  # ~每3分钟一次（假设60fps）
				_trigger_random_idle_action()
		_:
			pass
	
	_update_thought_bubble()

func _move_toward_target(delta: float) -> void:
	var direction = (target_position - position).normalized()
	if direction.length() > 0:
		position += direction * movement_speed * delta
	
	if position.distance_to(target_position) < 4.0:
		position = target_position
		current_state = AgentState.IDLE
		sprite.position.y = -28.0
		sprite.modulate.a = 1.0

func _trigger_random_idle_action() -> void:
	if randf() < 0.5:
		_go_drink_coffee()
	else:
		_go_random_walk()

func _go_drink_coffee() -> void:
	current_state = AgentState.DRINKING
	_update_thought_bubble()
	await get_tree().create_timer(2.0 + randf() * 2.0).timeout
	current_state = AgentState.IDLE

func _go_random_walk() -> void:
	var bounds = Rect2(150, 100, 800, 500)  # 办公室范围
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
				text = "💼 %s" % current_task["title"].substr(0, 16)
		AgentState.DRINKING:
			text = "☕"
		AgentState.ERROR:
			text = "❌"
		AgentState.MEETING:
			text = "🤝"
		AgentState.WALKING:
			text = "🚶"
	
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
