extends Agent

func _ready() -> void:
	agent_id = "xiaoyuan-explore"
	agent_name = "小远"
	display_name = "Xiaoyuan"
	agent_color = Color(0.8, 0.2, 0.2)  # 红色
	home_floor = 3
	home_position = Vector2(400, 250)
	
	sprite.color = agent_color
	
	# 小远：工作更快但更容易"摸鱼"
	var play_timer = Timer.new()
	play_timer.wait_time = 45.0
	play_timer.timeout.connect(_on_play_time)
	add_child(play_timer)
	play_timer.start()
	
	print("[Xiaoyuan] 小远已就位")

func _on_play_time() -> void:
	# 15% 几率摸鱼5秒
	if randf() < 0.15 and current_state == AgentState.WORKING:
		thought_bubble.text = "🎮"
		await get_tree().create_timer(5.0).timeout
		# 回到工作
		var tasks = get_node("/root/TaskBoard").get_tasks_by_owner(agent_id)
		if tasks.size() > 0:
			set_task(tasks[0])

func _go_random_walk() -> void:
	# 小远喜欢在自己的小隔间附近走
	var bounds = Rect2(300, 200, 200, 150)
	target_position = Vector2(
		randi_range(bounds.position.x, bounds.position.x + bounds.size.x),
		randi_range(bounds.position.y, bounds.position.y + bounds.size.y)
	)
	current_state = AgentState.WALKING
