extends Agent

func _ready() -> void:
	agent_id = "corali-feishu"
	agent_name = "克拉瑞"
	display_name = "Corali"
	agent_color = Color(1.0, 0.4, 0.8)  # 粉红色
	home_floor = 2
	home_position = Vector2(500, 200)
	
	sprite.color = agent_color
	
	# 克拉瑞：更喜欢休息
	var tea_timer = Timer.new()
	tea_timer.wait_time = 20.0
	tea_timer.timeout.connect(_on_tea_time)
	add_child(tea_timer)
	tea_timer.start()
	
	print("[Corali] 克拉瑞已就位")

func _on_tea_time() -> void:
	if current_state == AgentState.WORKING or current_state == AgentState.IDLE:
		_go_drink_coffee()  # 复用喝水动画

func _go_drink_coffee() -> void:
	current_state = AgentState.DRINKING
	await get_tree().create_timer(2.0).timeout
	current_state = AgentState.IDLE
