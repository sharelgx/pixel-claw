extends Agent

func _ready() -> void:
	super._ready()
	
	agent_id = "jarvis-feishu"
	agent_name = "贾维斯"
	display_name = "Jarvis"
	home_floor = 2
	home_position = Vector2(300, 200)
	
	# 检查任务
	var work_timer = Timer.new()
	work_timer.wait_time = 1.0
	work_timer.timeout.connect(_on_work_tick)
	add_child(work_timer)
	work_timer.start()

func _on_work_tick() -> void:
	if current_state == AgentState.IDLE:
		var tasks = get_node("/root/TaskBoard").get_tasks_by_owner(agent_id)
		if tasks.size() > 0:
			set_task(tasks[0])
