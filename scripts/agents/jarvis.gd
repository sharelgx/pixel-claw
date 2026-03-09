extends Agent

func _ready() -> void:
	agent_id = "jarvis-feishu"
	agent_name = "贾维斯"
	display_name = "Jarvis"
	agent_color = Color(0.2, 0.6, 1.0)  # 蓝色
	home_floor = 2
	home_position = Vector2(300, 200)
	
	# 创建后立即设置颜色
	sprite.color = agent_color
	
	# 贾维斯：更频繁的工作状态切换
	var work_timer = Timer.new()
	work_timer.wait_time = 1.0
	work_timer.timeout.connect(_on_work_tick)
	add_child(work_timer)
	work_timer.start()
	
	print("[Jarvis] 贾维斯已就位")

func _on_work_tick() -> void:
	if current_state == AgentState.IDLE:
		# 模拟收到新消息
		var tasks = get_node("/root/TaskBoard").get_tasks_by_owner(agent_id)
		if tasks.size() > 0:
			set_task(tasks[0])
