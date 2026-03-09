extends CanvasLayer
## UI 层 - 显示时间、楼层、Agent 数量等信息

@onready var time_label: Label = $Panel/TimeLabel
@onready var floor_label: Label = $Panel/FloorLabel
@onready var agent_count_label: Label = $Panel/AgentCount
@onready var debug_label: Label = $Panel/DebugLabel

func _ready() -> void:
	# 连接时间系统信号
	var time_system = get_node("/root/TimeSystem") as TimeSystem
	if time_system:
		time_system.time_updated.connect(_on_time_updated)
		# 初始化显示
		var hour = time_system.get_hour()
		var minute = int(time_system.game_time / 60.0) % 60
		_on_time_updated(hour, minute, time_system.is_daytime)
	
	# 启动 Agent 计数更新定时器
	set_physics_process(true)

func _process(delta: float) -> void:
	# 实时更新 Agent 计数
	var agents = get_tree().get_nodes_in_group("agents")
	agent_count_label.text = "👥 Agents: %d" % agents.size()

func _on_time_updated(hour: int, minute: int, is_daytime: bool) -> void:
	var time_str = "%02d:%02d" % [hour, minute]
	time_label.text = "🕐 %s" % time_str
	
	# 根据昼夜调整颜色
	if is_daytime:
		time_label.modulate = Color(1.0, 1.0, 1.0)
	else:
		time_label.modulate = Color(0.7, 0.7, 1.0)
