extends Agent

func _ready() -> void:
	agent_id = "corali-feishu"
	agent_name = "克拉瑞"
	display_name = "Corali"
	agent_color = Color(1.0, 0.4, 0.8)  # 粉红色
	home_floor = 2
	home_position = Vector2(500, 200)
	
	sprite.color = agent_color
	
	# 克拉瑞：每20分钟休息一下
	var tea_timer = Timer.new()
	tea_timer.wait_time = 20.0
	tea_timer.timeout.connect(_on_tea_time)
	add_child(tea_timer)
	tea_timer.start()
	
	print("[Corali] 克拉瑞已就位，负责执行脚本任务")

func _on_tea_time() -> void:
	if current_state in [AgentState.IDLE, AgentState.WORKING]:
		_go_drink_coffee()

func _go_drink_coffee() -> void:
	current_state = AgentState.DRINKING
	_update_thought_bubble()
	await get_tree().create_timer(2.5).timeout
	current_state = AgentState.IDLE
