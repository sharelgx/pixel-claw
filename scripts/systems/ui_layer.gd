extends CanvasLayer
## UI 层 - 显示时间、楼层、agent数量等信息

@onready var time_label: Label = $Panel/TimeLabel
@onready var floor_label: Label = $Panel/FloorLabel
@onready var agent_count_label: Label = $Panel/AgentCount
@onready var debug_label: Label = $Panel/DebugLabel

func _ready() -> void:
	# 连接时间系统信号
	var time_system = get_node("/root/TimeSystem") as TimeSystem
	if time_system:
		time_system.time_updated.connect(_on_time_updated)
		_on_time_updated(time_system.get_hour(), time_system.get_time_string().split(":")[1].to_int(), time_system.is_daytime)
	
	# 每帧更新 agent 计数
	set_physics_process(true)

func _process(delta: float) -> void:
	var agents = get_tree().get_nodes_in_group("agents")
	agent_count_label.text = "👥 Agents: %d" % agents.size()

func _on_time_updated(hour: int, minute: int, is_daytime: bool) -> void:
	var time_str = "%02d:%02d" % [hour, minute]
	time_label.text = "🕐 %s" % time_str
	
	# 颜色区分昼夜
	if is_daytime:
		time_label.modulate = Color(1.0, 1.0, 1.0)
	else:
		time_label.modulate = Color(0.7, 0.7, 1.0)
